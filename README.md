# CIS-566-Project-3

- Name : Hanming Zhang
- Pennkey : hanming

## [Demo Link](https://hanmingzhang.github.io/homework-3-case-study-HanmingZhang/)


- Tri-colored Cube : The basic idea is that 3D cube and 2D(divided by three portions) take turns to render the scene. After each rotation phase, update three colors so that they can perfectly match in next phase and creat a nice vision. Since it's hard to decide which face of a cube a ray intersects if a cube keeps rotating, I use a rasterization method to control and render the cube.

- Paw Metaballs : I refer a lot from this ([Cell Merge with Metaballs](https://www.shadertoy.com/view/MllXDH)).The idea is relative simple. I create eight circles osccillating back and front and accumulate a metaball formular value. Finally, use raymarching and just paint the pixel under certain threshold to create metaballs.

- Spindle of Death : I use Torus SDF from IQ to create the wireframe and sphere SDF to create white dots. Tool functions are used to control the move and pause of camera. The moving of runing spheres are just union of some spheres and add increasing delay for each of them to create the final effect. 



## Resources
- Javascript modules https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import
- Typescript https://www.typescriptlang.org/docs/home.html
- dat.gui https://workshop.chromeexperiments.com/examples/gui/
- glMatrix http://glmatrix.net/docs/
- WebGL
  - Interfaces https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API
  - Types https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Types
  - Constants https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Constants
