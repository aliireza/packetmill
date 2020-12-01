#!/bin/bash

# The first part of the script is copied from nslrack-setup
# The second part is copied from https://gist.github.com/bhaskarvk/78a80d9b5d308c84ba43b4a4e599a439


if [ $# -ne 1 ]; then
  echo "$0: Pass the LLVM version (e.g., 10)"
  exit 1
fi

VERSION=$1
ERROR=1
SUCCESS=0

# For printing
tab="    "

# A colorful wrapper of the standard printf
log()
{
  local mode=$1
  local module=$2
  local message=$3
  if ! [[ $mode =~ '^[0-9]$' ]] ; then
    case $(echo $mode | tr '[:upper:]' '[:lower:]') in
      #   Black: 0
      #     Red: 1
      #   Green: 2
      #  Yellow: 3
      #    Blue: 4
      # Magenta: 5
      #    Cyan: 6
      #   White: 7
      info)    color=7; tag="INFO"  ;;
      debug)   color=6; tag="DEBUG" ;;
      warn)    color=3; tag="WARN"  ;;
      error)   color=1; tag="ERROR" ;;
      *)       color=7; tag="INFO"  ;;
    esac
  fi

  # Maximum lengths
  max_tag_len=6
  max_mod_len=19

  # Set the color according to the logginig level
  tput setaf $color;
  # Print
  printf "[%0$((${max_tag_len}-${#tag}))s%s] [%0$((${max_mod_len}-${#module}))s%s] %s \n" " " $tag " " $module "$message"
  # Reset the color
  tput sgr0;
}

# Check if a command has root privileges
check_if_root()
{
  if [[ $EUID != 0 ]]; then
    log error CheckRoot "Please run as root"
    return $ERROR
  fi

  return $SUCCESS
}


# Start
check_if_root && : || exit $ERROR

# Remove all existing alternatives
sudo update-alternatives --remove-all llvm
sudo update-alternatives --remove-all clang

# exit on first error
set -e

# Install Clang/LLVM 10.0

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh $VERSION


# Linking llvm-$VERSION and clang-$VERSION to llvm and clang 
sudo update-alternatives \
  --install /usr/lib/llvm              llvm             /usr/lib/llvm-$VERSION  20 \
  --slave   /usr/bin/llvm-config       llvm-config      /usr/bin/llvm-config-$VERSION  \
	--slave   /usr/bin/llvm-ar           llvm-ar          /usr/bin/llvm-ar-$VERSION \
	--slave   /usr/bin/llvm-as           llvm-as          /usr/bin/llvm-as-$VERSION \
	--slave   /usr/bin/llvm-bcanalyzer   llvm-bcanalyzer  /usr/bin/llvm-bcanalyzer-$VERSION \
	--slave   /usr/bin/llvm-cov          llvm-cov         /usr/bin/llvm-cov-$VERSION \
	--slave   /usr/bin/llvm-diff         llvm-diff        /usr/bin/llvm-diff-$VERSION \
	--slave   /usr/bin/llvm-dis          llvm-dis         /usr/bin/llvm-dis-$VERSION \
	--slave   /usr/bin/llvm-dwarfdump    llvm-dwarfdump   /usr/bin/llvm-dwarfdump-$VERSION \
	--slave   /usr/bin/llvm-extract      llvm-extract     /usr/bin/llvm-extract-$VERSION \
	--slave   /usr/bin/llvm-link         llvm-link        /usr/bin/llvm-link-$VERSION \
	--slave   /usr/bin/llvm-mc           llvm-mc          /usr/bin/llvm-mc-$VERSION \
  --slave   /usr/bin/llvm-mca          llvm-mca          /usr/bin/llvm-mca-$VERSION \
	--slave   /usr/bin/llvm-nm           llvm-nm          /usr/bin/llvm-nm-$VERSION \
	--slave   /usr/bin/llvm-objdump      llvm-objdump     /usr/bin/llvm-objdump-$VERSION \
  --slave   /usr/bin/llvm-objcopy      llvm-objcopy     /usr/bin/llvm-objcopy-$VERSION \
	--slave   /usr/bin/llvm-ranlib       llvm-ranlib      /usr/bin/llvm-ranlib-$VERSION \
	--slave   /usr/bin/llvm-readobj      llvm-readobj     /usr/bin/llvm-readobj-$VERSION \
  --slave   /usr/bin/llvm-readelf      llvm-readelf     /usr/bin/llvm-readelf-$VERSION \
	--slave   /usr/bin/llvm-rtdyld       llvm-rtdyld      /usr/bin/llvm-rtdyld-$VERSION \
	--slave   /usr/bin/llvm-size         llvm-size        /usr/bin/llvm-size-$VERSION \
	--slave   /usr/bin/llvm-stress       llvm-stress      /usr/bin/llvm-stress-$VERSION \
	--slave   /usr/bin/llvm-symbolizer   llvm-symbolizer  /usr/bin/llvm-symbolizer-$VERSION \
	--slave   /usr/bin/llvm-tblgen       llvm-tblgen      /usr/bin/llvm-tblgen-$VERSION \

sudo update-alternatives \
  --install /usr/bin/clang                 clang                  /usr/bin/clang-$VERSION     20 \
  --slave   /usr/bin/clang++               clang++                /usr/bin/clang++-$VERSION \
  --slave   /usr/bin/lld                   lld                    /usr/bin/lld-$VERSION \
  --slave   /usr/bin/clangd                clangd                 /usr/bin/clangd-$VERSION \
  --slave   /usr/bin/lldb                  lldb                   /usr/bin/lldb-$VERSION \
  --slave   /usr/bin/lldb-server           lldb-server            /usr/bin/lldb-server-$VERSION \
  --slave   /usr/bin/llc                   llc                    /usr/bin/llc-$VERSION \
  --slave   /usr/bin/opt                   opt                    /usr/bin/opt-$VERSION
    
# Creating a link to lld
sudo ln -sf /usr/bin/lld /usr/bin/ld.lld

rm llvm.sh
