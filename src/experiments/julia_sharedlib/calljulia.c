#include <julia.h>
#include <stdio.h>

// This short program allocates two array in C, passes them to julia and writes results to one of them
// The output is then printed in C

int main(int argc, char *argv[])
{
    // Allocate two array in C
    double a[1];
    double b[1];
    a[0]=5.0;
    b[0]=1.0;
    
    // Init Julia
    jl_init_with_image("/Users/fgans/julia/julia-4d1b751dda/lib/julia", "sys.ji");
    JL_SET_STACK_BASE;
    
    // Define Array Type for 1D Array
    jl_value_t* array_type = jl_apply_array_type(jl_float64_type, 1);
    
    // Connect C-Arrays to julia Arrays
    jl_array_t *a_jl = jl_ptr_to_array_1d(array_type, a, 1, 0);
    jl_array_t *b_jl = jl_ptr_to_array_1d(array_type, b, 1, 0);
   

    // Load julia code
    jl_eval_string("include(\"square.jl\")");
    
    // Get function
    jl_function_t *func  = jl_get_function(jl_main_module, "square");
    if (func==NULL) {
        printf("Function not found!\n");
        return -1;
    }
    
    // Apply function
    jl_call2(func, (jl_value_t*)a_jl,(jl_value_t*)b_jl);
    if (jl_exception_occurred()) printf("%s \n", jl_typeof_str(jl_exception_occurred()));
    
    // Print result
    printf("%f squared is %f\n",a[0],b[0]);

    return 0;
}