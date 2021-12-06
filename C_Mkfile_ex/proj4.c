#include "proj4.h"
#include <math.h>
#include <stdio.h>

//Naive Monte Calro Integration
double* integ1(unsigned int size){
	//Allocating memory to result pointer at heap memory
	//to store result values even if we exit this function
	double *result = (double *)malloc(size * sizeof(double));
	srand(time(NULL));

	//Using multi-threads
#pragma omp parallel for
	for (int n = 0; n<size; n++){
	//Random vairable theta and r	
		double r = (double)(rand()%10000)/10000;
		
		//Compute function with random r values
		double exp = 1/(sqrt(1-r));
		result[n]= exp;
		}
	return result; 
}

//Monte Carlo Integration with importance sampling.
double* integ2(unsigned int size){
	double *result = (double *)malloc(size * sizeof(double));
	srand(time(NULL));
#pragma omp parallel for
	for (int n = 0; n < size; n++){
		char det = 0;
		while( det == 0){
			//Acception rejection method
			double r = (double)(rand()%10000)/10000;
			double y = (-1)* ((double)(rand()%10000)/10000);
			double f = (-1) * sqrt(1-r);
			if( y >= f)
				det = 1;
		}
		double exp =2;
		result[n] = exp;
	}	
	return result;
}


//Integ3 : Antithetic variates
double* integ3(unsigned int size){
	//Allocating memory to result pointer at heap memory
	//to store result values even if we exit this function
	double *result = (double *)malloc(size * sizeof(double));
	srand(time(NULL));

	//Using multi-threads
#pragma omp parallel for
	for (int n = 0; n<size; n++){
	//Random variable r (in fact, this is the value 1 - r)
		double r = (double)(rand()%10000)/10000;
		r = 1 - r;
		//to avoid r =1 that makes value infinity
		r = r - 0.0001;
		//Compute function with random r values
		double exp = 1/(sqrt(1-r));
		result[n]= exp;
		}
	return result; 
}
