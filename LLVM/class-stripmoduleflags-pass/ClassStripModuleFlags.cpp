/* 
 * Removing Module Flags
 * 
 * Copyright (c) 2020, Alireza Farshin, KTH Royal Institute of Technology - All Rights Reserved
 * 
 */

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

using namespace llvm;

namespace {
struct ClassStripModuleFlagsPass : public ModulePass {
  static char ID;
  ClassStripModuleFlagsPass() : ModulePass(ID) {}

  bool runOnModule(Module &M) override {

    /*
     * This pass removes llvm.module.flags,
     * which contains ThinLTO, EnableSplitLTOUnit, and LTOPostLink.
     * We do this to avoid linker error while building the binary.
     */
    auto flags = M.getModuleFlagsMetadata();

    if (flags) {
      errs() << "Removing " << flags->getName() << " ... "
             << "\n";

      for (auto f = flags->op_begin(); f != flags->op_end(); f++) {
        std::string type_str;
        llvm::raw_string_ostream rso(type_str);
        (*f)->print(rso);
        if ((*f)->getNumOperands() == 3) {
          errs() << "RM " << *(*f)->getOperand(1) << "\n";
        } else {
          errs() << "RM " << rso.str() << "\n";
        }
      }
      /* Erasing */
      flags->eraseFromParent();
      /*made change*/
      return true;
    } else {
      errs() << "No flags found!"
             << "\n";
      /*no change*/
      return false;
    }
  }
};
} // namespace

char ClassStripModuleFlagsPass::ID = 0;

// Make the pass visible to opt.
static RegisterPass<ClassStripModuleFlagsPass> X("strip-module-flags",
                                                 "ClassStripModuleFlags");

// Automatically enable the pass in clang.
// http://adriansampson.net/blog/clangpass.html
static void registerClassStripModuleFlagsPass(const PassManagerBuilder &,
                                              legacy::PassManagerBase &PM) {
  PM.add(new ClassStripModuleFlagsPass());
}

static RegisterStandardPasses
    RegisterMyPass(PassManagerBuilder::EP_EarlyAsPossible,
                   registerClassStripModuleFlagsPass);
