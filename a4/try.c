#include <stdio.h>

#define MAXRUNS 50


int main(void){
	int i,j,k,count1,count2;
	printf("Bill Xiong V00737042\nKolakoski Program starts\n");

	/*Init*/
		int Kseq[1000];
		/*Kseq[0] is not used*/
		Kseq[1] = 1;
		Kseq[2] = 2;
		int n=2;

		for(n=2;n<MAXRUNS;n++){
			for(i = 1; i<=Kseq[n];i++){
				
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



	printf("Kolakoski sequence of length %d with %d Runs",1,MAXRUNS);
	printf("Number of 1's is = %d\nNumber of 2's is = %d",count1,count2);
	printf(">>Print the array here...\n");
	printf("Kolakoski Program ends.");

	return (0);
}