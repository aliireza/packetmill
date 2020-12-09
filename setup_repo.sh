#!/bin/sh

# Clone and Compile X-Change
setup_xchange () {
  git clone git@github.com:tbarbette/xchange.git || (cd xchange ; git pull)
  rm -fr x86_64-native-linux-*
  make install T=x86_64-native-linux-clanglto
  git checkout v20.02
  make install T=x86_64-native-linux-clang
  make install T=x86_64-native-linux-gcc
}

# Heads-up

echo "Please make sure that LLVM toolchain and required packages (python3, pip, and cmake) are not broken!"
echo [press any key to continue]
read input

# Install Basic Dependencies
sudo apt-get update
sudo apt-get install build-essential cmake python3 python3-pip

# Clone PMU-Tools
git clone https://github.com/andikleen/pmu-tools.git || (cd pmu-tools ; git pull)

# Setup LLVM Toochain + Clang

sh ./llvm-clang.sh 10

# Setup X-Change
setup_xchange

# Compile LLVM

cd LLVM/
mkdir -p build 
cd build/
cmake ..
make 


# Setup NPF

python3 -m pip install --user npf


# Final message

echo "Sometimes, X-Change (DPDK) will not be compiled properly, so you need to do it manually."
echo "You can check README.md and the content of this bash script for more details."
