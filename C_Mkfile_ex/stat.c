#include <math.h>
#include "proj4.h"

//SSE intrinsics
#if defined(_MSC_VER)
#include <intrin.h>
#elif defined(__GNUC__) && (defined(__x86_64__) || defined(__i386__))
#include <immintrin.h>
#include <x86intrin.h>
#endif

double mean(double *array, int size){
    //Give four zeros to vector, sum_vec
    __m256d sum_vec = _mm256_set1_pd(0.0);
    for(unsigned int i = 0; i< (size/ 4 *4) ; i+=4){
	//in each step, load four double values from array and do elementwise add with sum_vec
	sum_vec = _mm256_add_pd(sum_vec, _mm256_loadu_pd(array + i));
    }    
    double sum_arr[4];
    //We cannot use sum_vec to compute total sum, so store it to double type array with four elements
    _mm256_storeu_pd(sum_arr, sum_vec);
    double result= 0;
    result += (sum_arr[0] + sum_arr[1] + sum_arr[2] + sum_arr[3]);
    //tail case
    for(unsigned int i = (size/4 *4); i<size; i++){
        result += array[i];
    }
    result = result/size;
    return result;
}

double sd(double *array, double avg, int size){
    double sum_arr[4];
    double result = 0;
    //Initialize each vector's element with four double elements
    __m256d avg_vec = _mm256_set1_pd(avg);
    __m256d sum_vec = _mm256_set1_pd(0.0);

    //Compute Variance
    for(unsigned int i=0; i<(size/4 *4); i+=4){
        __m256d tmp_vec = _mm256_loadu_pd(array+i);
	tmp_vec = _mm256_sub_pd(tmp_vec, avg_vec);
	tmp_vec = _mm256_mul_pd(tmp_vec, tmp_vec);
	sum_vec = _mm256_add_pd(tmp_vec, sum_vec);
    }
    
    _mm256_storeu_pd(sum_arr,sum_vec);
    result += (sum_arr[0] + sum_arr[1] + sum_arr[2] + sum_arr[3]);
    
    //tail case
    for(unsigned int i = (size/4 *4); i<size ;i++){
        result = result + pow((array[i] -avg), 2);
        }

    result = sqrt(result/size);
    return result;



    
}
