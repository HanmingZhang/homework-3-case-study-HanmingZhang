#version 300 es
precision highp float;

uniform float u_Width;
uniform float u_Height;
uniform float u_Time;


out vec4 out_Col;


// Ray marching stuff
const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;

/**
 * Rotation matrix around the X axis.
 */
mat3 rotateX(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );
}

/**
 * Rotation matrix around the Y axis.
 */
mat3 rotateY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}

/**
 * Rotation matrix around the Z axis.
 */
mat3 rotateZ(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, -s, 0),
        vec3(s, c, 0),
        vec3(0, 0, 1)
    );
}


/**
 * Signed distance function for a sphere centered at the origin with radius r.
 */
float sphereSDF(vec3 p, float r) {
    return length(p) - r;
}

float runingSphere(vec3 p, float r, float delay){
	float speed = 3.2;
    p.y -= r * sin((u_Time-delay) * speed);
    p.z -= r * cos((u_Time-delay) * speed);
    
    return sphereSDF(p, .1);
}


float runingSpheres(vec3 p, float r){
	return  min(runingSphere(rotateZ(0.875 * 3.1415926) * p, r, 0.7),
           min(runingSphere(rotateZ(0.75 * 3.1415926) * p, r, 0.6),
           min(runingSphere(rotateZ(0.625 * 3.1415926) * p, r, 0.5),
           min(runingSphere(rotateZ(0.5 * 3.1415926) * p, r, 0.4),
           min(runingSphere(rotateZ(0.375 * 3.1415926) * p, r, 0.3),
           min(runingSphere(rotateZ(0.25 * 3.1415926) * p, r, 0.2),
           min(runingSphere(rotateZ(0.125 * 3.1415926) * p, r, 0.1), runingSphere(p, r, 0.0))))))));
}


float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}


float wireFrame(vec3 samplePoint){
	 return min(sdTorus(rotateZ(0.875 * 3.1415926) * samplePoint, vec2(2.0, .01)),
          min(sdTorus(rotateZ(0.75 * 3.1415926) * samplePoint, vec2(2.0, .01)),
          min(sdTorus(rotateZ(0.625 * 3.1415926) * samplePoint, vec2(2.0, .01)),
          min(sdTorus(rotateZ(0.5 * 3.1415926) * samplePoint, vec2(2.0, .01)),
          min(sdTorus(rotateZ(0.375 * 3.1415926) * samplePoint, vec2(2.0, .01)),
          min(sdTorus(rotateZ(0.25 * 3.1415926) * samplePoint, vec2(2.0, .01)),
          min(sdTorus(rotateZ(0.125 * 3.1415926) * samplePoint, vec2(2.0, .01)), 
              sdTorus(samplePoint, vec2(2.0, .01)))))))));
}


float sceneSDF(vec3 samplePoint) {    
    return wireFrame(samplePoint);
}


float sceneSDF2(vec3 samplePoint){
	return runingSpheres(samplePoint, 2.);
}

/**
 * Return the shortest distance from the eyepoint to the scene surface along
 * the marching direction. If no part of the surface is found between start and end,
 * return end.
 * 
 * eye: the eye point, acting as the origin of the ray
 * marchingDirection: the normalized direction to march in
 * start: the starting distance away from the eye
 * end: the max distance away from the ey to march before giving up
 */
float shortestDistanceToSurface(vec3 eye, vec3 marchingDirection, float start, float end) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float dist = sceneSDF(eye + depth * marchingDirection);
        if (dist < EPSILON) {
			return depth;
        }
        depth += dist;
        if (depth >= end) {
            return end;
        }
    }
    return end;
}


float shortestDistanceToRunningSpheres(vec3 eye, vec3 marchingDirection, float start, float end) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float dist = sceneSDF2(eye + depth * marchingDirection);
        if (dist < EPSILON) {
			return depth;
        }
        depth += dist;
        if (depth >= end) {
            return end;
        }
    }
    return end;
}


/**
 * Return the normalized direction to march in from the eye point for a single pixel.
 * 
 * fieldOfView: vertical field of view in degrees
 * size: resolution of the output image
 * fragCoord: the x,y coordinate of the pixel in the output image
 */
vec3 rayDirection(float fieldOfView, vec2 size, vec2 fragCoord) {
    vec2 xy = fragCoord - size / 2.0;
    float z = size.y / tan(radians(fieldOfView) / 2.0);
    return normalize(vec3(xy, -z));
}


/**
 * Return a transform matrix that will transform a ray from view space
 * to world coordinates, given the eye point, the camera target, and an up vector.
 *
 * This assumes that the center of the camera is aligned with the negative z axis in
 * view space when calculating the ray marching direction. See rayDirection.
 */
mat3 viewMatrix(vec3 eye, vec3 center, vec3 up) {
    // Based on gluLookAt man page
    vec3 f = normalize(center - eye);
    vec3 s = normalize(cross(f, up));
    vec3 u = cross(s, f);
    return mat3(s, u, -f);
}


float helpToolFunc(float t){

    float tmp1 = max(2. * (fract(.5 * t - 1.) - .5),.0);
	float tmp2 = floor(.5 * t);
    
    return .5 * (tmp1 + tmp2);
}


void main()
{
	vec3 viewDir = rayDirection(45.0, vec2(u_Width, u_Height), gl_FragCoord.xy);
    
    vec3 eye = vec3(.0, -15.0, 0);
    
    //vec3 eye = vec3(15.0, .0, .0);
    
    float t = 0.5 + helpToolFunc(u_Time / 2.0);
    
    // float t = .5;

    // float t = u_Time / 3.14159;

    eye = rotateX(t * 3.14159) * eye;
    
    vec3 up;
    if(mod(t,2.0) == .0 || mod(t,2.0) > 1.0){
    	up = vec3(.0, -1.,.0);
    }
    else{
        up = vec3(.0, 1.,.0);
    }
    
    mat3 viewToWorld = viewMatrix(eye, vec3(0.0, 0.0, 0.0), up);
    
    vec3 worldDir = viewToWorld * viewDir;
    
    float dist = shortestDistanceToSurface(eye, worldDir, MIN_DIST, MAX_DIST);
    
    if (dist > MAX_DIST - EPSILON) {
        // Didn't hit anything
        
        dist = shortestDistanceToRunningSpheres(eye, worldDir, MIN_DIST, MAX_DIST);
        
        if (dist > MAX_DIST - EPSILON) {
        	vec3 bg_Col = vec3(0.22353);
        	out_Col = vec4(bg_Col, 1.0);
			return;
        }
        
        vec3 ball_Col = vec3(0.87);
        out_Col = vec4(ball_Col, 1.0);
        return;
    }
    
    // The closest point on the surface to the eyepoint along the view ray
    vec3 p = eye + dist * worldDir;
    
    vec3 wireframeColor = vec3(.0);
    
    out_Col = vec4(wireframeColor, 1.0);
}