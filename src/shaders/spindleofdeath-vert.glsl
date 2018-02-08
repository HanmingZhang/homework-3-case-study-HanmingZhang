#version 300 es

precision highp float;

in vec4 vs_Pos;

void main() {
	// this is a raymarching cube,
	// just pass in a square plane

	gl_Position = vs_Pos;
}

