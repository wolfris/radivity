#ifndef _INC_CBDSPSKYSITELOCATION_INCLUDED
#define _INC_CBDSPSKYSITELOCATION_INCLUDED

class CBdspSKYSiteLocation
{
public:
	CBdspSKYSiteLocation(float latRadN=52*3.1415927/180, float longRadE=0, float merRadE=0, float northRadW=0) :
		latitudeRadN(latRadN),
		longitudeRadE(longRadE),
		meridianRadE(merRadE),
		northAngleRadW(northRadW)
		{}

	CBdspSKYSiteLocation(const CBdspSKYSiteLocation& loc) :
		latitudeRadN(loc.latitudeRadN),
		longitudeRadE(loc.longitudeRadE),
		meridianRadE(loc.meridianRadE),
		northAngleRadW(loc.northAngleRadW)
		{}

	float latitudeRadN;
	float longitudeRadE;
	float meridianRadE;
	float northAngleRadW; // radians west of north
};

#endif //_INC_CBDSPSKYSITELOCATION_INCLUDED
