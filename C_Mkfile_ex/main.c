#include "proj4.h"
#include <stdio.h>
#include <time.h>
#ifndef NULL
#define NULL (void *)0
#endif

int main(int argc, char** argv){

	//File stream to get output file's data from argument
	FILE * fp;

	if(argc != 2){
		if( (fp = fopen("output.csv","w")) == NULL){
			fprintf(stderr, "File Open eror : output.csv \n");
			return(EXIT_FAILURE);
		}
	}
	else{
		if( (fp = fopen(argv[1],"w")) == NULL){
			fprintf(stderr, "File Open error : %s\n",argv[1]);
			return(EXIT_FAILURE);
		}
	}
	
	//Variables below are store timestamp value
	clock_t start1, start2, end1, end2, start3, end3;
	//time1, time2, time3 for total run time, it changes to run time each step.
	double time1, time2, time3;

	//Run with first way (navie Monte Carlo method)
	start1 = clock();	
	double *result1=integ1(1000000);
	end1 = clock();
	time1 = (float)(end1-start1)/(CLOCKS_PER_SEC/1000);

	//Run with second way (Importance sampling)
	start2 = clock();
	double *result2= integ2(1000000);
	end2 = clock();
	time2 = (float)(end2-start2)/(CLOCKS_PER_SEC/1000);

	//Run with third way (Antithetic variates)
	start3 = clock();	
	double *result3=integ3(1000000);
	end3 = clock();
	time3 = (float)(end3-start3)/(CLOCKS_PER_SEC/1000);

	//change time1, tieme2, time3 for run time each step by dividing 1000000(total steps)
	time1 = time1/1000000;
	time2= time2/1000000;
	time3 = time3/1000000;

	//get average of results
	double avg1=mean(result1, 1000000);
        double avg2=mean(result2, 1000000);
	double avg3=mean(result3, 1000000);

	//get standard deviation of results
	double sd1=sd(result1, avg1, 1000000);
	double sd2=sd(result2, avg2, 1000000);
	double sd3=sd(result3, avg3 ,1000000);

	printf("Average of method 1 : %lf\n", avg1);
	printf("Average of method 2 : %lf\n", avg2);
	printf("Avgerage of method 3 : %lf\n", avg3);
	printf("SD of method 1: %lf\n", sd1);
	printf("SD of method 2 : %lf\n", sd2);
	printf("SD of method 3 : %lf\n", sd3);

	//Comparing Performance of two Monte_Carlo methods
	printf("First method : integrate from uniform distribution.\n");
	printf("Second method : integrate using importance sampling.\n");
	//1. Relatively efficiency:
	printf("Relatively Efficiency method1/method3 : %lf\n", pow(sd1,2)/pow(sd3,2));	
	//2. Laboriousness
	printf("Laboriousness for method1 : %lf\n",time1*pow(sd1,2));
	printf("Laboriousness for method2 : %lf\n", time2*pow(sd2,2));
	printf("Laboriousness for method3 : %lf\n", time3*pow(sd3,2));
	
	//Freeing allocated memory on heap.
	//and set Null to those pointers to prevent dangling pointer.
	free(result1);
	free(result2);
	free(result3);
	result1=NULL;
	result2=NULL;
	result3=NULL;

	//From count 10 to 1000000, with increment stride, run way1 (integ 1) function
	//Stride becomes 10^n when it is in range between 10^n to 10^(n+1)
	unsigned int stride=10;
	for (unsigned int n=10; n<1000001; n= n+stride){
		double avg_list[100];
		for (int k=0; k<100; k++){
			double* tmp_result = integ3(n);
			avg_list[k] = mean(tmp_result,n);
			free(tmp_result);
			tmp_result=NULL;
		}
		double tmp_avg = mean(avg_list,100);
		fprintf(fp, "%u,%lf\n",n,tmp_avg);
		if(n==10 || n==100 || n==1000 || n==10000 || n==100000 || n==1000000){
			fprintf(stdout,"%u,%lf\n",n,tmp_avg);
			stride =n;
		}
	}

	fclose(fp);
	return(EXIT_SUCCESS);
	
}
