#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <iomanip>

#include "CBdspSKYSun.h"
#include <vector>
#include <cassert>

void printUsageError()
{
	fprintf(stderr,"Usage: genrepresentativesuns [-a latitude] [-o longitude][-m standard meridian]\n");
	fprintf(stderr,"(Note: longitude +ve East of Greenwich)\n\n");
}

int main(int argc, char* argv[])
{

	// Set the default parameters
	double latitude=51.7*M_PI/180;
	double longitude=0;
	double meridian=0;

	int counter=1;
	while (counter<argc)
	{
		if (argv[counter][0]=='-' && argv[counter][1]=='a')
		{
			if ((argc-counter)>=2)
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
			if ((argc-counter)>=2)
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
		else if (argv[counter][0]=='-' && argv[counter][1]=='m')
		{
			if ((argc-counter)>=2)
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
		else
		{
				printUsageError();
				return -1;
		}
	}

	CBdspSKYSun sun(CBdspSKYSiteLocation(latitude,longitude,meridian));

	const static int days[]={ 6, 36, 66, 96, 126, 157 };

	std::cout << "Representative suns: \n";
	std::vector<CBdspGENPoint> sunPositions;
	for (int dayIndex=0; dayIndex<sizeof(days)/sizeof(int); ++dayIndex)
	{
		sun.SetDay(days[dayIndex]);
		for (float hour=0.5; hour<24; ++hour)
		{
			sun.SetSolarTime(hour+((4./60.)*(longitude-meridian)*180.f/(float)M_PI));
			if (sun.SunUp())
			{
				sunPositions.push_back(sun.GetPosition());
				
				std::cout << "void light solar" << std::setw(3) << std::setfill('0') << sunPositions.size() 
						  << "\n0\n0\n3 1 1 1\nsolar" 
						  << std::setw(3) << std::setfill('0') << sunPositions.size() <<" source sun" << sunPositions.size() 
						  << "\n0\n0\n4 "
						  << sun.GetPosition()[BdspGENPointCoords::X] << " "
						  << sun.GetPosition()[BdspGENPointCoords::Y] << " "
						  << sun.GetPosition()[BdspGENPointCoords::Z] << " "
						  << "0.533\n\n";
			}
		}
	}

	std::cout << "Sun modifiers: \n";
	for (int i=0; i<sunPositions.size(); ++i)
		std::cout << "solar" << std::setw(3) << std::setfill('0') << i+1 << "\n";

	std::cout << "\nSun index for each hour of the year: \n";
	for (int day=1; day<=365; ++day)
	{
		sun.SetDay(day);
		for (int hour=0.; hour<24; ++hour)
		{
			sun.SetClockTime(hour+.5);

			if (sun.SunUp())
			{
				float cosClosestSunAngle=-9e9;
				int closestSun=-1;
				for (unsigned int i=0; i<sunPositions.size(); ++i)
				{
					const double cosThisSunAngle=dot_product(sun.GetPosition(),sunPositions[i]);
					if (cosThisSunAngle>cosClosestSunAngle)
					{
						cosClosestSunAngle=cosThisSunAngle;
						closestSun=i;
					}
				}
				std::cout << std::setw(3) << std::setfill('0') << closestSun+1 << "\n";
			}
			else
			{
				std::cout << "-1\n";
			}
		}
	}

	return 0;
}

