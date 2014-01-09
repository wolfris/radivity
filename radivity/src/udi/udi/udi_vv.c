#ifndef lint
static const char	RCSid[] = "$Id: pcomb.c,v 2.39 2006/09/08 21:38:25 greg Exp $";
#endif
/*
 *  Combine picture files according to calcomp functions.
 *
 *	1/4/89
 */

#include "platform.h"
#include "standard.h"
#include "color.h"
#include "view.h"
#include "time.h"

#define MAXINP		512		/* maximum number of input files */

struct {
	char	*name;		/* file or command name */
	FILE	*fp;		/* stream pointer */
	VIEW	vw;		/* view for picture */
	RESOLU	rs;		/* image resolution and orientation */
	float	pa;		/* pixel aspect ratio */
	COLOR	*data;	/* input image data */
	COLOR	coef;		/* coefficient */
	COLOR	expos;		/* recorded exposure */
}	input[MAXINP];			/* input pictures */

FILE *skycoefficients=0;

int	nfiles;				/* number of input files */

char	ourfmt[LPICFMT+1] = PICFMT;	/* input picture format */

char	StandardInput[] = "<stdin>";
char	Command[] = "<Command>";

int	nowarn = 0;			/* no warning messages? */


int	xres = 0, yres = 0;			/* image resolution */

char	*progname;			/* global argv[0] */

COLOR	*combinedimage = 0;

COLOR	*udiaimage = 0; /* autonomous */
COLOR	*udisimage = 0; /* supplemented */
COLOR	*udis_scaled_image = 0; /* supplemented - scaled according to fraction of lux threshold achieved */
COLOR	*udiuimage = 0; /* under illuminated */
COLOR	*udioimage = 0; /* over illuminated */

FILE *udia =0;
FILE *udis =0;
FILE *udis_scaled =0;
FILE *udiu =0;
FILE *udio =0;
FILE *udiaa =0;
FILE *udioo =0;
FILE *udiss =0;
FILE *udiuu =0;

int	wrongformat = 0;
int	gotview;

double level_supplementary=100;
double level_autonomous=500;
double level_glare=2000;

static gethfunc headline;
static void checkfile(void);
static void readfiles(void);
static void combine(double *);
static void calculateudi(void);
static void advance(void);
static void zerodui(void);
static void updateudi(void);
static void writeheader(FILE *fp, int	argc, char	*argv[]);

static double
rgb_bright(
	COLOR  clr
)
{
	return(bright(clr));
}


static double
xyz_bright(
	COLOR  clr
)
{
	return(clr[CIEY]);
}


double	(*ourbright)() = rgb_bright;

int
main(int argc,char *argv[])
{
  int	original;
  double	f;
  int	a,b,bb;
  
  SET_DEFAULT_BINARY();
  SET_FILE_BINARY(stdin);

  progname = argv[0];
  /* scan options */
  for (a = 1; a < argc; a++) {
    if (argv[a][0] == '-')
      switch (argv[a][1]) {
      case 'w':
	nowarn = !nowarn;
	continue;
      }
    break;
  }

  /* process files */
  for (nfiles = 0; nfiles < MAXINP; nfiles++) {
    setcolor(input[nfiles].coef, 1.0, 1.0, 1.0);
    setcolor(input[nfiles].expos, 1.0, 1.0, 1.0);
    input[nfiles].vw = stdview;
    input[nfiles].pa = 1.0;
  }
  nfiles = 0;
  original = 0;
  for ( ; a < argc; a++) {
    if (nfiles >= MAXINP) {
      eputs(argv[0]);
      eputs(": too many picture files\n");
      quit(1);
    }
    if (argv[a][0] == '-')
      switch (argv[a][1]) {
      case '\0':
	input[nfiles].name = StandardInput;
	input[nfiles].fp = stdin;
	break;
      case 'o':
	original++;
	continue;
      case 'f':
	skycoefficients=fopen(argv[++a],"r");
	if (skycoefficients == NULL) {
	  perror(argv[a]);
	  quit(1);
	case 's':
	  level_supplementary = atof(argv[++a]);
	  continue;
	case 'a':
	  level_autonomous = atof(argv[++a]);
	  continue;
	case 'g':
	  level_glare = atof(argv[++a]);
	  continue;
	}
	continue;
      default:
	goto usage;
      }
    else {
      if (argv[a][0] == '!') {
	input[nfiles].name = Command;
	input[nfiles].fp = popen(argv[a]+1, "r");
      } else {
	input[nfiles].name = argv[a];
	input[nfiles].fp = fopen(argv[a], "r");
      }
      if (input[nfiles].fp == NULL) {
	perror(argv[a]);
	quit(1);
      }
    }
    checkfile();
    if (original) {
      colval(input[nfiles].coef,RED) /=
	colval(input[nfiles].expos,RED);
      colval(input[nfiles].coef,GRN) /=
	colval(input[nfiles].expos,GRN);
      colval(input[nfiles].coef,BLU) /=
	colval(input[nfiles].expos,BLU);
      setcolor(input[nfiles].expos, 1.0, 1.0, 1.0);
    }
    nfiles++;
    original = 0;
  }

  if (skycoefficients == NULL) {
    eputs("No sky coefficient file specified - exiting");
    quit(1);
  }

  if (!strcmp(ourfmt, CIEFMT)) {
    ourbright = xyz_bright;
  }


  /* open files */
  udiu =fopen("./udiu.pic","w");
  udis =fopen("./udis.pic","w");
  udis_scaled=fopen("./udis_scaled.pic","w");
  udia =fopen("./udia.pic","w");
  udio =fopen("./udio.pic","w");
  udiaa=fopen("./udia_d.dat","w");
  udioo=fopen("./udio_d.dat","w");
  udiuu=fopen("./udiu_d.dat","w");
  udiss=fopen("./udis_d.dat","w");

  writeheader(udiu,argc,argv);
  writeheader(udis,argc,argv);
  writeheader(udis_scaled,argc,argv);
  writeheader(udia,argc,argv);
  writeheader(udio,argc,argv);

  /* combine pictures */

  readfiles();
  combinedimage=(COLOR *)emalloc(xres*yres*sizeof(COLOR));
  udiaimage=(COLOR *)emalloc(xres*yres*sizeof(COLOR));
  udisimage=(COLOR *)emalloc(xres*yres*sizeof(COLOR));
  udis_scaled_image=(COLOR *)emalloc(xres*yres*sizeof(COLOR));
  udiuimage=(COLOR *)emalloc(xres*yres*sizeof(COLOR));
  udioimage=(COLOR *)emalloc(xres*yres*sizeof(COLOR));
  eputs("Initialising the calculation of UDI...\n");
  fprintf(stdout,"supplementary level: %f, adequate level: %f, glare level: %f\n", level_supplementary,level_autonomous, level_glare);
  calculateudi();


  for (a = 0; a < yres; a++) {
    if (fwritescan(udiuimage+a*xres, xres, udiu) < 0) {
      perror("write error");
    }
	for (b = 0; b < xres; b++){
		bb = a*xres+b;
		fprintf(udiuu, "%d\t%d\t%f\t%f\t%f\n", b,a,*(udiuimage+bb)[RED],*(udiuimage+bb)[RED],*(udiuimage+bb)[RED]);
	}
  }
  for (a = 0; a < yres; a++) {
    if (fwritescan(udisimage+a*xres, xres, udis) < 0) {
      perror("write error");
    }
	for (b = 0; b < xres; b++){
		bb = a*xres+b;
		fprintf(udiss, "%d\t%d\t%f\t%f\t%f\n", b,a,*(udisimage+bb)[RED],*(udisimage+bb)[RED],*(udisimage+bb)[RED]);
	}
  }
  for (a = 0; a < yres; a++) {
    if (fwritescan(udis_scaled_image+a*xres, xres, udis_scaled) < 0) {
      perror("write error");
    }
  }
  for (a = 0; a < yres; a++) {
    if (fwritescan(udiaimage+a*xres, xres, udia) < 0) {
      perror("write error");
    }
	for (b = 0; b < xres; b++){
		bb = a*xres+b;
		fprintf(udiaa, "%d\t%d\t%f\t%f\t%f\n", b,a,*(udiaimage+bb)[RED],*(udiaimage+bb)[RED],*(udiaimage+bb)[RED]);
	}
  }
  for (a = 0; a < yres; a++) {
    if (fwritescan(udioimage+a*xres, xres, udio) < 0) {
      perror("write error");
    }
	for (b = 0; b < xres; b++){
		bb = a*xres+b;
		fprintf(udioo, "%d\t%d\t%f\t%f\t%f\n", b,a,*(udioimage+bb)[RED],*(udioimage+bb)[RED],*(udioimage+bb)[RED]);
	}
  }


  quit(0);
 usage:
  eputs("Usage: ");
  eputs(argv[0]);
  eputs(
	" [-w][-h][-x xr][-y yr][-e expr][-f file] [ [-o][-s f][-c r g b] pic ..]\n");
  quit(1);
  return 1; /* pro forma return */
}

static void
writeheader(FILE *fp, int argc, char *argv[])
{
  SET_FILE_BINARY(fp);
  newheader("RADIANCE", fp);	/* start header */
  fputnow(fp);

  /* complete header */
  printargs(argc, argv, fp);
  if (strcmp(ourfmt, PICFMT))
    {
      fputformat(ourfmt, fp);	/* print format if known */
    }
  fputc('\n',fp);
  fprtresolu(xres, yres, fp);
}

static int
headline(			/* check header line & echo if requested */
	char	*s,
	void	*p
)
{
	char	fmt[32];
	double	d;
	COLOR	ctmp;

	if (isheadid(s))			/* header id */
		return(0);	/* don't echo */
	if (formatval(fmt, s)) {		/* check format */
		if (globmatch(ourfmt, fmt)) {
			wrongformat = 0;
			strcpy(ourfmt, fmt);
		} else
			wrongformat = globmatch(PICFMT, fmt) ? 1 : -1;
		return(0);	/* don't echo */
	}
	if (isexpos(s)) {			/* exposure */
		d = exposval(s);
		scalecolor(input[nfiles].expos, d);
	} else if (iscolcor(s)) {		/* color correction */
		colcorval(ctmp, s);
		multcolor(input[nfiles].expos, ctmp);
	} else if (isaspect(s))
		input[nfiles].pa *= aspectval(s);
	else if (isview(s) && sscanview(&input[nfiles].vw, s) > 0)
		gotview++;

	return(0);
}


static void
checkfile(void)			/* ready a file */
{
	register int	i;
					/* process header */
	gotview = 0;

	getheader(input[nfiles].fp, headline, NULL);
	if (wrongformat < 0) {
		eputs(input[nfiles].name);
		eputs(": not a Radiance picture\n");
		quit(1);
	}
	if (wrongformat > 0) {
		wputs(input[nfiles].name);
		wputs(": warning -- incompatible picture format\n");
	}
	if (!gotview || setview(&input[nfiles].vw) != NULL)
		input[nfiles].vw.type = 0;
	if (!fgetsresolu(&input[nfiles].rs, input[nfiles].fp)) {
		eputs(input[nfiles].name);
		eputs(": bad picture size\n");
		quit(1);
	}
	if (xres == 0 && yres == 0) {
		xres = scanlen(&input[nfiles].rs);
		yres = numscans(&input[nfiles].rs);
	} else if (scanlen(&input[nfiles].rs) != xres ||
			numscans(&input[nfiles].rs) != yres) {
		eputs(input[nfiles].name);
		eputs(": resolution mismatch\n");
		quit(1);
	}
					/* allocate scanlines */
	input[nfiles].data=(COLOR*)emalloc(xres*yres*sizeof(COLOR));
}


static int
getcascii(		/* get an ascii color value from sky coefficient file */
	COLOR  col
)
{
	double	vd[3];
	if (fscanf(skycoefficients, "%lf %lf %lf", &vd[0], &vd[1], &vd[2]) != 3)
		return(-1);

	setcolor(col, vd[0], vd[1], vd[2]);
	return(0);
}

static int
getdascii(		/* get an ascii double value from sky coefficient file */
	double *d
)
{
	if (fscanf(skycoefficients, "%lf ", d) != 1)
		return(-1);
	return(0);
}

static void zeroudi(void)
{
	int pos,j;
	for (pos = 0; pos < xres*yres; pos++) {
		for (j = 0; j < 3; j++) {
			colval(udiaimage[pos],j)=0.0;
			colval(udisimage[pos],j)=0.0;
			colval(udis_scaled_image[pos],j)=0.0;
			colval(udiuimage[pos],j)=0.0;
			colval(udioimage[pos],j)=0.0;
		}
	}
}

static void updateudi(void)
{
	int pos,j;
	double brt;
	for (pos = 0; pos < xres*yres; pos++) {
		brt=(*ourbright)(combinedimage[pos]);
		if (brt <level_supplementary)
		{
			for (j = 0; j < 3; j++) {
				++colval(udiuimage[pos],j);
			}
		}
		else if (brt>=level_supplementary && brt<level_autonomous)
		{
			for (j = 0; j < 3; j++) {
				++colval(udisimage[pos],j);
				colval(udis_scaled_image[pos],j)+=brt/level_autonomous;
			}
		}
		else if (brt>=level_autonomous && brt<level_glare)
		{
			for (j = 0; j < 3; j++) {
				++colval(udiaimage[pos],j);
			}
		}
		else
		{
			for (j = 0; j < 3; j++) {
				++colval(udioimage[pos],j);
			}
		}
	}
}

static void
calculateudi(void)
{
  int a,i;
  int pos;
  time_t time1, time2;
  double *scalefactors;
  scalefactors=(double*)emalloc(nfiles*sizeof(double));

  zeroudi();

  a=0;
  while (!feof(skycoefficients))
    {
      ++a;
      //      fprintf(stdout,"line %d of the skycoefficients\n",a);

      for (i=0; i<nfiles; i++)
	{
	  if (getdascii(&(scalefactors[i]))<0)
	    {
	      if (0==i)
		return; /* ran out of coefficients, so we're done here */
	      else
		{
		  eputs("Error reading sky coefficients\n");
		  quit(1);
		}
	    }
	}
      time1 = time(NULL);
      fprintf(stdout,"       Combining factors\n");
      combine(scalefactors);
      time2 = time(NULL);
      fprintf(stdout,"       Combining factors took %ld seconds\n", time2-time1);
      fprintf(stdout,"       Updating UDI\n");
      time1 = time(NULL);
      updateudi();
      time2 = time(NULL);
      fprintf(stdout,"Total line %d: %ld\n", a, time2-time1);
    }
  efree(scalefactors);
}

static void
combine(double *scalefactors)			/* combine pictures */
{
  int	pos;			/* output position */
  COLOR finalcol;
  double	d;
  register int	i, j;
  /* combine files */
  for (pos = 0; pos < xres*yres; pos++) {
    for (j = 0; j < 3; j++) {
      colval(combinedimage[pos],j)=0;
    }
  }

  /* note - instead of going through line by line it is faster to go
   * through image by image - presumably due to fewer cache hits
   */
  for (i = 0; i < nfiles; i++) {
    for (pos = 0; pos < xres*yres; pos++) {
      copycolor(finalcol,input[i].data[pos]);
      scalecolor(finalcol,scalefactors[i]);
      addcolor(combinedimage[pos],finalcol);
    }
    //fprintf(stdout,"             Added file No %d with %dx%d pixels and %d pos\n", i+1, xres, yres, pos);
  }
}

static void
readfiles(void)			/* read in color data from input files  */
{
	int	ytarget;
	register COLOR	*st;
	register int	i, j;

	for (i = 0; i < nfiles; i++) {
		for (ytarget=0; ytarget<yres; ytarget++)
		{
			register COLOR	*st;
			st=&(input[i].data[ytarget*xres]);

			if (freadscan(st, xres, input[i].fp) < 0) {  /* read */
				eputs(input[i].name);
				eputs(": read error\n");
				quit(1);
			}
			for (j = 0; j < xres; j++)	/* adjust color */
				multcolor(st[j], input[i].coef);

		}
	}
}

extern void
wputs(char	*msg)
{
	if (!nowarn)
		eputs(msg);
}


extern void
eputs(char *msg)
{
	fputs(msg, stderr);
}


extern void
quit(int code)		/* exit gracefully */
{
	register int  i;
				/* close input files */
	for (i = 0; i < nfiles; i++)
		if (input[i].name == Command)
			pclose(input[i].fp);
		else
			fclose(input[i].fp);

	efree((char *)combinedimage);

	exit(code);
}
