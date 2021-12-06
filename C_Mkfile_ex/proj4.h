#ifndef _PROJ3_H
#define _RROJ3_H

#include <math.h>
#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#include <time.h>
extern double* integ1(unsigned int size);
extern double* integ2(unsigned int size);
extern double* integ3(unsigned int size);
extern double mean(double *array, int size);
extern double sd(double *array,double avg, int size);
#endif
