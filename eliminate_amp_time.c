#include <stdio.h>
#include <string.h>
#include <math.h>

#define MAX_LINE 1000
#define MAX_CHAR 50
#define ABS(x) (x>0?x:(-(x)))
void main(int argc, char **argv)
{
	FILE *fp;
	FILE *fresult;
	char source_filename[100];
	char target_filename[100];
	char col1[MAX_LINE][MAX_CHAR];
	double col2[MAX_LINE];
	double col3[MAX_LINE];
	int k,icount=0;
	double avg=0.0,sigma=0.0;
	if(argc!=3)
	{
		printf("Command parameters error!Correct format is as follows:\n");
		printf("convert.exe source_filename target_filename\n");
		return;
	}

	fp=fopen(argv[1],"r");
	fresult=fopen(argv[2],"w");

	while(!feof(fp))
	{
		fscanf(fp,"%s %lf %lf\n" ,col1[icount],&col2[icount],&col3[icount]);
		icount++;
	}
	
	for(k=0;k<icount;k++)
	{
		avg+=col3[k];
	}
	avg/=icount;
	for(k=0;k<icount;k++)
	{
		sigma+=pow((col3[k]-avg),2.0);
	}
        sigma/=icount-1;
	sigma=sqrt(sigma);
	for(k=0;k<icount;k++)
	{
		if(ABS(col3[k]-avg)<=2*sigma)
		{
			fprintf(fresult,"%s %lf %lf\n" ,col1[k],col2[k],col3[k]);
		}
	}
	fclose(fp);
	fclose(fresult);
}


