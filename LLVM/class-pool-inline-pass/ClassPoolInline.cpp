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
struct ClassPoolInlinePass : public ModulePass {
  static char ID;
  ClassPoolInlinePass() : ModulePass(ID) {}

  bool runOnModule(Module &M) override {

    /*
     * This pass replaces optnone with alwaysinline attribute for WritablePacket::pool_prepare_data_burst
     */

    /* RX Burst Function */
    std::string poolPrepareFuncName = "pool_prepare_data_burst";
    bool change = false;

    errs() << "Searching for the pool_prepare_data_burst function ...\n";
    for (auto &F : M) {
      std::string funcName = demangle(F.getName().data());
      auto found_func = funcName.find(poolPrepareFuncName);
      if ((found_func != std::string::npos)) {
        if (F.hasFnAttribute(llvm::Attribute::NoInline)) {
          errs() << "Removing noinline attribute...\n";
          F.removeFnAttr(llvm::Attribute::NoInline);
          change = true;
        }
        if (F.hasFnAttribute(llvm::Attribute::OptimizeNone)) {
          errs() << "Removing optnone attribute...\n";
          F.removeFnAttr(llvm::Attribute::OptimizeNone);
          change = true;
        }
        if (!F.hasFnAttribute(llvm::Attribute::AlwaysInline)) {
          errs() << "Adding alwaysinline attribute...\n";
          F.addFnAttr(llvm::Attribute::AlwaysInline);
          change = true;
        }
      }
    }

    /*change*/
    return change;
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

char ClassPoolInlinePass::ID = 0;

// Make the pass visible to opt.
static RegisterPass<ClassPoolInlinePass> X("inline-pool",
                                                "ClassPoolInline");

// Automatically enable the pass in clang.
// http://adriansampson.net/blog/clangpass.html
static void registerClassPoolInlinePass(const PassManagerBuilder &,
                                             legacy::PassManagerBase &PM) {
  PM.add(new ClassPoolInlinePass());
}

static RegisterStandardPasses
    RegisterMyPass(PassManagerBuilder::EP_EarlyAsPossible,
                   registerClassPoolInlinePass);
