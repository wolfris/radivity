#include  <stdio.h>
#include  <stdlib.h>
#include  <ctype.h>
#include  <math.h>
#include  "platform.h"
#include  "resolu.h"
#include "color.h"

#define  MAXCOL		256		/* maximum number of columns */
#define INPUTCOLS 3 /* number of input columns */

static int execute(void);

int hresolu=512;
int vresolu=512;

extern char *
formstr(				/* return format identifier */
	int  f
)
{
	switch (f) {
	case 'a': return("ascii");
	case 'f': return("float");
	case 'd': return("double");
	case 'c': return(COLRFMT);
	}
	return("unknown");
}

int
main(
int  argc,
char  *argv[]
)
{
	int  status;
	int  a;
	int outform;
	outform='c';

	for (a = 1; a < argc; a++)
		if (argv[a][0] == '-')
		{
			switch (argv[a][1]) {
			case 'l':				/* limit distance - no effect but produced by vwrays -d */
				if (argv[a][2] != 'd')
					goto userr;
				break;
			case 'x':
				hresolu = atoi(argv[++a]);
				break;
			case 'y':				/* y resolution */
				vresolu = atoi(argv[++a]);
				break;
			default:;
			userr:
				fprintf(stderr,
"Usage: %s [-m][-sE|p|u|l][-tC][-i{f|d}[N]][-o{f|d}][-count [-r]] [file..]\n",
						argv[0]);
				exit(1);
			}
		}
		else
			goto userr;

	SET_FILE_BINARY(stdout);

	printargs(argc, argv, stdout);
	printf("SOFTWARE= test\n");
	fputnow(stdout);
	fputformat(formstr(outform), stdout);
	putchar('\n');
	fprtresolu(hresolu, vresolu, stdout);
	status = execute() == -1 ? 1 : 0;

	exit(status);
}


static int
getrecord(			/* read next input record */
	double field[MAXCOL],
	FILE *fp
)
{
	char  buf[16*MAXCOL];
	int   nf;

	float	*fbuf = (float *)buf;
	int	i;
	int c;

	c=fgetc(fp);

	if (EOF==c || '~'==c)
	{
		fgetc(fp);
		return 0;
	}
	else if ('\t'!=c)
	{
		fprintf (stderr,"Unexpected character: %c\n",c);
		exit(-1);
	}

	nf = fread(fbuf, sizeof(float), INPUTCOLS, fp);

	for (i = nf; i-- > 0; )
		field[i] = fbuf[i];
	return(nf);
}


static void
writeresult(			/* write out results record */
	int visiblecount,
	FILE *fp
)
{
	int n;
	double  result[3];
	double *field=result;
	COLR  col;

	for (n = 0; n < 3; n++) 
	{
		field[n] = visiblecount;
	}

	setcolr(col,	visiblecount,
			visiblecount,
			visiblecount);
	fwrite((char *)col, sizeof(col), 1, stdout);
	return;
}


static int
execute(void)
{
	double	inpval[MAXCOL];
	int count;
	int  nread;
	long  nlin;
	FILE  *fp;

	fp = stdin;
	SET_FILE_BINARY(fp);

	while (!feof(fp)) 
	{
		count=0;

		for (nlin = 0; (nread = getrecord(inpval, fp)) > 0;
				nlin++) 
		{
							/* compute */
			if (inpval[0]>0)
				++count;
		}
						/* compute and print */

		if (!feof(fp))
			writeresult(count, stdout);
	}
							/* close input */
	return(fclose(fp));
}
