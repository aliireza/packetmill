# PacketMill: Toward per-core 100-Gbps Networking

PacketMill is a system for optimizing software packet processing, which (i) introduces a new model ([X-Change][x-change-repo]) to efficiently manage packet metadata and (ii) employs code-optimization techniques to better utilize commodity hardware. PacketMill grinds the whole packet processing stack, from the high-level network function configuration file to the low-level userspace network (specifically Data Plane Development Kit or [DPDK][dpdk-page]) drivers, to mitigate inefficiencies and produce a customized binary for a given network function. 

PacketMill is composed of three main components:

1. **X-Change:** developed as an Application Programming Interface (API) within DPDK, which realizes customized
buffers when using DPDK, rather than relying on the generic ***rte_mbuf*** structure;
2. **Source-code modifications:** implemented on top of a resurrected & modified ***click-devirtualize***, exploiting
the information defining a NF (i.e., Click configuration file) to mitigate virtual calls, improve constant propagation & constant folding; and
1. **IR-based modifications:** implemented as LLVM optimization passes applied to the complete program’s IR bitcode
as extracted from Link-Time Optimization (LTO), which reoders the commonly used data structures (i.e., ***Packet*** class in FastClick).

For more information, please refer to PacketMill's [paper][packetmill-paper].

## Applicability

We have developed/tested PacketMill for/on [FastClick][fastclick-repo], but our techniques could be adapted to other packet processing frameworks.

### X-Change

We modified the MLX5 driver used by Mellanox NICs. However, X-Change is applicable to other drivers, as other (e.g., Intel) drivers are implemented similarly and have the same inefficiencies. Although we have only tested X-Change with FastClick, other DPDK-based packet processing frameworks (e.g., BESS and VPP) could equally benefit from X-Change, as our proposed model only modifies DPDK userspace drivers.


### Code-optimizations

We implemented our source-code optimizations on top of [click-devirtualize][devirtualize-paper], but it is possible to apply the same optimization to other packet processing frameworks such as BESS and VPP.


## What is included here?

This repository contains information/source code to use PacketMill and reproduce the results presented in our ASPLOS'21 [paper][packetmill-paper].


## Experiments

The experiments are located at `experiments/`. The folder has a `Makefile` and `README.md` that can be used to run the experiments.

**Note: Before running the experiments you need to prepare your testbed according to our following guidelines.**


## Testbed

Our experiments mainly requires `npf`, `X-Change`, `FastClick`, and `LLVM toolchain`. 

### Network Performance Framework (NPF) Tool

You can clone and build NPF based on [guidelines][npf-setup] for our previous paper. Additionally, you can check the NPF README file.  

### X-Change

To build X-Change with clang and clang (LTO), you can run the following commands:

```bash
git clone git@github.com:tbarbette/xchange.git
cd xchange/
make install T=x86_64-native-linux-clang
make install T=x86_64-native-linux-clanglto
```

After building X-Change, you have to define `RTE_SDK` and `RTE_TARGET`. To do so, run:

```bash
export RTE_SDK=/home/alireza/packetmill/xchange/
export RTE_TARGET=x86_64-native-linux-clanglto
```

Fore more information, please check X-Change [repository][x-change-repo].

### LLVM Toolchain



### LLVM Pass - Reordering Pass



## Citing our paper

If you use PacketMill or X-Change in any context, please cite our [paper][packetmill-paper]:

```bibtex
@inproceedings{farshin-packetmill,
author = {Farshin, Alireza and Barbette, Tom and Roozbeh, Amir and {Maguire Jr.}, Gerald Q. and Kosti\'{c}, Dejan},
title = {PacketMill: Toward per-core 100-Gbps Networking},
year = {2021},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
booktitle = {Proceedings of the Twenty-Sixth International Conference on Architectural Support for Programming Languages and Operating Systems},
keywords = {Packet Processing, Metadata Management, PacketMill, X-Change, 100 Gbps, Network Function Virtualization (NFV), Click, DPDK, Link-Time Optimization (LTO), LLVM},
location = {Virtual},
series = {ASPLOS '21}
}
```

## Getting Help

If you have any questions regarding our code or the paper, you can contact [Alireza Farshin][alireza-page] (farshin at kth.se) and/or [Tom Barbette][tom-page] (barbette at kth.se).


[x-change-repo]: https://github.com/tbarbette/xchange
[dpdk-page]: https://www.dpdk.org/
[packetmill-paper]: https://people.kth.se/~farshin/documents/packetmill-asplos21.pdf
[packetmill-repo]: https://github.com/aliireza/packetmill 
[fastclick-repo]: https://github.com/tbarbette/fastclick
[tom-page]: https://www.kth.se/profile/barbette
[alireza-page]: https://www.kth.se/profile/farshin/
[devirtualize-paper]: https://pdos.csail.mit.edu/~rtm/papers/click-asplos02.pdf
[ddio-testbed]: https://github.com/aliireza/ddio-bench/blob/master/TESTBED.md 
[npf-setup]: https://github.com/aliireza/ddio-bench/blob/master/TESTBED.md#network-performance-framework-npf-tool
