mat2 Rotate(float a) {
    vec2 m;
    m.x = sin(a);
    m.y = cos(a);
	return mat2(m.y, -m.x,  m.x, m.y);
}

//Rotation using Quaternions!
vec4 QuaternionMultiply(vec4 a, vec4 b) {
    return vec4(
        a.x * b.w + a.y * b.z - a.z * b.y + a.w * b.x,
        -a.x * b.z + a.y * b.w + a.z * b.x + a.w * b.y,
        a.x * b.y - a.y * b.x + a.z * b.w + a.w * b.z,
        -a.x * b.x - a.y * b.y - a.z * b.z + a.w * b.w
    );
}

vec3 Rotate(vec3 pos, vec3 axis, float angle) {
    vec4 q = vec4(sin(angle / 2.0) * axis, cos(angle / 2.0));
    vec4 qInv = vec4(-q.xyz, q.w);
    return QuaternionMultiply(QuaternionMultiply(q, vec4(pos, 0)), qInv).xyz;
}

vec3 Rotate(vec3 pos, vec3 from, vec3 to) {
    vec3 halfway = normalize(from + to);
    vec4 quat = vec4(cross(from, halfway), dot(from, halfway));
    vec4 qInv = vec4(-quat.xyz, quat.w);
    return QuaternionMultiply(QuaternionMultiply(quat, vec4(pos, 0)), qInv).xyz;
}

mat3 GetRotationMatrix(vec3 from, vec3 to) {
	float cosine = dot(from, to);

	float tmp = cosine < 0.0 ? -1.0 : 1.0;
          tmp = 1.0 / (tmp + cosine);

	vec3 axis = cross(to, from);
	vec3 tmpv = axis * tmp;

	return mat3(
		axis.x * tmpv.x + cosine, axis.x * tmpv.y - axis.z, axis.x * tmpv.z + axis.y,
		axis.y * tmpv.x + axis.z, axis.y * tmpv.y + cosine, axis.y * tmpv.z - axis.x,
		axis.z * tmpv.x - axis.y, axis.z * tmpv.y + axis.x, axis.z * tmpv.z + cosine
	);
}

mat3 GetRotationMatrix(vec3 unitAxis, float angle) {
    float cosine = cos(angle);

    vec3 axis = unitAxis * sin(angle);
    vec3 tmp = unitAxis - unitAxis * cosine;

    return mat3(
        unitAxis.x * tmp.x + cosine, unitAxis.x * tmp.y - axis.z, unitAxis.x * tmp.z + axis.y,
        unitAxis.y * tmp.x + axis.z, unitAxis.y * tmp.y + cosine, unitAxis.y * tmp.z - axis.x,
        unitAxis.z * tmp.x - axis.y, unitAxis.z * tmp.y + axis.x, unitAxis.z * tmp.z + cosine
    );
}