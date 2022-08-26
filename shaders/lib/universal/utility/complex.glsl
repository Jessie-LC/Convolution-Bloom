struct complexFloat {
	float r;
	float i;
};

complexFloat complexAdd(complexFloat a, complexFloat b)
{
	complexFloat c;
	c.r=a.r+b.r;
	c.i=a.i+b.i;
	return c;
}

complexFloat complexSub(complexFloat a, complexFloat b)
{
	complexFloat c;
	c.r=a.r-b.r;
	c.i=a.i-b.i;
	return c;
}

complexFloat complexSub(complexFloat a, float b)
{
	complexFloat c;
	c.r=a.r-b;
	c.i= -a.i;
	return c;
}

complexFloat complexSub(float a, complexFloat b)
{
	complexFloat c;
	c.r=a-b.r;
	c.i= -b.i;
	return c;
}

complexFloat complexMul(complexFloat a, complexFloat b)
{
	complexFloat c;
	c.r=a.r*b.r-a.i*b.i;
	c.i=a.i*b.r+a.r*b.i;
	return c;
}

complexFloat complexMul(float x, complexFloat a)
{
	complexFloat c;
	c.r=x*a.r;
	c.i=x*a.i;
	return c;
}

complexFloat complexMul(complexFloat x, float a)
{
	complexFloat c;
	c.r=x.r*a;
	c.i=x.i*a;
	return c;
}

complexFloat complexConjugate(complexFloat z)
{
	complexFloat c;
	c.r=z.r;
	c.i = -z.i;
	return c;
}

complexFloat complexDiv(complexFloat a, complexFloat b)
{
	complexFloat c;
	float r,den;
	if (abs(b.r) >= abs(b.i)) {
		r=b.i/b.r;
		den=b.r+r*b.i;
		c.r=(a.r+r*a.i)/den;
		c.i=(a.i-r*a.r)/den;
	} else {
		r=b.r/b.i;
		den=b.i+r*b.r;
		c.r=(a.r*r+a.i)/den;
		c.i=(a.i*r-a.r)/den;
	}
	return c;
}

complexFloat complexDiv(complexFloat a, float z)
{
	complexFloat b = complexFloat(z, 0.0);
	complexFloat c;
	float r,den;
	if (abs(b.r) >= abs(b.i)) {
		r=b.i/b.r;
		den=b.r+r*b.i;
		c.r=(a.r+r*a.i)/den;
		c.i=(a.i-r*a.r)/den;
	} else {
		r=b.r/b.i;
		den=b.i+r*b.r;
		c.r=(a.r*r+a.i)/den;
		c.i=(a.i*r-a.r)/den;
	}
	return c;
}

float complexAbs(complexFloat z)
{
	float x,y,ans,temp;
	x=abs(z.r);
	y=abs(z.i);
	if (x == 0.0)
		ans=y;
	else if (y == 0.0)
		ans=x;
	else if (x > y) {
		temp=y/x;
		ans=x*sqrt(1.0+temp*temp);
	} else {
		temp=x/y;
		ans=y*sqrt(1.0+temp*temp);
	}
	return ans;
}

complexFloat complexSqrt(complexFloat z)
{
	complexFloat c;
	float x,y,w,r;
	if ((z.r == 0.0) && (z.i == 0.0)) {
		c.r=0.0;
		c.i=0.0;
		return c;
	} else {
		x=abs(z.r);
		y=abs(z.i);
		if (x >= y) {
			r=y/x;
			w=sqrt(x)*sqrt(0.5*(1.0+sqrt(1.0+r*r)));
		} else {
			r=x/y;
			w=sqrt(y)*sqrt(0.5*(r+sqrt(1.0+r*r)));
		}
		if (z.r >= 0.0) {
			c.r=w;
			c.i=z.i/(2.0*w);
		} else {
			c.i=(z.i >= 0) ? w : -w;
			c.r=z.i/(2.0*c.i);
		}
		return c;
	}
}

complexFloat complexExp(complexFloat z) {
	return complexMul(exp(z.r), complexFloat(cos(z.i), sin(z.i)));
}

vec2 complexToVector(complexFloat z) {
	return vec2(z.r, z.i);
}


struct complexVec3 {
	vec3 r;
	vec3 i;
};

complexVec3 complexAdd(complexVec3 a, complexVec3 b)
{
	complexVec3 c;
	c.r=a.r+b.r;
	c.i=a.i+b.i;
	return c;
}

complexVec3 complexSub(complexVec3 a, complexVec3 b)
{
	complexVec3 c;
	c.r=a.r-b.r;
	c.i=a.i-b.i;
	return c;
}

complexVec3 complexSub(complexVec3 a, vec3 b)
{
	complexVec3 c;
	c.r=a.r-b;
	c.i= -a.i;
	return c;
}

complexVec3 complexSub(vec3 a, complexVec3 b)
{
	complexVec3 c;
	c.r=a-b.r;
	c.i= -b.i;
	return c;
}

complexVec3 complexMul(complexVec3 a, complexVec3 b)
{
	complexVec3 c;
	c.r=a.r*b.r-a.i*b.i;
	c.i=a.i*b.r+a.r*b.i;
	return c;
}

complexVec3 complexMul(vec3 x, complexVec3 a)
{
	complexVec3 c;
	c.r=x*a.r;
	c.i=x*a.i;
	return c;
}

complexVec3 complexMul(complexVec3 x, vec3 a)
{
	complexVec3 c;
	c.r=x.r*a;
	c.i=x.i*a;
	return c;
}

complexVec3 complexConjugate(complexVec3 z)
{
	complexVec3 c;
	c.r=z.r;
	c.i = -z.i;
	return c;
}

complexVec3 complexDiv(complexVec3 a, complexVec3 b)
{
	complexVec3 c;
	vec3 r,den;
	if (all(greaterThanEqual(abs(b.r), abs(b.i)))) {
		r=b.i/b.r;
		den=b.r+r*b.i;
		c.r=(a.r+r*a.i)/den;
		c.i=(a.i-r*a.r)/den;
	} else {
		r=b.r/b.i;
		den=b.i+r*b.r;
		c.r=(a.r*r+a.i)/den;
		c.i=(a.i*r-a.r)/den;
	}
	return c;
}

complexVec3 complexDiv(complexVec3 a, vec3 b)
{
	complexVec3 B = complexVec3(b, vec3(0.0));
	complexVec3 c;
	vec3 r,den;
	if (all(greaterThanEqual(abs(B.r), abs(B.i)))) {
		r=B.i/B.r;
		den=B.r+r*B.i;
		c.r=(a.r+r*a.i)/den;
		c.i=(a.i-r*a.r)/den;
	} else {
		r=B.r/B.i;
		den=B.i+r*B.r;
		c.r=(a.r*r+a.i)/den;
		c.i=(a.i*r-a.r)/den;
	}
	return c;
}

vec3 complexAbs(complexVec3 z)
{
	vec3 x,y,ans,temp;
	x=abs(z.r);
	y=abs(z.i);
	if (all(equal(x, vec3(0.0))))
		ans=y;
	else if (all(equal(y, vec3(0.0))))
		ans=x;
	else if (all(greaterThanEqual(x, y))) {
		temp=y/x;
		ans=x*sqrt(1.0+temp*temp);
	} else {
		temp=x/y;
		ans=y*sqrt(1.0+temp*temp);
	}
	return ans;
}

complexVec3 complexSqrt(complexVec3 z)
{
	complexVec3 c;
	vec3 x,y,w,r;
	if (all(equal(z.r, vec3(0.0))) && all(equal(z.i, vec3(0.0)))) {
		c.r=vec3(0.0);
		c.i=vec3(0.0);
		return c;
	} else {
		x=abs(z.r);
		y=abs(z.i);
		if (all(greaterThanEqual(x, y))) {
			r=y/x;
			w=sqrt(x)*sqrt(0.5*(1.0+sqrt(1.0+r*r)));
		} else {
			r=x/y;
			w=sqrt(y)*sqrt(0.5*(r+sqrt(1.0+r*r)));
		}
		if (all(greaterThanEqual(z.r, vec3(0.0)))) {
			c.r=w;
			c.i=z.i/(2.0*w);
		} else {
			c.i=(all(greaterThanEqual(z.r, vec3(0.0)))) ? w : -w;
			c.r=z.i/(2.0*c.i);
		}
		return c;
	}
}

complexVec3 complexExp(complexVec3 z) {
	return complexMul(exp(z.r), complexVec3(cos(z.i), sin(z.i)));
}

mat2x3 complexToMatrix(complexVec3 z) {
	return mat2x3(z.r, z.i);
}

complexVec3 vectorsToComplex(in vec3 v1, in vec3 v2) {
	return complexVec3(v1, v2);
}