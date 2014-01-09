#include <iostream>
#include <fstream>
#include <stdio.h>
#include <cstdio>
#include <stdlib.h>
#include <math.h>
#include <iomanip>
#include <string>

#include "CBdspSKYSun.h"
#include <vector>
#include <cassert>

using namespace std;

void printUsageError()
{
  fprintf(stderr,"Usage: gensuns [-a latitude] [-o longitude][-m standard meridian][-w schedule]\n");
  fprintf(stderr,"(Note: longitude +ve East of Greenwich)\n\n");
}

int main(int argc, char* argv[])
{
  
  // Set the default parameters
  double latitude=51.7*M_PI/180;
  double longitude=0;
  double meridian=0;
  char* schedule;
  double sched_hrs[8760];
  string STRING;
  
  int wknd=0;
  int counter=1;
  
  std::fill_n(sched_hrs, 8760, 1);
  
  while (counter<argc)
    {
      if (argv[counter][0]=='-' && argv[counter][1]=='a')
	{
	  if ((argc-counter)>1)
	    {
	      latitude=atof(argv[counter+1])*M_PI/180;
	      counter+=2;
	    }
	  else
	    {
	      printUsageError();
	      return -1;
	    }
	}
      else if (argv[counter][0]=='-' && argv[counter][1]=='o')
	{
	  if ((argc-counter)>2)
	    {
	      longitude=atof(argv[counter+1])*M_PI/180.;
	      counter+=2;
	    }
	  else
	    {
	      printUsageError();
	      return -1;
	    }
	}
      else if (argv[counter][0]=='-' && argv[counter][1]=='m' )
	{
	  if ((argc-counter)>1)
	    {
	      meridian=atof(argv[counter+1])*M_PI/180.;
	      counter+=2;
	    }
	  else
	    {
	      printUsageError();
	      return -1;
	    }
	}
      else if (argv[counter][0]=='-' && argv[counter][1]=='w')
	{
	  if ((argc-counter)>=2)
	    {
	      schedule=argv[counter+1];
	      wknd=1;
	      counter+=2;
	    }
	  else
	    {
	      printUsageError();
	      return -1;
	    }
	}
      else
	{
	  printUsageError();
	  return -1;
	}
    }
  
  CBdspSKYSun sun(CBdspSKYSiteLocation(latitude,longitude,meridian));
  
  ifstream infile;
  infile.open(schedule);
  counter = 0;
  while(getline(infile,STRING))
    {		
      sched_hrs[counter]=atof(STRING.c_str());
      counter+=1;
    }
  
  
  counter = 0;
  for (int day=1; day<=365; ++day)
    {
      sun.SetDay(day);
      for (int hour=0; hour<24; ++hour)
	{
	  if (sched_hrs[counter]>0.0)
	    {
	      sun.SetClockTime(hour);
	      if (sun.SunUp())
		{
		  std::cout /*<< (day-1)*24+hour << ","*/
		    << sun.GetPosition()[BdspGENPointCoords::X] << " "
		    << sun.GetPosition()[BdspGENPointCoords::Y] << " "
		    << sun.GetPosition()[BdspGENPointCoords::Z] << " " << "\n";
		}
	    }
	  counter+=1;
	}
    }
  
  return 0;
  
 }
      
