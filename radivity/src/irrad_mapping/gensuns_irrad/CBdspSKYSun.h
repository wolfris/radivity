#pragma once

#ifndef _INC_CBDSPSKYSUN_INCLUDED
#define _INC_CBDSPSKYSUN_INCLUDED

/**
 *  Class to describe movement of sun
 *
 */

// SYSTEM INCLUDES
//
#ifndef _USE_MATH_DEFINES
#define _USE_MATH_DEFINES
#endif
#include <math.h>

// PROJECT INCLUDES
//


// LOCAL INCLUDES
//
#include "./CBdspSKYSiteLocation.h"
#include "./CBdspGENPoint.h"

// FORWARD REFERENCES
//

class CBdspSKYSun
{
public:
	CBdspSKYSun (const CBdspSKYSiteLocation& location=CBdspSKYSiteLocation(),
					int day=1, float hourangle=M_PI/2); // latitude in radians, day is integer 1-365

	// Difference between solar and clock time (add result to clock time to get solar)
	// return value in hours
	float TimeDiffHours() const;

	bool SetDay(int day); // day from 1-365
	int GetDay() const;

	bool SetClockTime(float hour); // hour from 0-24

	bool SetSolarTime(float hour);
	float GetSolarTime() const;

	const CBdspGENPoint& GetPosition() const; // solar position (in x,y,z form)

	float GetSunriseHourAngle() const;

	// True if sun is above horizon
	bool SunUp() const;

	bool SetHourAngle(float hourangle);
private:

	void Update();
	float CalculateAltitude();
	float CalculateAzimuth(float altitude);
	void CalculateSunrise();
	void CalculatePosition();

	// Note: all angles are stored in radians
	// location
	float m_latitudeRadN;
	float m_longitudeRadE;
	float m_meridianRadE;
	float m_northAngleRadAnticlockwiseFromY;

	// solar time
	float m_dayAngle;
	float m_hourAngle;

	float m_declination;
	float m_sunriseHourAngle;
	CBdspGENPoint m_solarPosition;
};

#endif //_INC_CBDSPSKYSUN_INCLUDED
