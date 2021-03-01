#!/bin/sh

# Clone and Compile X-Change
setup_xchange () {
  git clone https://github.com/tbarbette/xchange.git || (cd xchange ; git pull)
  rm -fr x86_64-native-linux-*
  make install T=x86_64-native-linux-clanglto
}

# Clone and Compile DPDK v20.02
setup_dpdk () {
  git clone https://github.com/tbarbette/xchange.git dpdk || (cd dpdk ; git pull)
  git checkout v20.02
  rm -fr x86_64-native-linux-*
  make install T=x86_64-native-linux-gcc
  make install T=x86_64-native-linux-clang
}

# Heads-up

echo "Please make sure that LLVM toolchain and required packages (python3, pip, and cmake) are not broken!"
echo [press any key to continue]
read input

# Install Basic Dependencies
sudo apt-get update
sudo apt-get install build-essential cmake python3 python3-pip

# Install Perf
sudo apt-get install linux-cloud-tools-$(uname -r) linux-tools-$(uname -r)

# Clone PMU-Tools
git clone https://github.com/andikleen/pmu-tools.git || (cd pmu-tools ; git pull)

# Setup LLVM Toochain + Clang

sh ./llvm-clang.sh 10

# Setup X-Change and DPDK v20.02
setup_xchange
setup_dpdk

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
