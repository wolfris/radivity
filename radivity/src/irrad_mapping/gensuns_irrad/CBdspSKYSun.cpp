#include "CBdspSKYSun.h"
#include "CBdspSKYSiteLocation.h"

// =========================== LIFECYCLE ====================================
CBdspSKYSun::CBdspSKYSun (const CBdspSKYSiteLocation& location, int day, float hourangle) :
		m_latitudeRadN(location.latitudeRadN),
		m_longitudeRadE(location.longitudeRadE),
		m_meridianRadE(location.meridianRadE),
		m_solarPosition(CBdspGENPoint::Origin()),
		m_northAngleRadAnticlockwiseFromY(location.northAngleRadW)
{
	if (!this->SetDay(day))
		this->SetDay(1);

	if (!this->SetHourAngle(hourangle))
		this->SetHourAngle((float)M_PI/2);

	Update();
}

// ..........................................................................

float CBdspSKYSun::TimeDiffHours() const
{
	const float Et = 229.2f * (0.000075f + 
					0.001868f*cos(m_dayAngle) - 0.032077f*sin(m_dayAngle) - 
					0.014615f*cos(2*m_dayAngle) - 0.04089f*sin(2*m_dayAngle));

	return ((4.f/60.f)*(m_longitudeRadE-m_meridianRadE)*180.f/(float)M_PI) + (Et/60.f);
}

// ..........................................................................

bool CBdspSKYSun::SetDay(int day)
{
  if (day >=1 && day <=365)
  {
    m_dayAngle=2.0f*(float)M_PI*(day-1.0f)/365.0f;
    m_declination = 0.006918f - 0.399912f*cos(m_dayAngle) + 0.070257f*sin(m_dayAngle) 
               - 0.006758f*cos(2*m_dayAngle) + 0.000907f*sin(2*m_dayAngle) - 0.002697f*cos(3*m_dayAngle) 
               + 0.00148f*sin(3*m_dayAngle);

    Update();
	return true;
  }
  else
    return false;
}

// ..........................................................................

int CBdspSKYSun::GetDay() const 
{ 
	return int((m_dayAngle*365/(2*M_PI)) + 1); 
} 

// ..........................................................................

bool CBdspSKYSun::SetHourAngle(float hourangle)
{
	m_hourAngle=hourangle;

	Update();

	if (hourangle >= m_sunriseHourAngle && hourangle <= (2*(float)M_PI - m_sunriseHourAngle))
	{
		return true;
	}
	else
		// return false if the user tries to set the time outside of the solar
        // day (but still let them do it)
		return false;
}
// ..........................................................................

bool CBdspSKYSun::SetSolarTime(float hour)
{
	return SetHourAngle(hour*(float)M_PI/12);
}

// ..........................................................................

float CBdspSKYSun::GetSolarTime()  const
{
	return m_hourAngle*(12.f/(float)M_PI);
}

// ..........................................................................

bool CBdspSKYSun::SetClockTime(float hour)
{
	return SetSolarTime(hour+TimeDiffHours());
}

// ..........................................................................

void CBdspSKYSun::Update()
{
    CalculateSunrise();
	CalculatePosition();
}

// ..........................................................................

float CBdspSKYSun::CalculateAltitude() 
{
	return asin(
			sin(m_latitudeRadN)*sin(m_declination) - 
			cos(m_latitudeRadN)*cos(m_declination)*cos(m_hourAngle)
		);
}

// ..........................................................................

float CBdspSKYSun::CalculateAzimuth(float altitude) 
{
  const float temp = (-sin(m_latitudeRadN)*sin(altitude) + sin(m_declination))
					/(cos(m_latitudeRadN)*cos(altitude));

  float az=0;
  if (temp > 1)
	 az= 0;
  else if (temp < -1)
	 az= (float)M_PI;  
  else if (m_hourAngle < (float)M_PI)
     az= acos(temp);
  else
     az= 2*(float)M_PI - acos(temp);

  return az-m_northAngleRadAnticlockwiseFromY;
}

// ..........................................................................

const CBdspGENPoint& CBdspSKYSun::GetPosition() const
{
	return m_solarPosition;
}

// ..........................................................................

float CBdspSKYSun::GetSunriseHourAngle() const 
{ 
	return m_sunriseHourAngle; 
}

// ..........................................................................

bool CBdspSKYSun::SunUp() const
{ 
	return m_solarPosition[BdspGENPointCoords::Z]>0.f; 
}

// ..........................................................................

void CBdspSKYSun::CalculateSunrise()
{
	const float t=tan(m_latitudeRadN)*tan(m_declination);
	if (t>=1)
		m_sunriseHourAngle=0;
	else if (t<=-1)
		m_sunriseHourAngle=(float)M_PI;
	else
		m_sunriseHourAngle=acos(t);
}

// ..........................................................................

void CBdspSKYSun::CalculatePosition()
{
	const float altitude=CalculateAltitude();
	const float azimuth=CalculateAzimuth(altitude);
	m_solarPosition=CBdspGENPoint::Polar(altitude, azimuth);
}
