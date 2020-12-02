/* 
 * Reordering Packet class of FastClick
 * 
 * Copyright (c) 2020, Alireza Farshin, KTH Royal Institute of Technology - All Rights Reserved
 * 
 */

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include <algorithm>
#include <cxxabi.h>
#include <fstream>
#include <string>
#include <unordered_map>
#include <vector>

using namespace llvm;

static cl::opt<std::string> ElementListFilename(
    "element-list-filename",
    cl::desc(
        "Specify the filename that contains the name of the used elements."),
    cl::value_desc("filename"), cl::Optional, cl::init("-"));

namespace {

/*
 * This pass reoders the variables in the Packet class of FastClick.
 */

struct ClassHandpickPass : public ModulePass {
  static char ID;
  ClassHandpickPass() : ModulePass(ID) {}

  bool runOnModule(Module &M) override {

    /* Reoder AllAnno struct */
    errs() << "Reordering AllAnno Struct"
           << "\n";
    auto res_1 = reorderStructAllAnno(M, ElementListFilename);

    /* Reorder class.Packet */
    errs() << "Reordering Class Packet"
           << "\n";
    auto res_2 = reorderClassPacket(M, ElementListFilename);

    /* return true if changed */
    return (res_1 || res_2);
  }

private:
  /*
   * Reorder the elements of Struct AllAnno based on
   * the number of accesses
   */
  bool reorderStructAllAnno(Module &M, std::string ElementListFilename) {
    /* The target class/struct */
    std::string className = "class.Packet";
    std::string structName = "struct.Packet::AllAnno";
    uint64_t cur_index;

    /* Reading the elementsFile and save the elements in a vector */
    std::vector<std::string> elements;
    std::string str;

    std::vector<uint64_t> accessed_indices;

    /* Check the arguments */
    if (ElementListFilename != "-") {
      /* Opening the elementsFile */
      std::ifstream elementsFile(ElementListFilename);
      if (!elementsFile) {
        errs() << "error: " << ElementListFilename
               << ": cannot open the file!\n";
        exit(-1);
      }

      while (std::getline(elementsFile, str)) {
        if (str.size() > 0)
          elements.push_back(str);
      }

      /* Closing the elementsFile */
      elementsFile.close();

      /* Printing the elements */
      errs() << "Searching the following Click elements:\n";
      for (auto const &i : elements) {
        errs() << i << "\n";
      }
    } else {
      errs() << "Searching all Click elements\n";
    }

    /* Find the accesses made to the class/struct */
    size_t res;
    if (elements.size() != 0)
      res = findAccessedIndicesStructAllAnno(M, elements, className, structName,
                                             accessed_indices, cur_index);
    else
      res = findAccessedIndicesStructAllAnno(M, className, structName,
                                             accessed_indices, cur_index);

    /* Check whether there is any access */
    if (res == 0) {
      errs() << "No access to the struct/class!\n";
      /* The module is not changed! */
      return false;
    }

    errs() << "#References: " << res << "\n";

    /* Order accesses based on the repetition */
    OrderBasedOnTheRepetition(accessed_indices);

    /*
     * Find the maximum number of variables in the class/struct
     */
    uint64_t max_indices;
    for (auto ST : M.getIdentifiedStructTypes()) {
      if (ST->getName() == structName) {
        max_indices = ST->getNumElements();
        errs() << "Before Pass:\n" << *ST << "\n";
        break;
      }
    }

    /*
     * Add the unused indices at the end
     * We do this to avoid removing the unused variables.
     * TODO: Ignore the unused variables.
     */

    for (auto i = 0; i < max_indices; i++) {
      if (!(std::find(accessed_indices.begin(), accessed_indices.end(), i) !=
            accessed_indices.end())) {
        accessed_indices.push_back(i);
      }
    }


    /* Print the ordered indices */
    errs() << "Accesses: ";
    for(auto idx : accessed_indices)
      errs() << idx << " ";
    errs() << "\n";

    /* Find the class/struct in the module and handpick the variables */

    std::vector<Type *> new_elements;
    StructType *markedST =
        modifyClassStructure(M, structName, accessed_indices, new_elements);

    if (markedST == NULL) {
      errs() << "Could not find the class!!\n";
      /* The module is not changed! */
      return false;
    }

    /* Fixing the references to the class */

    uint64_t fixed = fixClassReferencesStructAllAnno(M, className, accessed_indices, cur_index);
    errs() << "Fixed " << fixed << " references!" << "\n";

    /* Change the Struct Type */

    markedST->setBody(new_elements);

    errs() << "After Pass:\n" << *markedST << "\n";

    return true;
  }

  /*
   * Find the accesses to different variables of class/struct
   * in the functions relevant to the used Click elements.
   */
  size_t findAccessedIndicesStructAllAnno(Module &M,
                                          std::vector<std::string> &el,
                                          std::string cn, std::string sn,
                                          std::vector<uint64_t> &idx_vec,
                                          uint64_t &cr_idx) {

    /* Find the current index of the AllAnno struct in Packet class */
    for (auto ST : M.getIdentifiedStructTypes()) {
      if (ST->getName() == cn) {
        errs() << ST->getName() << "\n";
        ArrayRef<Type *> elements = ST->elements();
        auto numElements = ST->getNumElements();
        auto name = ST->getName().str();
        auto elements_vec = elements.vec();

        for (auto i = 0; i < elements_vec.size(); i++) {
          if (elements_vec[i]->isStructTy()) {
            if (elements_vec[i]->getStructName() == sn) {
              cr_idx = i;
              errs() << "Found AllAnno, located at index " << cr_idx << "\n";
            }
          }
        }
      }
    }
    for (auto &F : M) {
      std::string funcName = demangle(F.getName().data());

      /*
       * Check whether the function name contains any elements
       * TODO: Since embedclick is optimized, we could apply this on the whole
       * module
       */
      std::size_t found;

      for (auto const &e : el) {
        found = funcName.find(e);
        if (found != std::string::npos) {
          for (auto &BB : F) {
            for (auto &I : BB) {
              /* Find the GetElementPtr Instructions */
              if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(&I)) {
                /* Check whether it is accesing a struct/class called cn (e.g.,
                 * class.Packet */
                if (GEPI->getSourceElementType()->isStructTy()) {
                  if (GEPI->getSourceElementType()->getStructName() == cn) {
                    /*
                     * Find the accessed index of AllAnno
                     */
                    auto idx = GEPI->idx_begin() + 1;
                    Value *val = idx->get();
                    /* Check whether the index is a constant integer */
                    if (llvm::ConstantInt *CI =
                            dyn_cast<llvm::ConstantInt>(val)) {
                      /*
                       * TODO: Check the type of the next instruction
                       * load or store
                       * we can remove the accesses which are not load
                       */
                      if (CI->getZExtValue() == cr_idx) {
                        idx++;
                        Value *val = idx->get();
                        if (llvm::ConstantInt *CI_2 =
                                dyn_cast<llvm::ConstantInt>(val)) {
                          idx_vec.push_back(CI_2->getZExtValue());
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          /*
           * There is not need to check other elements
           * Since we have already analayzed the function.
           */
          break;
        }
      }
    }

    return idx_vec.size();
  }

  /*
   * Find the accesses to different variables of class/struct
   * in all of the functions.
   */
  size_t findAccessedIndicesStructAllAnno(Module &M, std::string cn,
                                          std::string sn,
                                          std::vector<uint64_t> &idx_vec,
                                          uint64_t &cr_idx) {

    /* Find the current index of the AllAnno struct in Packet class */
    for (auto ST : M.getIdentifiedStructTypes()) {
      if (ST->getName() == cn) {
        errs() << ST->getName() << "\n";
        ArrayRef<Type *> elements = ST->elements();
        auto numElements = ST->getNumElements();
        auto name = ST->getName().str();
        auto elements_vec = elements.vec();

        for (auto i = 0; i < elements_vec.size(); i++) {
          if (elements_vec[i]->isStructTy()) {
            if (elements_vec[i]->getStructName() == sn) {
              cr_idx = i;
              errs() << "Found AllAnno, located at index " << cr_idx << "\n";
            }
          }
        }
      }
    }
    for (auto &F : M) {
      for (auto &BB : F) {
        for (auto &I : BB) {
          /* Find the GetElementPtr Instructions */
          if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(&I)) {
            /* Check whether it is accesing a struct/class called cn (e.g.,
             * class.Packet */
            if (GEPI->getSourceElementType()->isStructTy()) {
              if (GEPI->getSourceElementType()->getStructName() == cn) {
                /*
                 * Find the accessed index of AllAnno
                 */
                auto idx = GEPI->idx_begin() + 1;
                Value *val = idx->get();
                /* Check whether the index is a constant integer */
                if (llvm::ConstantInt *CI = dyn_cast<llvm::ConstantInt>(val)) {
                  /*
                   * TODO: Check the type of the next instruction
                   * load or store
                   * we can remove the accesses which are not load
                   */
                  if (CI->getZExtValue() == cr_idx) {
                    idx++;
                    Value *val = idx->get();
                    if (llvm::ConstantInt *CI_2 =
                            dyn_cast<llvm::ConstantInt>(val)) {
                      idx_vec.push_back(CI_2->getZExtValue());
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    return idx_vec.size();
  }

  /*
   * Fixing all references to the AllAnno struct in the Class Packet and its
   * derived classes WritablePacket and PacketBatch classes are derived from the
   * Packet class
   */
  uint64_t fixClassReferencesStructAllAnno(
      Module &M, std::string cn, std::vector<uint64_t> &idx_vec,
      uint64_t cr_idx, std::string dcn_1 = "class.WritablePacket",
      std::string dcn_2 = "class.PacketBatch") {

    uint64_t fixed_accesses=0;
    /* Similar to the findAccessedIndicesStructAllAnno function */
    for (auto &F : M) {
      for (auto &BB : F) {
        for (auto &I : BB) {
          if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(&I)) {
            if (GEPI->getSourceElementType()->isStructTy()) {
              if ((GEPI->getSourceElementType()->getStructName() == cn) &&
                  (GEPI->getNumIndices() >= 2)) {
                /* We know that accesses to class.Packet are happening in the
                 * 2nd index */
                auto idx = GEPI->idx_begin() + 1;

                Value *val = idx->get();
                if (llvm::ConstantInt *CI = dyn_cast<llvm::ConstantInt>(val)) {
                  if (CI->getZExtValue() == cr_idx) {
                    idx++;
                    Value *val = idx->get();
                    if (llvm::ConstantInt *CI_2 =
                            dyn_cast<llvm::ConstantInt>(val)) {
                      auto NI = GEPI->getNextNonDebugInstruction();
                      /*Change the index*/
                      std::pair<bool, int> result =
                          findInVector<uint64_t>(idx_vec, CI_2->getZExtValue());
                      /* We know that accesses to struct.Packet::AllAnno are
                       * happening in the 3rd index */
                      GEPI->setOperand(
                          3, ConstantInt::get(Type::getInt32Ty(I.getContext()),
                                              result.second));
                      fixed_accesses++;
                    }
                  }
                } else {
                  errs() << "Could not cast as a constant integer!"
                         << "\n";
                }
              } /* dcn_1 should be the class.WritablePacket */
              else if ((GEPI->getSourceElementType()->getStructName() ==
                        dcn_1) &&
                       (GEPI->getNumIndices() >= 3)) {
                /* We know that accesses to class.WritablePacket are happening
                 * in the 3rd index */
                auto idx = GEPI->idx_begin() + 2;

                Value *val = idx->get();
                if (llvm::ConstantInt *CI = dyn_cast<llvm::ConstantInt>(val)) {
                  if (CI->getZExtValue() == cr_idx) {
                    idx++;
                    Value *val = idx->get();
                    if (llvm::ConstantInt *CI_2 =
                            dyn_cast<llvm::ConstantInt>(val)) {
                      auto NI = GEPI->getNextNonDebugInstruction();
                      /*Change the index*/
                      std::pair<bool, int> result =
                          findInVector<uint64_t>(idx_vec, CI_2->getZExtValue());
                      /* We know that accesses to class.WritablePacket are
                       * happening in the 4th index */
                      GEPI->setOperand(
                          4, ConstantInt::get(Type::getInt32Ty(I.getContext()),
                                              result.second));
                      fixed_accesses++;
                    }
                  }
                } else {
                  errs() << "Could not cast as a constant integer!"
                         << "\n";
                }
              } /* dcn_2 should be the class.PacketBatch */
              else if ((GEPI->getSourceElementType()->getStructName() ==
                        dcn_2) &&
                       (GEPI->getNumIndices() >= 4)) {
                /* We know that accesses to class.PacketBatch are happening in
                 * the 4th index */
                auto idx = GEPI->idx_begin() + 3;

                Value *val = idx->get();
                if (llvm::ConstantInt *CI = dyn_cast<llvm::ConstantInt>(val)) {
                  if (CI->getZExtValue() == cr_idx) {
                    idx++;
                    Value *val = idx->get();
                    if (llvm::ConstantInt *CI_2 =
                            dyn_cast<llvm::ConstantInt>(val)) {
                      auto NI = GEPI->getNextNonDebugInstruction();
                      /*Change the index*/
                      std::pair<bool, int> result =
                          findInVector<uint64_t>(idx_vec, CI_2->getZExtValue());
                      /* We know that accesses to class.PacketBatch are
                       * happening in the 5th index */
                      GEPI->setOperand(
                          5, ConstantInt::get(Type::getInt32Ty(I.getContext()),
                                              result.second));
                      fixed_accesses++;
                    }
                  }
                } else {
                  errs() << "Could not cast as a constant integer!"
                         << "\n";
                }
              }
            }
          }
        }
      }
    }
    return fixed_accesses;
  }

  /*
   * Reorder the elements of Class Packet based on
   * the number of accesses
   */
  bool reorderClassPacket(Module &M, std::string ElementListFilename) {
    /* The target class/struct */
    std::string className = "class.Packet";

    /* Reading the elementsFile and save the elements in a vector */
    std::vector<std::string> elements;
    std::string str;

    std::vector<uint64_t> accessed_indices;

    /* Check the arguments */
    if (ElementListFilename != "-") {
      /* Opening the elementsFile */
      std::ifstream elementsFile(ElementListFilename);
      if (!elementsFile) {
        errs() << "error: " << ElementListFilename
               << ": cannot open the file!\n";
        exit(-1);
      }

      while (std::getline(elementsFile, str)) {
        if (str.size() > 0)
          elements.push_back(str);
      }

      /* Closing the elementsFile */
      elementsFile.close();

      /* Printing the elements */
      errs() << "Searching the following Click elements:\n";
      for (auto const &i : elements) {
        errs() << i << "\n";
      }
    } else {
      errs() << "Searching all Click elements\n";
    }

    /* Find the accesses made to the class/struct */
    size_t res;
    if (elements.size() != 0)
      res = findAccessedIndicesClassPacket(M, elements, className,
                                           accessed_indices);
    else
      res = findAccessedIndicesClassPacket(M, className, accessed_indices);

    /* Check whether there is any access */
    if (res == 0) {
      errs() << "No access to the struct/class!\n";
      /* The module is not changed! */
      return false;
    }

    errs() << "#References: " << res << "\n";

    /* Order accesses based on the repetition */
    OrderBasedOnTheRepetition(accessed_indices);

    /*
     * Find the maximum number of variables in the class/struct
     */
    uint64_t max_indices;
    for (auto ST : M.getIdentifiedStructTypes()) {
      if (ST->getName() == className) {
        max_indices = ST->getNumElements();
        errs() << "Before Pass:\n" << *ST << "\n";
        break;
      }
    }

    /*
     * Add the unused indices at the end
     * We do this to avoid removing the unused variables.
     * TODO: Ignore the unused variables.
     */

    for (auto i = 0; i < max_indices; i++) {
      if (!(std::find(accessed_indices.begin(), accessed_indices.end(), i) !=
            accessed_indices.end())) {
        accessed_indices.push_back(i);
      }
    }


    std::pair<bool, int> result =
                      findInVector<uint64_t>(accessed_indices, 0);
    errs() << "New index of 0 is: " << result.second << "\n";


    /* Print the ordered indices */
    errs() << "Accesses: ";
    for(auto idx : accessed_indices)
      errs() << idx << " ";
    errs() << "\n";

    /* Find the class/struct in the module and handpick the variables */

    std::vector<Type *> new_elements;
    StructType *markedST =
        modifyClassStructure(M, className, accessed_indices, new_elements);

    if (markedST == NULL) {
      errs() << "Could not find the class!!\n";
      /* The module is not changed! */
      return false;
    }

    /* Fixing the references to the class */

    uint64_t fixed = fixClassReferencesClassPacket(M, className, accessed_indices);
    errs() << "Fixed " << fixed << " references!" << "\n";

    /* Change the Struct Type */

    markedST->setBody(new_elements);

    errs() << "After Pass:\n" << *markedST << "\n";

    /*made change*/
    return true;
  }
  /*
   * Find the accesses to different variables of class/struct
   * in the functions relevant to the used Click elements.
   */
  size_t findAccessedIndicesClassPacket(Module &M, std::vector<std::string> &el,
                                        std::string cn,
                                        std::vector<uint64_t> &idx_vec) {

    for (auto &F : M) {
      std::string funcName = demangle(F.getName().data());

      /*
       * Check whether the function name contains any elements
       * TODO: Since embedclick is optimized, we could apply this on the whole
       * module
       */
      std::size_t found;

      for (auto const &e : el) {
        found = funcName.find(e);
        if (found != std::string::npos) {
          for (auto &BB : F) {
            for (auto &I : BB) {
              /* Find the GetElementPtr Instructions */
              if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(&I)) {
                /* Check whether it is accesing a struct/class called cn
                 * (e.g., class.Packet */
                if (GEPI->getSourceElementType()->isStructTy()) {
                  if (GEPI->getSourceElementType()->getStructName() == cn) {
                    /*
                     * Find the accessed index
                     * It is usually the second one
                     * e.g., getelementptr inbounds %class.Packet,
                     * %class.Packet* %0, i64 0, i32 2 which is accesing the
                     * 3rd (starting from 0 -> i32 2) variable
                     */
                    auto idx = GEPI->idx_begin() + 1;
                    Value *val = idx->get();
                    /* Check whether the index is a constant integer */
                    if (llvm::ConstantInt *CI =
                            dyn_cast<llvm::ConstantInt>(val)) {
                      /*
                       * TODO: Check the type of the next instruction
                       * load or store
                       * we can remove the accesses which are not load
                       */

                      idx_vec.push_back(CI->getZExtValue());
                    }
                  }
                }
              }
            }
          }

          /*
           * There is not need to check other elements
           * Since we have already analayzed the function.
           */
          break;
        }
      }
    }

    return idx_vec.size();
  }

  /*
   * Find the accesses to different variables of class/struct
   * in all of the functions.
   */
  size_t findAccessedIndicesClassPacket(Module &M, std::string cn,
                                        std::vector<uint64_t> &idx_vec) {

    for (auto &F : M) {
      for (auto &BB : F) {
        for (auto &I : BB) {
          /* Find the GetElementPtr Instructions */
          if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(&I)) {
            /* Check whether it is accesing a struct/class called cn (e.g.,
             * class.Packet */
            if (GEPI->getSourceElementType()->isStructTy()) {
              if (GEPI->getSourceElementType()->getStructName() == cn) {
                /*
                 * Find the accessed index
                 * It is usually the second one
                 * e.g., getelementptr inbounds %class.Packet,
                 * %class.Packet* %0, i64 0, i32 2 which is accesing the 3rd
                 * (starting from 0 -> i32 2) variable
                 */
                auto idx = GEPI->idx_begin() + 1;
                Value *val = idx->get();
                /* Check whether the index is a constant integer */
                if (llvm::ConstantInt *CI = dyn_cast<llvm::ConstantInt>(val)) {
                  /*
                   * TODO: Check the type of the next instruction
                   * load or store
                   * we can remove the accesses which are not load
                   */

                  idx_vec.push_back(CI->getZExtValue());
                }
              }
            }
          }
        }
      }
    }

    return idx_vec.size();
  }

  StructType *modifyClassStructure(Module &M, std::string cn,
                                   std::vector<uint64_t> &idx_vec,
                                   std::vector<Type *> &new_el) {

    StructType *markedST;
    for (auto ST : M.getIdentifiedStructTypes()) {
      if (ST->getName() == cn) {

        ArrayRef<Type *> elements = ST->elements();
        auto numElements = ST->getNumElements();
        auto name = ST->getName().str();

        auto elements_vec = elements.vec();

        auto j = 0;
        for (auto j = 0; j < idx_vec.size(); j++) {
          auto idx = idx_vec[j];
          auto itr = elements.begin();
          while (idx > 0) {
            itr++;
            idx--;
          }
          new_el.push_back(*itr);
        }

        /* Keep the reference to the StructType for later */
        markedST = ST;
        break;
      }
    }
    return markedST;
  }

  /*
   * Fixing all references to the target class and its derived classes
   * WritablePacket and PacketBatch classes are derived from the target class,
   * i.e., Packet class.
   */
  uint64_t fixClassReferencesClassPacket(Module &M, std::string cn,
                                     std::vector<uint64_t> &idx_vec,
                                     std::string dcn_1 = "class.WritablePacket",
                                     std::string dcn_2 = "class.PacketBatch") {
    uint64_t fixed_accesses=0;
    /* Similar to the findAccessedIndicesClassPacket function */
    for (auto &F : M) {
      for (auto &BB : F) {
        for (auto &I : BB) {
          if (GetElementPtrInst *GEPI = dyn_cast<GetElementPtrInst>(&I)) {
            if (GEPI->getSourceElementType()->isStructTy()) {
              if ((GEPI->getSourceElementType()->getStructName() == cn) &&
                  (GEPI->getNumIndices() >= 2)) {
                /* We know that accesses to class.Packet are happening in the
                 * 2nd index */
                auto idx = GEPI->idx_begin() + 1;

                Value *val = idx->get();
                if (llvm::ConstantInt *CI = dyn_cast<llvm::ConstantInt>(val)) {
                  auto NI = GEPI->getNextNonDebugInstruction();
                  /*Change the index*/
                  std::pair<bool, int> result =
                      findInVector<uint64_t>(idx_vec, CI->getZExtValue());
                  /* We know that accesses to class.Packet are happening in
                   * the 2nd index */
                  GEPI->setOperand(
                      2, ConstantInt::get(Type::getInt32Ty(I.getContext()),
                                          result.second));
                    fixed_accesses++;
                } else {
                  errs() << "Could not cast as a constant integer!"
                         << "\n";
                }
              } /* dcn_1 should be the class.WritablePacket */
              else if ((GEPI->getSourceElementType()->getStructName() ==
                        dcn_1) &&
                       (GEPI->getNumIndices() >= 3)) {
                /* We know that accesses to class.WritablePacket are happening
                 * in the 3rd index */
                auto idx = GEPI->idx_begin() + 2;

                Value *val = idx->get();
                if (llvm::ConstantInt *CI = dyn_cast<llvm::ConstantInt>(val)) {

                  auto NI = GEPI->getNextNonDebugInstruction();
                  /*Change the index*/
                  std::pair<bool, int> result =
                      findInVector<uint64_t>(idx_vec, CI->getZExtValue());
                  /* We know that accesses to class.WritablePacket are
                   * happening in the 3rd index */
                  GEPI->setOperand(
                      3, ConstantInt::get(Type::getInt32Ty(I.getContext()),
                                          result.second));
                  fixed_accesses++;
                } else {
                  errs() << "Could not cast as a constant integer!"
                         << "\n";
                }
              } /* dcn_2 should be the class.PacketBatch */
              else if ((GEPI->getSourceElementType()->getStructName() ==
                        dcn_2) &&
                       (GEPI->getNumIndices() >= 4)) {
                /* We know that accesses to class.PacketBatch are happening in
                 * the 4th index */
                auto idx = GEPI->idx_begin() + 3;

                Value *val = idx->get();
                if (llvm::ConstantInt *CI = dyn_cast<llvm::ConstantInt>(val)) {

                  auto NI = GEPI->getNextNonDebugInstruction();
                  /*Change the index*/
                  std::pair<bool, int> result =
                      findInVector<uint64_t>(idx_vec, CI->getZExtValue());
                  /* We know that accesses to class.PacketBatch are happening
                   * in the 4th index */
                  GEPI->setOperand(
                      4, ConstantInt::get(Type::getInt32Ty(I.getContext()),
                                          result.second));
                  fixed_accesses++;
                } else {
                  errs() << "Could not cast as a constant integer!"
                         << "\n";
                }
              }
            }
          }
        }
      }
    }
    return fixed_accesses;
  }

  /* Demangle a function name */
  std::string demangle(const char *name) {
    int status = -1;

    std::unique_ptr<char, void (*)(void *)> res{
        abi::__cxa_demangle(name, NULL, NULL, &status), std::free};
    return (status == 0) ? res.get() : std::string(name);
  }

  /* The following functions are inspired by online resources */

  /* Remove the duplicates from a vector while keeping the order */
  template <typename T> size_t RemoveDuplicatesKeepOrder(std::vector<T> &vec) {
    std::set<T> seen;

    auto newEnd =
        std::remove_if(vec.begin(), vec.end(), [&seen](const T &value) {
          if (seen.find(value) != std::end(seen))
            return true;

          seen.insert(value);
          return false;
        });

    vec.erase(newEnd, vec.end());

    return vec.size();
  }

  /* Order the vector elements based on the number of repetitions */
  template <typename T> void OrderBasedOnTheRepetition(std::vector<T> &vec) {
    std::unordered_map<T, int> count;

    for (auto v : vec)
      count[v]++;
    std::sort(vec.begin(), vec.end(), [&](int a, int b) {
      return std::tie(count[a], a) > std::tie(count[b], b);
    });
    RemoveDuplicatesKeepOrder(vec);
  }

  template <typename T>
  std::pair<bool, int> findInVector(const std::vector<T> &vecOfElements,
                                    const T &element) {
    std::pair<bool, int> result;

    auto it = std::find(vecOfElements.begin(), vecOfElements.end(), element);

    if (it != vecOfElements.end()) {
      result.second = distance(vecOfElements.begin(), it);
      result.first = true;
    } else {
      result.first = false;
      result.second = -1;
    }
    return result;
  }
}; // namespace
} // namespace

char ClassHandpickPass::ID = 0;

/* Make the pass visible to opt */
static RegisterPass<ClassHandpickPass> X("handpick-packet-class",
                                         "ClassHandpickPass");

/*
 * Automatically enable the pass in clang.
 */
static void registerClassHandpickPass(const PassManagerBuilder &,
                                      legacy::PassManagerBase &PM) {
  PM.add(new ClassHandpickPass());
}

static RegisterStandardPasses
    RegisterMyPass(PassManagerBuilder::EP_EarlyAsPossible,
                   registerClassHandpickPass);
