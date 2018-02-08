#version 300 es
precision highp float;

uniform float u_Width;
uniform float u_Height;
uniform float u_Time;


out vec4 out_Col;



// bases on Cell Merge (prototype) from https://www.shadertoy.com/view/llsXD8
// with metaball
float mBall(vec2 uv, vec2 pos, float radius)
{
	return radius/dot(uv-pos,uv-pos);
}

void main()
{
	vec3 color_bg = vec3(1.0);

	vec2 g = gl_FragCoord.xy;
    vec2 s = vec2(u_Width, u_Height);
    vec2 uv = (2.*g-s)/s.y;


	float radius = 0.4;
	float delay  = -0.7854;
	float oneOverSqrtTwo = 0.7071068;
	float speed = 1.5;

	float metaballRadius = 0.02;

	float mb = 0.;

   	mb += mBall(uv, vec2(radius, .0) + radius * sin(speed * u_Time) * vec2(-1., .0), metaballRadius);
    mb += mBall(uv, vec2(oneOverSqrtTwo * radius) + radius * sin(speed * u_Time + delay) * vec2(-oneOverSqrtTwo), metaballRadius);
    mb += mBall(uv, vec2(.0, radius) + radius * sin(speed * u_Time + 2.0 * delay) * vec2(.0, -1.), metaballRadius);
    mb += mBall(uv, vec2(-oneOverSqrtTwo * radius, oneOverSqrtTwo * radius) + radius * sin(speed * u_Time + 3.0 * delay) * vec2(oneOverSqrtTwo, -oneOverSqrtTwo), metaballRadius);
   	mb += mBall(uv, vec2(-radius, .0) + radius * sin(speed * u_Time + 4.0 * delay) * vec2(1., .0), metaballRadius);
    mb += mBall(uv, vec2(-oneOverSqrtTwo * radius) + radius * sin(speed * u_Time + 5.0 * delay) * vec2(oneOverSqrtTwo), metaballRadius);
    mb += mBall(uv, vec2(.0, -radius) + radius * sin(speed * u_Time + 6.0 * delay) * vec2(.0, 1.), metaballRadius);
    mb += mBall(uv, vec2(oneOverSqrtTwo * radius, -oneOverSqrtTwo * radius) + radius * sin(speed * u_Time + 7.0 * delay) * vec2(-oneOverSqrtTwo, oneOverSqrtTwo), metaballRadius);
   
    // vec3 mbin  = color_inner * (1.- smoothstep(mb, mb+0.01, 0.8)); // 0.8 for control the blob kernel size
    // vec3 mbext = color_outer * (1.-smoothstep(mb, mb+0.01, 0.5));  // 0.5 fro control the blob thickness

    out_Col = vec4(smoothstep(mb, mb+0.01, 1.1) * color_bg, 1.0);
}

