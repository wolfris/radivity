#include "CBdspGENPoint.h"


#ifdef _MSC_VER
#if defined(DEBUG_MEM)
#define CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>
#define new new(_NORMAL_BLOCK,__FILE__, __LINE__)
#endif
#endif // _MSC_VER

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER> CBdspGENPoint_<NUMBER>::Cartesian(NUMBER x,NUMBER y,NUMBER z)
{
	return CBdspGENPoint_<NUMBER>(x,y,z);
}

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER> CBdspGENPoint_<NUMBER>::Polar(NUMBER altitudeRads, NUMBER azimuthRads, NUMBER radius)
{
	return CBdspGENPoint_<NUMBER>(altitudeRads,azimuthRads,radius,true);
}

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER> CBdspGENPoint_<NUMBER>::UnitVector(const CBdspGENPoint_<NUMBER> &A)
{
	if (A.Radius()!=0)
		return Cartesian(A.m_coords[BdspGENPointCoords::X]/A.Radius(),A.m_coords[BdspGENPointCoords::Y]/A.Radius(),A.m_coords[BdspGENPointCoords::Z]/A.Radius());
	else
		return Origin();
}

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER> CBdspGENPoint_<NUMBER>::CartesianNormalised(NUMBER x, NUMBER y, NUMBER z)
{
	return UnitVector(Cartesian(x,y,z));
}

// ..........................................................................

template<class NUMBER>
const CBdspGENPoint_<NUMBER>& CBdspGENPoint_<NUMBER>::Origin()
{
	// a little optimisation here - origin point is often required as a
    // temporary in calcs, so we create a static const version to return as a
    // const reference
	static const CBdspGENPoint_<NUMBER> origin(0,0,0);
	return origin;
}

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER>::CBdspGENPoint_() :
	m_sphericalCalculated(false)
{
	std::fill(m_coords,m_coords+3,0.f);
}

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER>::CBdspGENPoint_(NUMBER altitudeRads, NUMBER azimuthRads, NUMBER radius, bool /*dummy*/) :
	m_sphericalCalculated(true),
	m_altitude(altitudeRads),
	m_azimuth(azimuthRads),
	m_radius(radius)
{
	m_coords[BdspGENPointCoords::X]=sin(azimuthRads)*cos(altitudeRads)*m_radius;
	m_coords[BdspGENPointCoords::Y]=cos(azimuthRads)*cos(altitudeRads)*m_radius;
	m_coords[BdspGENPointCoords::Z]=sin(altitudeRads)*m_radius;
}

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER>::CBdspGENPoint_(NUMBER Xcoord, NUMBER Ycoord, NUMBER Zcoord) :
	m_sphericalCalculated(false)
{
	m_coords[BdspGENPointCoords::X]=Xcoord;
	m_coords[BdspGENPointCoords::Y]=Ycoord;
	m_coords[BdspGENPointCoords::Z]=Zcoord;
}

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER>::CBdspGENPoint_(const CBdspGENPoint_<NUMBER> &A) :
	m_sphericalCalculated(A.m_sphericalCalculated),
	m_altitude(A.m_altitude),
	m_azimuth(A.m_azimuth),
	m_radius(A.m_radius)
{
	m_coords[0]=A.m_coords[0];
	m_coords[1]=A.m_coords[1];
	m_coords[2]=A.m_coords[2];
}

// ..........................................................................

template<class NUMBER>
template <class N>
CBdspGENPoint_<NUMBER>::operator CBdspGENPoint_<N>() const
{
	return CBdspGENPoint_<N>::Cartesian(m_coords[0],m_coords[1],m_coords[2]);
}


// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER>& CBdspGENPoint_<NUMBER>::operator=(const CBdspGENPoint_<NUMBER> &a)
{
	if (this!=&a)
	{
		this->m_coords[0]=a.m_coords[0];
		this->m_coords[1]=a.m_coords[1];
		this->m_coords[2]=a.m_coords[2];

		this->m_altitude=a.m_altitude;
		this->m_azimuth=a.m_azimuth;
		this->m_radius=a.m_radius;
		this->m_sphericalCalculated=a.m_sphericalCalculated;
	}

	return *this;
}

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER>& CBdspGENPoint_<NUMBER>::operator-=(const CBdspGENPoint_<NUMBER> &a)
{
	this->m_coords[0]-=a.m_coords[0];
	this->m_coords[1]-=a.m_coords[1];
	this->m_coords[2]-=a.m_coords[2];

	this->m_sphericalCalculated=false;

	return *this;
}

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER>& CBdspGENPoint_<NUMBER>::operator+=(const CBdspGENPoint_<NUMBER> &a)
{
	this->m_coords[0]+=a.m_coords[0];
	this->m_coords[1]+=a.m_coords[1];
	this->m_coords[2]+=a.m_coords[2];

	this->m_sphericalCalculated=false;

	return *this;
}

// ..........................................................................

template<class NUMBER>
CBdspGENPoint_<NUMBER>& CBdspGENPoint_<NUMBER>::operator*=(NUMBER k)
{
	this->m_coords[0]*=k;
	this->m_coords[1]*=k;
	this->m_coords[2]*=k;

	this->m_sphericalCalculated=false;

	return *this;
}

template<class NUMBER>
CBdspGENPoint_<NUMBER>& CBdspGENPoint_<NUMBER>::operator/=(NUMBER k)
{
	this->m_coords[0]/=k;
	this->m_coords[1]/=k;
	this->m_coords[2]/=k;

	this->m_sphericalCalculated=false;

	return *this;
}
// ..........................................................................

template<class NUMBER>
NUMBER& CBdspGENPoint_<NUMBER>::operator[](unsigned int i)
{
	this->m_sphericalCalculated=false;
	return this->m_coords[i];
}

// ..........................................................................

template<class NUMBER>
const NUMBER& CBdspGENPoint_<NUMBER>::operator[](unsigned int i) const
{
	return this->m_coords[i];
}

// ..........................................................................

template<class NUMBER>
NUMBER CBdspGENPoint_<NUMBER>::Altitude() const
{
	if (!m_sphericalCalculated)
		CalculateSphericalCoordinates();

	return m_altitude;
}

// ..........................................................................

template<class NUMBER>
NUMBER CBdspGENPoint_<NUMBER>::Azimuth() const
{
	if (!m_sphericalCalculated)
		CalculateSphericalCoordinates();

	return m_azimuth;
}

// ..........................................................................

template<class NUMBER>
NUMBER CBdspGENPoint_<NUMBER>::Radius() const
{
	if (!m_sphericalCalculated)
		CalculateSphericalCoordinates();

	return m_radius;
}

// ..........................................................................

template<class NUMBER>
void CBdspGENPoint_<NUMBER>::CalculateSphericalCoordinates() const
{
	m_radius=sqrt(dot_product(*this,*this));

	CalculateAltitude();
	CalculateAzimuth();
	m_sphericalCalculated=true;
}

// ..........................................................................

template<class NUMBER>
void CBdspGENPoint_<NUMBER>::CalculateAltitude() const
{
	if (0==m_radius)
	{
		m_altitude=0;
	}
	else
	{
		m_altitude=asin(m_coords[BdspGENPointCoords::Z]/m_radius);
	}
}

// ..........................................................................

template<class NUMBER>
void CBdspGENPoint_<NUMBER>::CalculateAzimuth() const
{
	// shouldn't do atan2(0,0) (occurs when altitude = +/- 90 degrees)
	if (m_coords[BdspGENPointCoords::X]==0 && m_coords[BdspGENPointCoords::Y]==0)
	{
		m_azimuth=0;
	}
	else
	{
		m_azimuth=atan2(m_coords[BdspGENPointCoords::X],m_coords[BdspGENPointCoords::Y]);
	}
}


// ..........................................................................

template<class NUMBER>
const CBdspGENPoint_<NUMBER> operator+(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b)
{
	CBdspGENPoint_<NUMBER> c=a;
	c+=b;
	return c;
}

// ..........................................................................

template<class NUMBER>
const CBdspGENPoint_<NUMBER> operator-(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b)
{
	CBdspGENPoint_<NUMBER> c=a;
	c-=b;
	return c;
}

// ..........................................................................

template<class NUMBER, class SCALAR>
const CBdspGENPoint_<NUMBER> operator/(const CBdspGENPoint_<NUMBER> &a, SCALAR k)
{
	CBdspGENPoint_<NUMBER> tmp(a);
	tmp/=k;
	return tmp;
}

// ..........................................................................

template<class NUMBER, class SCALAR>
const CBdspGENPoint_<NUMBER> operator*(const CBdspGENPoint_<NUMBER> &a, SCALAR k)
{
	CBdspGENPoint_<NUMBER> tmp(a);
	tmp*=k;
	return tmp;
}

// ..........................................................................

template<class NUMBER>
const CBdspGENPoint_<NUMBER> operator-(const CBdspGENPoint_<NUMBER> &a)
{
	return CBdspGENPoint_<NUMBER>::Origin()-a;
}

// ..........................................................................

template <class NUMBER>
bool ApproxEqual(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b)
{
	const static NUMBER EPSILON=static_cast<NUMBER>(1e-4);
	const NUMBER distanceABSquared=length_squared(a-b);
	return distanceABSquared<EPSILON;
}

// ..........................................................................

template <class NUMBER>
NUMBER dot_product(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b)
{
	return a[0]*b[0] + a[1]*b[1] + a[2]*b[2];
}

// ..........................................................................

template <class NUMBER>
CBdspGENPoint_<NUMBER> cross_product(const CBdspGENPoint_<NUMBER> &a,const  CBdspGENPoint_<NUMBER> &b)
{
	return CBdspGENPoint_<NUMBER>::Cartesian(a[BdspGENPointCoords::Y]*b[BdspGENPointCoords::Z]-b[BdspGENPointCoords::Y]*a[BdspGENPointCoords::Z],
											-(a[BdspGENPointCoords::X]*b[BdspGENPointCoords::Z]-b[BdspGENPointCoords::X]*a[BdspGENPointCoords::Z]),
											a[BdspGENPointCoords::X]*b[BdspGENPointCoords::Y]-b[BdspGENPointCoords::X]*a[BdspGENPointCoords::Y]);

}

// ..........................................................................

template <class NUMBER>
NUMBER length_squared(const CBdspGENPoint_<NUMBER> &a)
{
	return dot_product(a,a);
}

// ..........................................................................

template <class NUMBER>
NUMBER distance_squared(const CBdspGENPoint_<NUMBER> &a, const CBdspGENPoint_<NUMBER> &b)
{
	return length_squared(a-b);
}

// ..........................................................................
template <class NUMBER>
NUMBER distance_from_line_squared(const CBdspGENPoint_<NUMBER> &point,
							  const CBdspGENPoint_<NUMBER> &line_origin,
							  const CBdspGENPoint_<NUMBER> &line_direction)
{
	return length_squared(cross_product(line_direction,line_origin-point))/length_squared(line_direction);
}


// ..........................................................................

template <class NUMBER>
std::ostream& operator<<(std::ostream &o, const CBdspGENPoint_<NUMBER>& A)
{
	o << A[0] << "," << A[1] << "," << A[2];
	return o;
}
