// identify compiler family via macros
#include <stdio.h>
#include <stdlib.h>

int main(void){

char* compiler_id;

#if defined(__ibmxl__)
compiler_id = "ibmxl";
#elif defined(__INTEL_COMPILER) || defined(__INTEL_LLVM_COMPILER)
// the classic and llvm intel compilers are ABI compatiable, so here we treat them the same.
compiler_id = "intel";
#elif defined(__NVCOMPILER)
compiler_id = "nvidia";
#elif defined(_CRAYC)
compiler_id = "cray";
#elif defined(__FCC_VERSION)
compiler_id = "fujitsu";
#elif defined(_MSC_VER)
compiler_id = "msvc";
#elif defined(__WATCOMC__)
compiler_id = "watcom";
#elif defined(__clang__)
// should be second last because other compilers may define __clang__
compiler_id = "clang";
#elif defined(__GNUC__)
// should be last because other compilers may define __GNUC__
compiler_id = "gnu";
#else
fprintf(stderr, "could not identify compiler");
return EXIT_FAILURE;
#endif

printf("%s\n", compiler_id);

return EXIT_SUCCESS;

}
