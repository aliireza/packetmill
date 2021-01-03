#include "llvm/IR/Attributes.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include <cxxabi.h>
#include <string>
#include <vector>

using namespace llvm;

namespace {
struct ClassXCHGInlinePass : public ModulePass {
  static char ID;
  ClassXCHGInlinePass() : ModulePass(ID) {}

  bool runOnModule(Module &M) override {

    /*
     * This pass prepares the indirect driver call in l2fwd_launch_one_lcore for inlining
     * TODO: Get the function name via arg. 
     */

    /* RX Burst Function */
    std::string RXDriverFuncName = "mlx5_rx_burst_xchg_vec";

    /* DPDK Example Function */
    std::string L2FWDFuncName = "l2fwd_launch_one_lcore";

    /* Variable saving the call */
    CallInst *driverCall;

    errs() << "Searching for the call ...\n";
    for (auto &F : M) {
      std::string funcName = demangle(F.getName().data());
      auto found_l2fwd = funcName.find(L2FWDFuncName);
      if ((found_l2fwd != std::string::npos)) {
         errs() << "Searching in " << funcName << "\n";
        for (auto &BB : F) {
          for (auto &I : BB) {
            if (CallInst *CI = dyn_cast<CallInst>(&I)) {
              /* Finding a direct call to RXDriverFuncName */
              if (!(CI->isIndirectCall())) {
                if (auto FF = CI->getCalledFunction()) {
                  auto calleeName = FF->getName().str();
                  auto found_rxdriver_call = calleeName.find(RXDriverFuncName);
                  if ((found_rxdriver_call != std::string::npos)) {
                      /* Do something here if call does not have bitcast */
                      //driverCall=CI;
                  }
                  /* Finding a call to RXDriverFuncName with bitcast */
                } else if(Function *bitcastFunc = dyn_cast<Function>(CI->getCalledValue()->stripPointerCasts())) {
                  auto calleeName = bitcastFunc->getName().str();
                  auto found_rxdriver_call = calleeName.find(RXDriverFuncName);
                  if ((found_rxdriver_call != std::string::npos)){
                    errs () << "Found the call!\n";
                    /* Saving the call */
                    driverCall=CI;
                  }
                }
              }
            }
          }
        }
      }
    }

    /* If found any call replace the bitcast with call + zext */
    if(driverCall) {
      errs() << *driverCall << "\n";
      Function *bitcastFunc = dyn_cast<Function>(driverCall->getCalledValue()->stripPointerCasts());
      auto calleeName = bitcastFunc->getName().str();

      std::string type_str;
      llvm::raw_string_ostream rso(type_str);

      /* Saving the arguments of the call */
      // Value** args = new Value*[bitcastFunc->arg_size()];
      // Type** arg_types = new Type*[bitcastFunc->arg_size()];
      SmallVector<Value*,3> args_vec;
      int idx = 0;
      for(auto it = bitcastFunc->arg_begin(); it< bitcastFunc->arg_end(); it++){
        // args[idx] = driverCall->getArgOperand(idx);
        // arg_types[idx] = bitcastFunc->arg_begin()->getType();
        args_vec.push_back( driverCall->getArgOperand(idx));
        idx++;
      }
      /* Get the function output type */
      FunctionType* FT = bitcastFunc->getFunctionType();

      /* Create a new call instruction before the call */
      Twine output_name = Twine("inlined_driver");
      CallInst *NC = CallInst::Create(FT,bitcastFunc, makeArrayRef(args_vec),output_name,driverCall);

      /* Create a zext instruction before the instruction after the call */
      auto &Context = bitcastFunc->getContext();
      Instruction* nextInst = driverCall->getNextNode();
      ZExtInst *zext = new ZExtInst(NC,IntegerType::getInt32Ty(Context),"driver_output",nextInst);
      nextInst->setOperand(0, zext);

      /* Remove the call instruction */
      driverCall->eraseFromParent();
       /*change*/
      return true;
    } else {
      errs() << "No calls found!"
             << "\n";

      /*no change*/
      return false;
    }

    /*no change*/
    return false;
  }

private:
  /* Demangle a function name */
  std::string demangle(const char *name) {
    int status = -1;

    std::unique_ptr<char, void (*)(void *)> res{
        abi::__cxa_demangle(name, NULL, NULL, &status), std::free};
    return (status == 0) ? res.get() : std::string(name);
  }
};
} // namespace

char ClassXCHGInlinePass::ID = 0;

// Make the pass visible to opt.
static RegisterPass<ClassXCHGInlinePass> X("inline-xchg",
                                                "ClassDriverInline");

// Automatically enable the pass in clang.
// http://adriansampson.net/blog/clangpass.html
static void registerClassXCHGInlinePass(const PassManagerBuilder &,
                                             legacy::PassManagerBase &PM) {
  PM.add(new ClassXCHGInlinePass());
}

static RegisterStandardPasses
    RegisterMyPass(PassManagerBuilder::EP_EarlyAsPossible,
                   registerClassXCHGInlinePass);
