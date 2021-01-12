# Change the number of runs per experiment
N_RUNS=5

# Default Configuration
CASE?=router
PROFILE?=perf

# To avoid running multiple experiments at once
MAKEFLAGS := -j 1

# NPF Clusters (dut.node and pkt-gen.node should be defined in cluster/)
NPF_CLUSTER=client=client-100G dut=dut-100G client2=client2-100G

NPF_OUTPUT_NAME?=packetmill-results.pdf
NPF_OUTPUT= --output --output-columns x all --max-results --graph-filename ${NPF_OUTPUT_NAME}
NPF_INT_FLAGS := --show-full --rand-env 65536 --build-folder ./npf_build/ --force-retest ${NPF_OUTPUT} $(NPF_FLAGS)

# Tools path 
DUT_PMU_PATH=$(CURDIR)/../pmu-tools # PMU Tools
XCHG_PATH=$(CURDIR)/../xchange # X-Change (DPDK)
XCHG_EXAMPLES_PATH=$(CURDIR)/../xchange/examples/ # X-Change (DPDK) - Examples
#BESS_PATH=$(CURDIR)/../bess # BESS
#VPP_PATH=$(CURDIR)/../vpp.2005 # VPP
DUT_BOLT_PATH=$(CURDIR)/../llvm-bolt/build/bin/ # BOLT Binary Optimizer
DUT_AUTOFDO_PATH=$(CURDIR)/../autofdo/ # Autofdo Tool
LLVM_PASS_PATH=$(CURDIR)/../LLVM # LLVM Passes
EXP_PATH=$(CURDIR) # Current Directory

TOOLS_PATH := 
TOOLS_PATH += DUT_PMU_PATH=${DUT_PMU_PATH}
TOOLS_PATH += XCHG_PATH=${XCHG_PATH}
TOOLS_PATH += XCHG_EXAMPLES_PATH=${XCHG_EXAMPLES_PATH}
TOOLS_PATH += BESS_PATH=
TOOLS_PATH += VPP_PATH=
TOOLS_PATH += DUT_BOLT_PATH=${DUT_BOLT_PATH}
TOOLS_PATH += DUT_AUTOFDO_PATH=${DUT_AUTOFDO_PATH}
TOOLS_PATH += LLVM_PASS_PATH=${LLVM_PASS_PATH}
TOOLS_PATH += EXP_PATH=${EXP_PATH}

# Repositories
CPY_GCC_REPO=packetmill
CPY_CLANG_REPO=packetmill-clang-cpy
CPY_CLANG_REPO_STRIPPED=packetmill-clang-cpy-stripped
CPY_CLANG_LTO_REPO=packetmill-clang-flto-cpy
OVRLY_CLANG_LTO_REPO=packetmill-clang-flto-ovrly
INSIDE_CLANG_LTO_REPO=packetmill-clang-flto-inside
XCHG_CLANG_LTO_REPO=packetmill-clang-flto-xchg
XCHG_CLANG_LTO_REPO_STRIPPED=packetmill-clang-flto-xchg-stripped
CLANG_PGO_REPO=packetmill-clang-cpy-pgo
CLANG_PGO_PROFILE_REPO=packetmill-clang-cpy-pgo-profile
CLANG_BOLT_REPO=packetmill-clang-cpy-bolt
BESS_REPO=bess
BESS_NOVEC_REPO=bess-no-vec
VPP_REPO=vpp
VPP_NOVEC_REPO=vpp-no-vec

# Profiling related for PGO
CREATE_PROF := $(addsuffix create_llvm_prof,$(DUT_AUTOFDO_PATH))
PROFILE_PATH := $(addsuffix /code.prof,$(EXP_PATH))

.PHONY: deps deps-xchg all clean AE

# Verification of the Setup
deps:
ifndef RTE_SDK
	$(error Please define RTE_SDK environment variable)
endif
ifndef RTE_TARGET
		$(error Please define RTE_TARGET environment variable)
endif
ifeq ($(wildcard ${RTE_SDK}/${RTE_TARGET}/),)
		$(error The folder ${RTE_SDK}/${RTE_TARGET} is not found. Please install DPDK  as per the README.md documentation and set the RTE_SDK and RTE_TARGET environment variables)
endif
ifeq ($(shell which npf-compare),)
		$(error The NPF toolkit is required to manage experiments. Install it with python3 -m pip install --user npf)
endif
	@:

deps-xchg: deps
ifndef XCHG_SDK
        $(error Please define XCHG_SDK environment variable)
endif
ifndef XCHG_TARGET
                $(error Please define XCHG_TARGET environment variable)
endif
ifeq ($(wildcard ${XCHG_SDK}/${XCHG_TARGET}/),)
                $(error The folder ${XCHG_SDK}/${XCHG_TARGET} is not found. Please install X-Change as per the README.md documentation and set the XCHG_SDK and XCHG_TARGET environment variables)
endif
ifeq ($(wildcard ${XCHG_SDK}/lib/librte_xchg/),)
		$(error X-Change was found, but it does not seem to be the X-Change version. Please follow the guide in README.md)
endif
	@:

all: deps deps-xchg
	@echo Your setup is fine! Now type 'make AE' to run the experiments

.DEFAULT_GOAL := all


# Now the Real Experiments
AE_SYNTHETIC = test_xchg_fwd test_packetmill_router test_packetmill_ids test_packetmill_nat test_sourcecode_router

AE: $(AE_SYNTHETIC)

# Metadata Management Comparisson (X-Change vs. Overlaying vs. Copying) - Forwarding - single core
test_xchg_fwd: deps-xchg
	npf-compare ${CPY_CLANG_LTO_REPO}+vanilla:Copying ${OVRLY_CLANG_LTO_REPO}+vanilla:Overlaying ${XCHG_CLANG_LTO_REPO}+vanilla,xchg:X-Change  --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} novec udp udpgen fwd --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --variable ${TOOLS_PATH} GEN_LENGTH={64,512,1024}
	rm -fr test_xchg_fwd/
	mkdir -p test_xchg_fwd
	mv packetmill-results* test_xchg_fwd/

# Metadata Management Comparisson (X-Change vs. Overlaying vs. Copying) - with/without vectorized PMD - Forwarding - single core
test_xchg_fwd_vec: deps-xchg
	npf-compare ${CPY_CLANG_LTO_REPO}+vanilla,novec:Copying-NOVEC ${CPY_CLANG_LTO_REPO}+vanilla:Copying-VEC ${OVRLY_CLANG_LTO_REPO}+vanilla,novec:Overlaying-NOVEC ${OVRLY_CLANG_LTO_REPO}+vanilla:Overlaying-VEC ${XCHG_CLANG_LTO_REPO}+vanilla,xchg,novec:X-Change-NOVEC  ${XCHG_CLANG_LTO_REPO}+vanilla,xchg,xchgvec:X-Change-VEC --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} udp udpgen fwd --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} graph_color={6,6,1,1,5,2,4} --variable ${TOOLS_PATH} GEN_LENGTH=[64-1500#128]
	rm -fr test_xchg_fwd_vec/
	mkdir -p test_xchg_fwd_vec
	mv packetmill-results* test_xchg_fwd_vec/

# Metadata Management Comparisson - FastClick vs. L2FWD (with/without X-Change) 
test_xchg_app: deps-xchg
	npf-compare "local+dpdk,TARGET=fwd:L2fwd" "local+dpdk,TARGET=xchg:L2fwd-xchg" ${CPY_CLANG_REPO}+fwd:FastClick ${CPY_CLANG_REPO_STRIPPED}+fwd:FastClick-Light ${XCHG_CLANG_LTO_REPO}+fwd,xchg:PacketMill ${XCHG_CLANG_LTO_REPO_STRIPPED}+fwd,xchg:PacketMill-Light local+bess:BESS local+vpp:VPP --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags udpgen udp promisc dpdkfixed --config graph_color={6,6,1,1,5,2,4} n_runs=${N_RUNS} ${NPF_INT_FLAGS} --tags novec --variable ${TOOLS_PATH} VEC=0 FREQ=1200 --variables TOUCH=1 "GEN_LENGTH=[64-1500#128]" --force-retest 
	rm -fr test_xchg_app/
	mkdir -p test_xchg_app
	mv packetmill-results* test_xchg_app/

test_xchg_app_2: deps-xchg
	npf-compare ${CPY_CLANG_REPO}+fwd:FastClick ${CPY_CLANG_REPO_STRIPPED}+fwd:FastClick-Light ${XCHG_CLANG_LTO_REPO}+fwd,xchg:PacketMill ${XCHG_CLANG_LTO_REPO_STRIPPED}+fwd,xchg:PacketMill-Light local+bess:BESS local+vpp:VPP --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags udpgen udp promisc dpdkfixed --config graph_color={1,1,6,6,4,5} n_runs=${N_RUNS} ${NPF_INT_FLAGS} --tags novec --variable ${TOOLS_PATH} VEC=0 FREQ=1200 --variables TOUCH=1 "GEN_LENGTH=[64-1500#128]" --force-retest 
	rm -fr test_xchg_app_2/
	mkdir -p test_xchg_app_2
	mv packetmill-results* test_xchg_app_2/

test_stripped: deps-xchg
	npf-compare ${CPY_CLANG_REPO_STRIPPED}+fwd:FastClick-Light ${XCHG_CLANG_LTO_REPO_STRIPPED}+fwd,xchg:PacketMill-Light --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags udpgen udp promisc dpdkfixed --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --tags novec --variable ${TOOLS_PATH} VEC=0 FREQ=1200 --variables TOUCH=1 "GEN_LENGTH=[64-1500#128]" --force-retest 
	rm -fr test_stripped/
	mkdir -p test_stripped
	mv packetmill-results* test_stripped/

test_bess: deps-xchg
	npf-compare ${BESS_REPO}+bess:BESS ${BESS_NOVEC_REPO}+bess:BESS-NOVEC --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags udpgen udp promisc --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --tags novec --variable ${TOOLS_PATH} VEC=0 FREQ=1200 --variables "GEN_LENGTH=[64-1500#128]" --force-retest
	rm -fr test_bess/
	mkdir -p test_bess
	mv packetmill-results* test_bess/

test_vpp: deps-xchg
	npf-compare ${VPP_REPO}+vpp:VPP ${VPP_NOVEC_REPO}+vpp:VPP --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags udpgen udp promisc --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --tags novec --variable ${TOOLS_PATH} VEC=0 FREQ=1200 --variables "GEN_LENGTH=[64-1500#128]" --force-retest
	rm -fr test_vpp/
	mkdir -p test_vpp
	mv packetmill-results* test_vpp/

# Metadata Management Comparisson (X-Change vs. Copying) - with/without vectorized PMD - Forwarding DPDK - single core
test_xchg_l2fwd_dpdk: deps-xchg
	npf-compare fastclick --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} udpgen udp dpdk promisc --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --variable ${TOOLS_PATH} GEN_LENGTH=[64-1500#128] 
	rm -fr test_xchg_l2fwd_dpdk/
	mkdir -p test_xchg_l2fwd_dpdk
	mv packetmill-results* test_xchg_l2fwd_dpdk/

# Metadata Management Comparisson (X-Change vs. Copying) - with/without vectorized PMD - Forwarding DPDK - Trace+freqtune - single core
test_xchg_l2fwd_dpdk_freq: deps-xchg
	npf-compare fastclick --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} freqtune dpdk promisc --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --variable ${TOOLS_PATH}
	rm -fr test_xchg_l2fwd_dpdk_freq/
	mkdir -p test_xchg_l2fwd_dpdk_freq
	mv packetmill-results* test_xchg_l2fwd_dpdk_freq/

# Router Comparisson (Vanilla vs. PacketMill) - single core
test_packetmill_router: deps-xchg
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} novec udp udpgen --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --variable ${TOOLS_PATH} GEN_LENGTH={64,512,1024}
	rm -fr test_packetmill_router/
	mkdir -p test_packetmill_router
	mv packetmill-results* test_packetmill_router/

# IDS+VLAN Comparisson (Vanilla vs. PacketMill) - single core
test_packetmill_ids: deps-xchg
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} ids vlan novec udp udpgen --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --variable ${TOOLS_PATH} GEN_LENGTH={64,512,1024}
	rm -fr test_packetmill_ids/
	mkdir -p test_packetmill_ids
	mv packetmill-results* test_packetmill_ids/

# NAT Comparisson (Vanilla vs. PacketMill) - multicore
test_packetmill_nat: deps-xchg
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} nat scaling novec udp udpgen --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --variable ${TOOLS_PATH}  GEN_LENGTH={1024}
	rm -fr test_packetmill_nat/
	mkdir -p test_packetmill_nat
	mv packetmill-results* test_packetmill_nat/

# Check LLVM Pass (reordering)
test_llvm_pass_router: deps
	npf-compare ${CPY_CLANG_REPO}+vanilla:NoLTO ${CPY_CLANG_LTO_REPO}+vanilla:ClickLTO ${CPY_CLANG_LTO_REPO}+clickopt:ReorderLTO --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} udp udpgen --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --variable ${TOOLS_PATH} FREQ=3000 GEN_LENGTH={64,512,1024}
	rm -fr test_llvm_pass_router/
	mkdir -p test_llvm_pass_router
	mv packetmill-results* test_llvm_pass_router/

# Compare PacketMill & Vanilla with WorkPackage 
test_packetmill_wp: deps-xchg
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill  --testie test.testie --cluster ${NPF_CLUSTER} --tags ${CASE} novec wp --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --variable ${TOOLS_PATH} FREQ=2300
	rm -fr packetmill_wp/
	mkdir -p packetmill_wp
	mv packetmill-results* packetmill_wp/

# Source-code Modifications Router via Copying (Vanilla Click) - Router - single core
test_sourcecode_router: deps
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${CPY_CLANG_REPO}+devir:Devirtualize ${CPY_CLANG_REPO}+constants:Constant ${CPY_CLANG_REPO}+graph:Graph ${CPY_CLANG_REPO}+embedding:All --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} udp udpgen --config n_runs=${N_RUNS} ${NPF_INT_FLAGS} --variable ${TOOLS_PATH} GEN_LENGTH=[64-1500#128]
	rm -fr test_sourcecode_router/
	mkdir -p test_sourcecode_router
	mv packetmill-results* test_sourcecode_router/

# Compare Vanilla FastClick vs. BOLT vs. PGO (clang)
test_bolt_pgo: perf.data.bolt code.prof deps
	export PROFILE_PATH=${PROFILE_PATH}
	npf-compare ${CLANG_BOLT_REPO}+vanilla:Vanilla ${CLANG_PGO_REPO}+vanilla:PGO ${CLANG_BOLT_REPO}+vanilla,boltpgo:Bolt --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} --config n_runs=${N_RUNS} ${NPF_FLAGS} --force-build --variable ${TOOLS_PATH} FREQ=3000 
	rm -fr test_bolt_pgo/
	mkdir -p test_bolt_pgo
	mv packetmill-results* test_bolt_pgo/
	mv perf.* test_bolt_pgo/
	mv code.prof test_bolt_pgo/

# Apply BOLT to FastClick
test_bolt: perf.data.bolt  deps
	npf-compare ${CLANG_BOLT_REPO}+vanilla,boltpgo:Bolt --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} noperf --config n_runs=${N_RUNS} ${NPF_FLAGS} --force-build --variable ${TOOLS_PATH}
	rm -fr test_bolt/
	mkdir -p test_bolt
	mv packetmill-results* test_bolt/
	mv perf.* test_bolt/

# Compare Vanilla vs. Vanilla+BOLT FastClick
test_compare_bolt: perf.data.bolt  deps
	npf-compare ${CLANG_BOLT_REPO_SUBMITTED}+vanilla:Vanilla ${CLANG_BOLT_REPO_SUBMITTED}+vanilla,boltpgo:Vanilla+Bolt --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} freqtune --config n_runs=${N_RUNS} ${NPF_FLAGS} --force-build --variable ${TOOLS_PATH}
	rm -fr test_compare_bolt/
	mkdir -p test_compare_bolt
	mv packetmill-results* test_compare_bolt/
	mv perf.* test_compare_bolt/

# Apply PGO (clang) to FastClick
test_pgo: code.prof deps
	export PROFILE_PATH=${PROFILE_PATH}
	npf-compare  ${CLANG_PGO_REPO}+vanilla:PGO --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} --config n_runs=${N_RUNS} ${NPF_FLAGS} --force-build --variable ${TOOLS_PATH} FREQ=3000 
	rm -fr test_pgo/
	mkdir -p test_pgo
	mv packetmill-results* test_pgo/
	mv perf.* test_pgo/
	mv code.prof test_pgo/

# BOLT perf data
perf.data.bolt: deps
	npf-compare ${CLANG_BOLT_REPO_SUBMITTED}+vanilla,profilebolt:Profile --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} noperf --config n_runs=1 ${NPF_FLAGS} --force-build --variable ${TOOLS_PATH} FREQ=3000
	rm -fr packetmill-results*

	rm -fr packetmill-results*

# PGO perf data
perf.data.pgo: deps
	npf-compare ${CLANG_PGO_PROFILE_REPO}+vanilla,profilepgo:Profile --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} noperf --config n_runs=1 ${NPF_FLAGS} --force-build --variable ${TOOLS_PATH}
	rm -fr packetmill-results*

# PGO clang data
code.prof: perf.data.pgo
	sudo ${CREATE_PROF} --profile=./perf.data.pgo --binary=./npf_build/${CLANG_PGO_PROFILE_REPO}/userlevel/click --out=./code.prof

clean:
	rm -fr testie* perf-normalized.csv
	rm -fr results/
