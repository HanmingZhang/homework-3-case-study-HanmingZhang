import {vec3, vec4, mat4} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import Cube from './geometry/Cube';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';



// const ICOSPHERE = 'Icosphere';
const CUBE = 'Cube';
const SQUARE = 'Square';

// Two different scenes
const TRICUBE     = 'TriColoredCube';
const METABALL    = 'MetaBall';
const SPINDLEOFDEATH = 'SpindleOfDeath';
// const RAINBOWCUBE    = 'RainbowStepCube'; 

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  SceneSelect: TRICUBE,
};

let icosphere: Icosphere;
let square: Square;
let cube : Cube;

function loadScene() {
  // icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  // icosphere.create();

  cube = new Cube(vec3.fromValues(0, 0, 0));
  cube.create();

  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
}

// global variables used in tri-colored
let RED:    vec3;
let BLUE:   vec3;
let PURPLE: vec3;
let rotationMatrix: mat4;
let animationStage: number;


// Toolkit functions
function bias(b: number, t: number){
	return Math.pow(t, Math.log(b) / Math.log(0.5));
}

function gain(g: number, t: number){
  if(t < 0.5){
    return bias(1.0-g, 2.0*t) / 2.0
  }
  else{
    return 1.0 - bias(1.0-g, 2.0-2.0*t) / 2.0;
  }
}


function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  // Add controls to the gui
  const gui = new DAT.GUI();

  // Camera
  const camera = new Camera(vec3.fromValues(3, 3, 3), vec3.fromValues(0, 0, 0));

  // Open GL Renderer
  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.9, 0.9, 0.9, 1);
  gl.enable(gl.DEPTH_TEST);

  // -------------------------------------------------
  // setup TRICUBE shader
  const triCube = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/tricube-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/tricube-frag.glsl')),
  ]);

  // setup tricube colors
  RED    = vec3.fromValues(232.0 / 255.0, 78.0  / 255.0, 128.0 / 255.0);
  BLUE   = vec3.fromValues(169.0 / 255.0, 217.0 / 255.0, 198.0 / 255.0);
  PURPLE = vec3.fromValues(81.0  / 255.0, 65.0  / 255.0, 96.0  / 238.0);
 
  // set up tricube animation info
  rotationMatrix = mat4.create();
  animationStage = 0;
  var tmpCounter = 0.0;

  triCube.setCubeColors(PURPLE, RED, BLUE);
  triCube.setAnimationStage(animationStage);


  // -------------------------------------------------
  // setup RAINBOWCUBE shader
  // const rainbowCube = new ShaderProgram([
  //   new Shader(gl.VERTEX_SHADER, require('./shaders/rainbowcube-vert.glsl')),
  //   new Shader(gl.FRAGMENT_SHADER, require('./shaders/rainbowcube-frag.glsl')),
  // ]);

  // -------------------------------------------------
  // setup METABALL shader
  const metaBall = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/metaball-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/metaball-frag.glsl')),
  ]);


  // --------------------------------------------------
  // setup spindle of death shader
  const spindleOfDeath = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/spindleofdeath-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/spindleofdeath-frag.glsl')),
  ]);


  // function setSceneSelect(){
  //   switch(controls.SceneSelect) {
  //       case TRICUBE:
  //         sceneSelect = 0.0;
  //         time = 0.0;
  //         break;
  //       case RAINBOWCUBE:
  //         sceneSelect = 1.0;
  //         time = 0.0;
  //         break;
  //     }
  // }

  // gui.add(controls, 'SceneSelect', [TRICUBE, SPINDLEOFDEATH, METABALL, RAINBOWCUBE]);
  gui.add(controls, 'SceneSelect', [TRICUBE, SPINDLEOFDEATH, METABALL]);
  

  // setup timer;
  var timer = 0.0;

  var gain_g = 0.9;
  camera.update();
  
  // This function will be called every frame
  function tick() {
    // camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);

    timer += 1.0;
    if(timer > 10000.0){
      timer -= 10000.0;
    }
 

    if(controls.SceneSelect == TRICUBE){
      // Update animation info
      // tmp counter should always be 0 -> 1
      tmpCounter += 0.012;

      // ------------ Tri Cube animation phase 0 ----------
      if(animationStage == 0){
        // rotate angle
        let rotationAngle = gain(gain_g, Math.min(tmpCounter, 1.0)) * (0.5 * 3.1415926);

        mat4.identity(rotationMatrix);
        mat4.rotateZ(rotationMatrix, rotationMatrix, rotationAngle);
        triCube.setModelMatrix(rotationMatrix);

        // render
        renderer.clear();
        renderer.render(camera, triCube, [
          cube,
        ]);

        // Move to next animation stage
        if(tmpCounter >= 1.0){
          // reset variables
          mat4.identity(rotationMatrix);
          tmpCounter = 0.0;
          animationStage = 1;

          triCube.setCubeColors(RED, PURPLE, BLUE);
          triCube.setAnimationStage(animationStage);
        }
      }
      // ------------ Tri Cube animation phase 1 ----------
      else if(animationStage == 1){
        // screen space rotation angle
        let screenRotationAngle = gain(gain_g, Math.min(tmpCounter, 1.0));

        triCube.setModelMatrix(rotationMatrix);
        triCube.setScreenRot(screenRotationAngle);
        
        // render
        renderer.clear();
        renderer.render(camera, triCube, [
          cube,
        ]);

        // Move to next animation stage
        if(tmpCounter >= 1.0){
          // reset variables
          tmpCounter = 0.0;
          animationStage = 2;

          triCube.setCubeColors(PURPLE, BLUE, RED);
          triCube.setAnimationStage(animationStage);
        }
      }
      // ------------ Tri Cube animation phase 2 ----------
      else if(animationStage == 2){
        // rotation angle (reverse, so negative)
        let rotationAngle = -gain(gain_g, Math.min(tmpCounter, 1.0)) * (0.5 * 3.1415926);

        mat4.identity(rotationMatrix);
        mat4.rotateY(rotationMatrix, rotationMatrix, rotationAngle);
        triCube.setModelMatrix(rotationMatrix);

        // render
        renderer.clear();
        renderer.render(camera, triCube, [
          cube,
        ]);

        // Move to next animation stage
        if(tmpCounter >= 1.0){
          // reset vaiables
          mat4.identity(rotationMatrix);
          tmpCounter = 0.0;
          animationStage = 3;

          triCube.setCubeColors(PURPLE, RED, BLUE);
          triCube.setAnimationStage(animationStage);
        }
      }
      // ------------ Tri Cube animation phase 3 ----------
      else if(animationStage == 3){
        // screen space rotation angle
        let screenRotationAngle = gain(gain_g, Math.min(tmpCounter, 1.0));
        
        triCube.setModelMatrix(rotationMatrix);
        triCube.setScreenRot(screenRotationAngle);
        
        // render
        renderer.clear();
        renderer.render(camera, triCube, [
          cube,
        ]);

        // Move to next animation stage
        if(tmpCounter >= 1.0){
          // reset variables
          tmpCounter = 0.0;
          animationStage = 0;

          triCube.setCubeColors(PURPLE, RED, BLUE);
          triCube.setAnimationStage(animationStage);
        }
      }
    }


    // else if(controls.SceneSelect == RAINBOWCUBE){
    //   rainbowCube.setTimer(timer / 50.0); 

    //   renderer.clear();
    //   renderer.render(camera, rainbowCube, [
    //     square,
    //   ]);
    // }


    else if(controls.SceneSelect == METABALL){
        metaBall.setTimer(timer / 50.0); 
      
        renderer.clear();
        renderer.render(camera, metaBall, [
          square,
        ]);
    }

    else if(controls.SceneSelect == SPINDLEOFDEATH){
        spindleOfDeath.setTimer(timer / 50.0); 
      
        renderer.clear();
        renderer.render(camera, spindleOfDeath, [
          square,
        ]);
    }

    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();

    triCube.setResolution(window.innerWidth, window.innerHeight);
    // rainbowCube.setResolution(window.innerWidth, window.innerHeight);
    metaBall.setResolution(window.innerWidth, window.innerHeight);
    spindleOfDeath.setResolution(window.innerWidth, window.innerHeight);
    
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  triCube.setResolution(window.innerWidth, window.innerHeight);
  // rainbowCube.setResolution(window.innerWidth, window.innerHeight);
  metaBall.setResolution(window.innerWidth, window.innerHeight);
  spindleOfDeath.setResolution(window.innerWidth, window.innerHeight);
  
  
  // Start the render loop
  tick();
}

main();
