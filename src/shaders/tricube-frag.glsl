#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec3 u_Color1;
uniform vec3 u_Color2;
uniform vec3 u_Color3;

uniform int u_AnimationStage;
uniform float u_ScreenRot;

uniform float u_Width;
uniform float u_Height;


// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

const float PI = 3.1415926;


/**
 * 2D Rotation 
 */
mat2 rotate2D(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat2(
        vec2(c, -s),
        vec2(s, c)
    );
}

void main()
{

    vec3 baseColor = vec3(1.0);
    

    // if(u_AnimationStage % 2 == 1){

        vec3 screenCol;

        // ------------------- 2D screen space mask --------------------
        // Normalized pixel coordinates (from 0 to 1)
        vec2 uv = gl_FragCoord.xy / vec2(u_Width, u_Height);
        
        vec2 scrPt = uv * 2.0 - 1.0; // Transform to NDC
        scrPt.x *= u_Width / u_Height; // Account for aspect ratio
        
        float partitationDegree = 0.6667 * PI;

        if(u_AnimationStage == 1){
            scrPt = rotate2D(-u_ScreenRot * partitationDegree) * scrPt;
        }
        else{
            scrPt = rotate2D(-(1.0 - u_ScreenRot) * partitationDegree) * scrPt;
        }

        float angle = atan(scrPt.y, scrPt.x) / 6.283185 + 0.5;
        
        // decide which portion this frag lies
        if(angle >= .25 && angle < .58333333333){
            screenCol = u_Color1;
        }
        else if(angle >= .58333333333 && angle < .91666666667){
            screenCol = u_Color2;
        }
        else{
            screenCol = u_Color3;
        }
    // }
    
    // int u_AnimationStage 0 & 2, just rotate the cube
    //else{
        if(fs_Nor.x != .0){
            baseColor = u_Color1;
        }
        else if(fs_Nor.y != .0){
            baseColor = u_Color2;
        }
        else if(fs_Nor.z != .0){
            baseColor = u_Color3;
        }
    //}

    int selection = u_AnimationStage % 2;

    out_Col = vec4((1.0 - float(selection)) * baseColor + float(selection) * screenCol, 1.0);
}
