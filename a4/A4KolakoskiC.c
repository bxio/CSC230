/* File: A4CSC230.c */
/* Bill Xiong V00737042 */
/*Summer 2012 - CSC 230 - Assignment 4 */

#include <stdio.h>
#include <stdlib.h>                    /*For "malloc", "exit" functions. */

#define MAXRUNS 50
int i,j,k;


int AppendKseq(int Kseq[],int index,int *Num1){
	return index;
}

void PrintKseq(int Kseq[],int index){
	for(i=1;i<=index;i++){
		for(j=0;j<10;j++){
			printf("%d	",Kseq[i]);
		}
		printf("\n");
	}
}

int main(void){
	printf("Bill Xiong V00737042\nKolakoski Program starts\n");


	/*Init*/
	int Kseq[1000];
	/*Kseq[0] is not used*/
	Kseq[1] = 1; int Num1 = 1;
	Kseq[2] = 2;
	int index = 3;
	int n=2;

	for(n=2;n<MAXRUNS;n++){
		for(i = 1; i<=Kseq[n];i++){
			index = AppendKseq(&Kseq,index,&Num1)
		}
	}


	/*
	Let Kseq be the the the array to contain the Kolakoski sequence 
	Initialize the beginning elements as:
		Kseq[0] is not used 
		Kseq[1] = 1 
		Kseq[2] = 2
	Let n be the number of “run” steps in producing the sequence
	where n ranges from 2 to infinity. 
	In a practical program, n should range from 2 
	to a given maximum number of “runs”, here denoted by MAXRUNS
		for (n=2 to MAXRUNS)
		{
			for(i=1 to i= Kseq[n])
			{
				append the element (1+(n mod 2)) to Kseq
			}
		}


	*/



	printf("Kolakoski sequence of length %d with %d Runs",index,MAXRUNS);
	printf("Number of 1's is = %d\nNumber of 2's is = %d",Num1,(index-Num1));
	PrintKseq(Kseq[],index);
	printf("Kolakoski Program ends.");

	return (0);
}