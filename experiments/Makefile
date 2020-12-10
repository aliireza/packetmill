N_RUNS=1
CASE?=router
PROFILE?=perf

MAKEFLAGS := -j 1

# NPF Clusters (dut.node and pkt-gen.node should be defined in cluster/)
NPF_CLUSTER=client=client-100G dut=dut-100G client2=client2-100G

NPF_OUTPUT_NAME?=packetmill-results.pdf
NPF_OUTPUT= --output --output-columns x all --max-results --graph-filename ${NPF_OUTPUT_NAME}
NPF_FLAGS= --show-full --rand-env --build-folder ./npf_build/ --force-retest ${NPF_OUTPUT} # --force-build

# Tools path 
TOOLS_PATH := 
TOOLS_PATH += DUT_PMU_PATH=$(CURDIR)/../pmu-tools # PMU Tools
TOOLS_PATH += XCHG_PATH=$(CURDIR)/../xchange # X-Change (DPDK)
TOOLS_PATH += EXP_PATH=$(CURDIR) # Current Directory
TOOLS_PATH += LLVM_PASS_PATH=$(CURDIR)/../LLVM

CPY_CLANG_REPO=packetmill-clang-cpy
CPY_CLANG_LTO_REPO=packetmill-clang-flto-cpy
OVRLY_CLANG_LTO_REPO=packetmill-clang-flto-ovrly
XCHG_CLANG_LTO_REPO=packetmill-clang-flto-xchg


AE_SYNTHETIC = test_sourcecode_router test_xchg_fwd test_packetmill_router test_packetmill_ids test_packetmill_nat


all: $(AE_SYNTHETIC)


# Source-code Modifications Router via Copying (Vanilla Click) - Router - single core
test_sourcecode_router:
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${CPY_CLANG_REPO}+devir:Devirtualize ${CPY_CLANG_REPO}+constants:Constant ${CPY_CLANG_REPO}+graph:Graph ${CPY_CLANG_REPO}+embedding:All --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} freqtune udp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} FREQ=3000 GEN_LENGTH={64,512,1024}
	rm -fr test_sourcecode_router/
	mkdir -p test_sourcecode_router
	mv packetmill-results* test_sourcecode_router/

# Metadata Management Comparisson (X-Change vs. Overlaying vs. Copying) - Forwarding - single core
test_xchg_fwd:
	npf-compare ${CPY_CLANG_LTO_REPO}+vanilla:Copying ${OVRLY_CLANG_LTO_REPO}+vanilla:Overlaying ${XCHG_CLANG_LTO_REPO}+vanilla,xchg:X-Change  --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} novec freqtune udp fwd --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} FREQ=3000 GEN_LENGTH={64,512,1024}
	rm -fr test_xchg_fwd/
	mkdir -p test_xchg_fwd
	mv packetmill-results* test_xchg_fwd/

# Router Comparisson (Vanilla vs. PacketMill) - single core
test_packetmill_router:
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} novec freqtune udp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} FREQ=3000 GEN_LENGTH={64,512,1024}
	rm -fr test_packetmill_router/
	mkdir -p test_packetmill_router
	mv packetmill-results* test_packetmill_router/

# IDS+VLAN Comparisson (Vanilla vs. PacketMill) - single core
test_packetmill_ids:
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} ids vlan novec freqtune udp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} FREQ=3000 GEN_LENGTH={64,512,1024}
	rm -fr test_packetmill_ids/
	mkdir -p test_packetmill_ids
	mv packetmill-results* test_packetmill_ids/

# NAT Comparisson (Vanilla vs. PacketMill) - multi core
test_packetmill_nat:
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} nat scaling novec freqtune udp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} FREQ=3000 GEN_LENGTH={64,512,1024}
	rm -fr test_packetmill_nat/
	mkdir -p test_packetmill_nat
	mv packetmill-results* test_packetmill_nat/

# Check LLVM Pass (reordering)
test_llvm_pass_router:
	npf-compare ${CPY_CLANG_REPO}+vanilla:NoLTO ${CPY_CLANG_LTO_REPO}+vanilla:ClickLTO ${CPY_CLANG_LTO_REPO}+clickopt:ReorderLTO --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} freqtune udp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} FREQ=3000 GEN_LENGTH={64,512,1024}
	rm -fr test_llvm_pass_router/
	mkdir -p test_llvm_pass_router
	mv packetmill-results* test_llvm_pass_router/

clean:
	rm -fr testie* perf-normalized.csv
	rm -fr results/
