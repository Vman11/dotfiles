### Based on code in https://github.com/Erotemic/local/blob/main/tools/pyenv_ext/pyenv_ext_commands.sh

apt_ensure(){
     __doc__="
     Checks to see if the packages are installed and installs them if needed.
     "
     ARGS=("$@")
     MISS_PKGS=()
     HIT_PKGS=()
     # Only use the sudo command if we need it (i.e. we are not root)
     _SUDO=""
     if [ "$(whoami)" != "root" ]; then
         _SUDO="sudo "
     fi
     # shellcheck disable=SC2068
     for PKG_NAME in ${ARGS[@]}
     do
         # Check if the package is already installed or not
         if dpkg -l "$PKG_NAME" | grep "^ii *$PKG_NAME" > /dev/null; then
             echo "Already have PKG_NAME='$PKG_NAME'"
             # shellcheck disable=SC2268,SC2206
             HIT_PKGS=(${HIT_PKGS[@]} "$PKG_NAME")
         else
             echo "Do not have PKG_NAME='$PKG_NAME'"
             # shellcheck disable=SC2268,SC2206
             MISS_PKGS=(${MISS_PKGS[@]} "$PKG_NAME")
         fi
     done
     # Install the packages if any are missing
     if [ "${#MISS_PKGS}" -gt 0 ]; then
         if [ "${UPDATE}" != "" ]; then
             $_SUDO apt update -y
         fi
         $_SUDO apt install -y "${MISS_PKGS[@]}"
     else
         echo "No missing packages"
     fi
 }

 # Install requirements for building Python (apt-specific command, might be different for other distros)
 apt_ensure \
     make build-essential libssl-dev zlib1g-dev \
     libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
     libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev

 # Download pyenv
 export PYENV_ROOT="$HOME/.pyenv"
 if [[ ! -d "$PYENV_ROOT" ]]; then
     git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT
     (cd $PYENV_ROOT && src/configure && make -C src)
 fi

 # We will need to add something similar in your bashrc
 if [ -d "$PYENV_ROOT" ]; then
     export PATH="$PYENV_ROOT/bin:$PATH"
     eval "$($PYENV_ROOT/bin/pyenv init -)"
     source $PYENV_ROOT/completions/pyenv.bash
 fi

 # Compiling with optimizations makes Python run ~20% faster:
 # For more info see:
 # https://github.com/docker-library/python/issues/160#issuecomment-509426916
 # https://gist.github.com/nszceta/ec6efc9b5e54df70deeec7bceead0a1d
 # https://clearlinux.org/news-blogs/boosting-python-profile-guided-platform-specific-optimizations
 CHOSEN_PYTHON_VERSION=3.12.5

 PROFILE_TASK="-m test.regrtest --pgo test_array test_base64 test_binascii test_binhex test_binop test_c_locale_coercion test_csv test_json test_hashlib test_unicode test_codecs test_traceback test_decimal test_math test_compile test_threading test_time test_fstring test_re test_float test_class test_cmath test_complex test_iter test_struct test_slice test_set test_dict test_long test_bytes test_memoryview test_io test_pickle"

 PYTHON_CONFIGURE_OPTS="--enable-shared --enable-optimizations --with-computed-gotos --with-lto"

 PYTHON_CFLAGS="-march=native -O2 -pipe"

 PROFILE_TASK=$PROFILE_TASK \
 PYTHON_CFLAGS="$PYTHON_CFLAGS" \
 PYTHON_CONFIGURE_OPTS="$PYTHON_CONFIGURE_OPTS" \
 pyenv install $CHOSEN_PYTHON_VERSION --verbose

 # Set your global pyenv version, so your prefix maps correctly.
 pyenv shell $CHOSEN_PYTHON_VERSION
 pyenv global $CHOSEN_PYTHON_VERSION

 # Create the virtual environment
 PYENV_PREFIX=$(pyenv prefix)
 python -m venv $PYENV_PREFIX/envs/pyenv$CHOSEN_PYTHON_VERSION

 # Add this to your bashrc so you have access to the pyenv command
 # and optionally auto-start in a virtual environment

 #### START BASHRC PART ###
 echo "#### ADD THIS TO YOUR BASH RC ####"
 BASHRC_CONTENTS='

 # Add the pyenv command to our environment if it exists
 export PYENV_ROOT="$HOME/.pyenv"
 if [ -d "$PYENV_ROOT" ]; then
     export PATH="$PYENV_ROOT/bin:$PATH"
     eval "$($PYENV_ROOT/bin/pyenv init -)"
     source $PYENV_ROOT/completions/pyenv.bash
     export PYENV_PREFIX=$(pyenv prefix)
 fi

 # Optionally auto-activate the chosen pyenv pyenv environment
 CHOSEN_PYTHON_VERSION=3.12.5
 if [ -d "$PYENV_PREFIX/envs/pyenv$CHOSEN_PYTHON_VERSION" ]; then
     source $PYENV_PREFIX/envs/pyenv$CHOSEN_PYTHON_VERSION/bin/activate
 fi
 '
 echo "#### ADD THE ABOVE TO YOUR BASH RC ####"
 echo "$BASHRC_CONTENTS"
 #### END BASHRC PART ####
