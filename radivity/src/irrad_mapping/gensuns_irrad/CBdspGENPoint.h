#ifndef _INC_CBDSPGEOMPOINT_INCLUDED
#define _INC_CBDSPGEOMPOINT_INCLUDED

// SYSTEM INCLUDES
// 
#include <iostream>

#ifndef _USE_MATH_DEFINES
#define _USE_MATH_DEFINES
#endif
#include <cmath>

// PROJECT INCLUDES
//

// LOCAL INCLUDES
//

// FORWARD REFERENCES
//

namespace BdspGENPointCoords
{
	// helper enum for accessing x, y and z coordinates in CBdspGENPoint
	enum { X=0, Y=1, Z=2};
};

template <class NUMBER>
class  CBdspGENPoint_ 
{
public:
	typedef NUMBER number_type;

	CBdspGENPoint_(); ///< default constructor creates point at origin
	CBdspGENPoint_& operator=(const CBdspGENPoint_ &a);	
	CBdspGENPoint_(const CBdspGENPoint_ &A); 	

	template <class N>
	operator CBdspGENPoint_<N>() const; 	

	static CBdspGENPoint_ UnitVector(const CBdspGENPoint_ &A);
	static CBdspGENPoint_ CartesianNormalised(NUMBER Xcoord, NUMBER Ycoord, NUMBER Zcoord);
	static CBdspGENPoint_ Cartesian(NUMBER Xcoord, NUMBER Ycoord, NUMBER Zcoord);
	static CBdspGENPoint_ Polar(NUMBER altitudeRads, NUMBER azimuthFromNorthRads, NUMBER radius=1);
	static const CBdspGENPoint_& Origin();

	CBdspGENPoint_& operator+=(const CBdspGENPoint_ &a);
	CBdspGENPoint_& operator-=(const CBdspGENPoint_ &a);
	CBdspGENPoint_& operator*=(NUMBER k); 
	CBdspGENPoint_& operator/=(NUMBER k); 

	NUMBER& operator[](unsigned int i);			///< access element i
	const NUMBER& operator[](unsigned int i) const;///< access element i

	NUMBER Altitude() const;
	NUMBER Azimuth() const;
	NUMBER Radius() const;

private:
	// construct polar point
	CBdspGENPoint_(NUMBER altitudeRads, NUMBER azimuthRads, NUMBER radius, bool dummy); // need dummy argument to distinguish constructors

	// construct cartesian point
	CBdspGENPoint_(NUMBER Xcoord, NUMBER Ycoord, NUMBER Zcoord);

	void CalculateSphericalCoordinates() const;
	void CalculateAltitude() const;
	void CalculateAzimuth() const;

	/// store the actual co-ordinates (3 dimensional points)
	NUMBER m_coords[3];

	mutable NUMBER m_altitude;
	mutable NUMBER m_azimuth;
	mutable NUMBER m_radius;
	mutable bool m_sphericalCalculated; // note - lazy evaluation of alt and az is used
};

template <class NUMBER>
const CBdspGENPoint_<NUMBER> operator+(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b);
template <class NUMBER>
const CBdspGENPoint_<NUMBER> operator-(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b);
template <class NUMBER, class SCALAR>
const CBdspGENPoint_<NUMBER> operator/(const CBdspGENPoint_<NUMBER> &a, SCALAR b);
template <class NUMBER, class SCALAR>
const CBdspGENPoint_<NUMBER> operator*(const CBdspGENPoint_<NUMBER> &a, SCALAR b);
template <class NUMBER>
const CBdspGENPoint_<NUMBER> operator-(const CBdspGENPoint_<NUMBER> &a);

template <class NUMBER>
CBdspGENPoint_<NUMBER> cross_product(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b);
template <class NUMBER>
NUMBER dot_product(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b);

template <class NUMBER>
NUMBER length_squared(const CBdspGENPoint_<NUMBER> &a);
template <class NUMBER>
NUMBER distance_squared(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b);
template <class NUMBER>
NUMBER distance_from_line_squared(const CBdspGENPoint_<NUMBER> &point,
							  const CBdspGENPoint_<NUMBER> &line_origin, 
							  const CBdspGENPoint_<NUMBER> &line_direction);

template <class NUMBER>
std::ostream& operator<<(std::ostream &o, const CBdspGENPoint_<NUMBER>& a);

template <class NUMBER>
bool ApproxEqual(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b);

template <class NUMBER>
bool operator==(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b)
{
	return ApproxEqual(a,b);
}

template <class NUMBER>
bool operator!=(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b)
{ 
	return !(a==b); 
}


#include "CBdspGENPoint.inl"

// we get a significant increase in speed by using float instead of double points
typedef CBdspGENPoint_<float> CBdspGENPoint;


bool operator<(const CBdspGENPoint &a, const CBdspGENPoint &b);

float closest_point_on_line(const CBdspGENPoint &point, const CBdspGENPoint &a, const CBdspGENPoint &b);

// returns true if points are (roughly) collinear
bool collinear(const CBdspGENPoint &a,const CBdspGENPoint &b,const CBdspGENPoint &c);


#endif // _INC_CBDSPGEOMPOINT_INCLUDED
