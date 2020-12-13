N_RUNS=5
CASE?=router
PROFILE?=perf

MAKEFLAGS := -j 1

# NPF Clusters (dut.node and pkt-gen.node should be defined in cluster/)
NPF_CLUSTER=client=client-100G dut=dut-100G client2=client2-100G

NPF_OUTPUT_NAME?=packetmill-results.pdf
NPF_OUTPUT= --output --output-columns x all --max-results --graph-filename ${NPF_OUTPUT_NAME}
NPF_FLAGS= --show-full --rand-env 65536 --build-folder ./npf_build/ --force-retest ${NPF_OUTPUT} # --force-build

# Tools path 
DUT_PMU_PATH=$(CURDIR)/../pmu-tools # PMU Tools
XCHG_PATH=$(CURDIR)/../xchange # X-Change (DPDK)
DUT_BOLT_PATH=$(CURDIR)/../llvm-bolt/build/bin/ # BOLT Binary Optimizer
DUT_AUTOFDO_PATH=$(CURDIR)/../autofdo/ # Autofdo Tool
LLVM_PASS_PATH=$(CURDIR)/../LLVM # LLVM Passes
EXP_PATH=$(CURDIR) # Current Directory

TOOLS_PATH := 
TOOLS_PATH += DUT_PMU_PATH=${DUT_PMU_PATH}
TOOLS_PATH += XCHG_PATH=${XCHG_PATH}
TOOLS_PATH += DUT_BOLT_PATH=${DUT_BOLT_PATH}
TOOLS_PATH += DUT_AUTOFDO_PATH=${DUT_AUTOFDO_PATH}
TOOLS_PATH += LLVM_PASS_PATH=${LLVM_PASS_PATH}
TOOLS_PATH += EXP_PATH=${EXP_PATH}

# Repositories

CPY_CLANG_REPO=packetmill-clang-cpy
CPY_CLANG_LTO_REPO=packetmill-clang-flto-cpy
OVRLY_CLANG_LTO_REPO=packetmill-clang-flto-ovrly
INSIDE_CLANG_LTO_REPO=packetmill-clang-flto-inside
XCHG_CLANG_LTO_REPO=packetmill-clang-flto-xchg
CLANG_PGO_REPO=packetmill-clang-cpy-pgo
CLANG_PGO_PROFILE_REPO=packetmill-clang-cpy-pgo-profile
CLANG_BOLT_REPO=packetmill-clang-cpy-bolt


CREATE_PROF := $(addsuffix create_llvm_prof,$(DUT_AUTOFDO_PATH))
PROFILE_PATH := $(addsuffix /code.prof,$(EXP_PATH))

AE_SYNTHETIC = test_xchg_fwd test_packetmill_router test_packetmill_ids test_sourcecode_router test_packetmill_nat


AE: $(AE_SYNTHETIC)


# Source-code Modifications Router via Copying (Vanilla Click) - Router - single core
test_sourcecode_router:
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${CPY_CLANG_REPO}+devir:Devirtualize ${CPY_CLANG_REPO}+constants:Constant ${CPY_CLANG_REPO}+graph:Graph ${CPY_CLANG_REPO}+embedding:All --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} udp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} GEN_LENGTH={64,512,1024}
	rm -fr test_sourcecode_router/
	mkdir -p test_sourcecode_router
	mv packetmill-results* test_sourcecode_router/

# Metadata Management Comparisson (X-Change vs. Overlaying vs. Copying) - Forwarding - single core
test_xchg_fwd:
	npf-compare ${CPY_CLANG_LTO_REPO}+vanilla:Copying ${OVRLY_CLANG_LTO_REPO}+vanilla:Overlaying ${XCHG_CLANG_LTO_REPO}+vanilla,xchg:X-Change  --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} novec udp fwd --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} GEN_LENGTH={64,512,1024}
	rm -fr test_xchg_fwd/
	mkdir -p test_xchg_fwd
	mv packetmill-results* test_xchg_fwd/

# Router Comparisson (Vanilla vs. PacketMill) - single core
test_packetmill_router:
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} novec udp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} GEN_LENGTH={64,512,1024}
	rm -fr test_packetmill_router/
	mkdir -p test_packetmill_router
	mv packetmill-results* test_packetmill_router/

# IDS+VLAN Comparisson (Vanilla vs. PacketMill) - single core
test_packetmill_ids:
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} ids vlan novec udp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} GEN_LENGTH={64,512,1024}
	rm -fr test_packetmill_ids/
	mkdir -p test_packetmill_ids
	mv packetmill-results* test_packetmill_ids/

# NAT Comparisson (Vanilla vs. PacketMill) - multicore
test_packetmill_nat:
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} nat scaling novec udp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH}  GEN_LENGTH={1024}
	rm -fr test_packetmill_nat/
	mkdir -p test_packetmill_nat
	mv packetmill-results* test_packetmill_nat/

# Check LLVM Pass (reordering)
test_llvm_pass_router:
	npf-compare ${CPY_CLANG_REPO}+vanilla:NoLTO ${CPY_CLANG_LTO_REPO}+vanilla:ClickLTO ${CPY_CLANG_LTO_REPO}+clickopt:ReorderLTO --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} udp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} FREQ=3000 GEN_LENGTH={64,512,1024}
	rm -fr test_llvm_pass_router/
	mkdir -p test_llvm_pass_router
	mv packetmill-results* test_llvm_pass_router/

# Compare PacketMill & Vanilla with WorkPackage 
test_packetmill_wp:
	npf-compare ${CPY_CLANG_REPO}+vanilla:Vanilla ${XCHG_CLANG_LTO_REPO}+embedding,xchg:PacketMill  --testie test.testie --cluster ${NPF_CLUSTER} --tags ${CASE} novec wp --config n_runs=${N_RUNS} ${NPF_FLAGS} --variable ${TOOLS_PATH} FREQ=2300
	rm -fr packetmill_wp/
	mkdir -p packetmill_wp
	mv packetmill-results* packetmill_wp/


# Compare Vanilla FastClick vs. BOLT vs. PGO (clang)
test_bolt_pgo: perf.data.bolt code.prof
	export PROFILE_PATH=${PROFILE_PATH}
	npf-compare ${CLANG_BOLT_REPO}+vanilla:Vanilla ${CLANG_PGO_REPO}+vanilla:PGO ${CLANG_BOLT_REPO}+vanilla,boltpgo:Bolt --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} --config n_runs=${N_RUNS} ${NPF_FLAGS} --force-build --variable ${TOOLS_PATH} FREQ=3000 
	rm -fr test_bolt_pgo/
	mkdir -p test_bolt_pgo
	mv packetmill-results* test_bolt_pgo/
	mv perf.* test_bolt_pgo/
	mv code.prof test_bolt_pgo/

# Apply BOLT to FastClick
test_bolt: perf.data.bolt 
	npf-compare ${CLANG_BOLT_REPO}+vanilla,boltpgo:Bolt --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} --config n_runs=${N_RUNS} ${NPF_FLAGS} --force-build --variable ${TOOLS_PATH} FREQ=3000 
	rm -fr test_bolt/
	mkdir -p test_bolt
	mv packetmill-results* test_bolt/
	mv perf.* test_bolt/

# Apply PGO (clang) to FastClick
test_pgo: code.prof
	export PROFILE_PATH=${PROFILE_PATH}
	npf-compare  ${CLANG_PGO_REPO}+vanilla:PGO --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} --config n_runs=${N_RUNS} ${NPF_FLAGS} --force-build --variable ${TOOLS_PATH} FREQ=3000 
	rm -fr test_pgo/
	mkdir -p test_pgo
	mv packetmill-results* test_pgo/
	mv perf.* test_pgo/
	mv code.prof test_pgo/

# BOLT perf data
perf.data.bolt:
	npf-compare ${CLANG_BOLT_REPO}+vanilla,profilebolt:Profile --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} --config n_runs=1 ${NPF_FLAGS} --variable ${TOOLS_PATH}
	rm -fr packetmill-results*

# PGO perf data
perf.data.pgo:
	npf-compare ${CLANG_PGO_PROFILE_REPO}+vanilla,profilepgo:Profile --testie packetmill.npf --cluster ${NPF_CLUSTER} --tags ${CASE} --config n_runs=1 ${NPF_FLAGS} --variable ${TOOLS_PATH}
	rm -fr packetmill-results*

code.prof: perf.data.pgo
	sudo ${CREATE_PROF} --profile=./perf.data.pgo --binary=./npf_build/${CLANG_PGO_PROFILE_REPO}/userlevel/click --out=./code.prof

clean:
	rm -fr testie* perf-normalized.csv
	rm -fr results/
