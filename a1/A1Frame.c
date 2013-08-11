/* File: A1Frame.c */
/* Captain Bill Xiong V00737042 */
/*Summer 2012 - CSC 230 - Assignment 1 */
/*Read 2 dimensional matrices and their sizes until
	end of file. Compute the transpose. Test if a matrix
	is symmetrical, skew-symmetrical or orthogonal */

#include <stdio.h>
#define MAXSIZE 10

/* global variables and functions */
FILE *fpin;		/*pointers to input file*/

/**************************************************/

/*****THIS IS THE INITIAL FRAMEWORK DOING ONLY THE I/O IN MAIN ******/

/*==== Function RdRowSize: read the row size of a matrix from a file */ /*Input parameters:
     FILE *fp       pointer to input file
     int *Nrows     pointer to row size to be returned
  Output parameter:
     1 if okay, -1 if end of file found*/
int RdRowSize(FILE *fp, 
				int *Nrows) {
	fscanf(fpin,"%d",Nrows);
return *Nrows;
}

/*==== Procedure RdMatrix: read the elements of a matrix from a file */ 
/*Input parameters:
	FILE *fp						pointer to input file
	int Mat[MAXSIZE][MAXSIZE]	2D array for matrix
	int R,int C					row and column sizes
Output parameters:
     None */
void RdMatrix(FILE *fp,int Mat[MAXSIZE][MAXSIZE],int R,int C) { 
	int i,j,temp;
	for (i=0;i<R;i++) {		/*read matrix*/
		for (j=0;j<C;j++) {
			fscanf(fpin,"%d",&temp);
			Mat[i][j]=temp;
		}
	}
}

/*===== Procedure PrMat: print a 2-D matrix of integers row by row*/
/*Input parameters:
     int Mat[MAXSIZE][MAXSIZE]     the matrix to be printed
     int R, int C                  the row and column sizes
  Output parameter: None*/
void PrMat (int Mat[MAXSIZE][MAXSIZE],int R,int C) {
	int i,j;
	for (i=0;i<R;i++) {
		fprintf(stdout,"     ");
		for (j=0;j<C;j++) {
			fprintf(stdout,"%5d  ",Mat[i][j]);
		}
		fprintf(stdout,"\n");
	}
}

/*===== Procedure Transpose: construct the transpose of a matrix*/ 
/*Input parameters:
	int Mat[MAXSIZE][MAXSIZE]     the original matrix
	int Transp[MAXSIZE][MAXSIZE]  the transpose to be built
	int RM,int CM                 the original row and column sizes
	int *RT,int *CT               the transpose row and column sizes
Output parameter: 
	None*/
/*Given a matrix Mat and its dimensions in RM and CM,
  construct its transpose in Transp with dimensions RT and CT as in:
  The first parameter is a pointer to the input file (read the I/O documentation).
copy rows 0,1,...,CM-1 of Mat to cols 0,1,...,RT-1 of Transp */
void Transpose(int Mat[MAXSIZE][MAXSIZE],int Transp[MAXSIZE][MAXSIZE],int RM,int CM,int *RT,int *CT){ /* your code here */
	int i,j;
	*RT = CM;
	*CT = RM;
	for (i=0;i<RM;i++){
		for(j=0;j<CM;j++){
			Transp[j][i] = Mat[i][j];
		}
	}
	/*printf(">Transpose: %d x %d\n",*RT,*CT);*/
	
	
}

/*===== Function Symm: check for symmetric matrix*/ /*Input parameters:
     int Mat[MAXSIZE][MAXSIZE]     the  matrix
     int Transp[MAXSIZE][MAXSIZE]  its transpose
     int Size                      size
  Output parameter:
     0 for yes or -1 for no */
/*Given a square matrix, check if it is symmetric
  by comparing if Mat = Transp*/
int Symm(int Mat[MAXSIZE][MAXSIZE],int Transp[MAXSIZE][MAXSIZE],int Size) {
	int i,j,isSymm = 0;
	for(i=0;i<Size;i++){
		for(j=0;j<Size;j++){
			if(Mat[i][j] != Transp[i][j]){
				isSymm = -1;
			}
		}
	}
return isSymm;
}

/*===== Function SkewSymm: check for symmetric matrix*/ /*Input parameters:
     int Mat[MAXSIZE][MAXSIZE]     the  matrix
     int Transp[MAXSIZE][MAXSIZE]  its transpose
     int Size                      dimensions
  Output parameter:
     0 for yes or -1 for no */
/*Given a square matrix, check if it is skew-symmetric
  by comparing if Mat = - Transp*/
int SkewSymm(int Mat[MAXSIZE][MAXSIZE],int Transp[MAXSIZE][MAXSIZE],int Size) {
	int i,j,isSymm = 0;
	for(i=0;i<Size;i++){
		for(j=0;j<Size;j++){
			if(Mat[i][j] != (Transp[i][j]*-1)){
				isSymm = -1;
			}
		}
	}
return isSymm;
}

/*===== Function MatMult: multiply 2 matrices*/
/*Input parameters:
   int MatA[MAXSIZE][MAXSIZE]	matrix 1
   int MatB[MAXSIZE][MAXSIZE]	matrix 2
   int MatP[MAXSIZE][MAXSIZE]	resulting matrix
   int RowA,int ColA				size matrix 1
   int RowB,int ColB				size matrix 2
   int *RowP, int *ColP			size result
Output parameter:
    0 if okay, or -1 if incompatible sizes*/
int MatMult (int MatA[MAXSIZE][MAXSIZE],int MatB[MAXSIZE][MAXSIZE],int MatP[MAXSIZE][MAXSIZE],int RowA,int ColA,int RowB, int ColB, int *RowP, int *ColP) {
	if(RowA != ColB || ColA != RowB){
		return -1; /*Incompatible types*/
	}
	int i,j,k;
	*RowP = RowA; /*Set Resulting Matrix Row*/
	*ColP = ColB; /*Set Resulting Matrix Col*/
	/*Reset the result array to 0*/
	for(i=0;i<*RowP;i++){
		for(j=0;j<*ColP;j++){
			MatP[i][j] = 0;
		}
	}
	/*Multiply and deliver*/
	for(i=0;i<*RowP;i++){ /*For each Row in result*/
		for(j=0;j<*ColP;j++){ /*For each Col in results*/
			for(k=0;k<ColA;k++){ /*For each element we need to add up in Col*/
				MatP[i][j] += (MatA[i][k]*MatB[k][j]);
			}
		}
	}
	return 0;
}

/*===== Function Ortho: check for orthogonal matrix*/ /*Input parameters:
     int Mat[MAXSIZE][MAXSIZE]     matrix
     int Transp[MAXSIZE][MAXSIZE]  its transpose
     int Size                      size
  Output parameter:
    0 for yes or -1 for no*/
 /*Given a square matrix, its dimensions in Size,
  and its transpose in Transp, check if Mat is
  orthogonal by comparing if Mat x Transp = Identity */
/*It also calls the function:
  MatMult(Mat,Transp,Prod,Size,Size,Size,Size,&Size,&Size)
  to multiply the two matrices before comparing the result to I*/
int Ortho (int Mat[MAXSIZE][MAXSIZE],int Transp[MAXSIZE][MAXSIZE],int Size){
	int Prod[MAXSIZE][MAXSIZE],i,j;/*Initialize the Product matrix*/
	MatMult(Mat,Transp,Prod,Size,Size,Size,Size, &Size,&Size);/*Multiply the two matrices together*/
	/*Check Prod for identity*/
	int isIdent = 0;
	for(i=0;i<Size;i++){
		for(j=0;j<Size;j++){
			if(i!=j){ /*Not on diagonal. Should be 0.*/
				if(Prod[i][j]!=0){
					isIdent = -1;
				}
			}
			if(i==j){ /*On diagonal. Should be 1.*/
				if(Prod[i][j]!=1){
					isIdent = -1;
				}
			}
		}
	}
	
return isIdent;
}

/*===============================================*/
int main() {
	int MatMain[MAXSIZE][MAXSIZE];			/*the initial matrix*/
	int MatTransp[MAXSIZE][MAXSIZE]; 		/*the transpose*/
	int RsizeM, CsizeM;				/*matrix row size and column size*/
	int RsizeTr,CsizeTr;			/*transpose row size and column size*/
	int	nir;				/*counters*/

	fprintf(stdout, "Matrix testing program starts\n");	/*Headers*/
	fprintf(stdout, "Bill Xiong V00737042\n");
	fprintf(stdout, "Summer 2012 - CSC 230 Assignment 1\n");
	/*open input file*/
	fpin = fopen("INA1.txt", "r");  /* open the file for reading */
	if (fpin == NULL) {
		fprintf(stdout, "Cannot open input file  - Bye\n");
		return(0); 					/* if problem, exit program*/
	}
	/*ASSUMPTIONS: the file is not empty
		and the matrix has at least 1 element*/
	
	/*nir = RdRowSize(fpin,&RsizeM); */
	nir=fscanf(fpin,"%d",&RsizeM);	 /*read row size of a matrix */
							/* this needs to be encapsulated in RdRowSize*/
	while (nir == 1) {				/* while not end of file*/
		fscanf(fpin,"%d",&CsizeM);	/*read column size*/
		RdMatrix(fpin,MatMain,RsizeM,CsizeM);
		/*print the matrix and the sizes*/
		fprintf(stdout, "\n\n*** MATRIX ***");
		fprintf(stdout, "  Size = %2d x %2d\n",RsizeM,CsizeM);
		PrMat(MatMain,RsizeM,CsizeM);
		fprintf(stdout,"\n");

		/* NEW CODE HERE FOR PROCESSING */
		Transpose(MatMain,MatTransp,RsizeM,CsizeM,&RsizeTr,&CsizeTr); /* Compute Transpose */
		fprintf(stdout, "    Transpose:");
		fprintf(stdout, " Size = %2d x %2d\n",RsizeTr,CsizeTr);
		PrMat(MatTransp,RsizeTr,CsizeTr); /* Print Transpose */
		if(RsizeM != CsizeM){/*Not Square. Do nothing.*/
			fprintf(stdout,"	==>Not Square - no testing");
		}else{
			if(Symm(MatMain,MatTransp,RsizeM)==0){ /*Check Symmetry*/
				fprintf(stdout,"	==>Symmetric");
			}else{
				fprintf(stdout,"	==>Not Symmetric");
			}fprintf(stdout,"\n"); /*Insert some spacing so TA's don't go insane marking this*/
			if(SkewSymm(MatMain,MatTransp,RsizeM)==0){ /*Check Skew-Symmetry*/
				fprintf(stdout,"	==>Skew-Symmetric");
			}else{
				fprintf(stdout,"	==>Not Skew-Symmetric");
			}fprintf(stdout,"\n"); /*Insert some more spacing so TA's don't go insane marking this*/
			if(Ortho(MatMain,MatTransp,RsizeM)==0){ /*Check Orthogonal*/
				fprintf(stdout,"	==>Orthogonal");
			}else{
				fprintf(stdout,"	==>Not Orthogonal");
			}fprintf(stdout,"\n"); /*Insert some more spacing so TA's don't go insane marking this*/
		}
		nir=fscanf(fpin,"%d",&RsizeM); /*read next row size*/
	}

	fclose(fpin);  /* close the file */
	fprintf(stdout, "\nAll done - Bye\n");

	return (0);
}
