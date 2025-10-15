#ifdef GL_ES
precision mediump float;
#endif

// #define PROCESSING_COLOR_SHADER

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_offset;
uniform float u_zoom;
// uniform int u_octaves;
// uniform float u_falloff;

// these inputs are for the individual gain and offsets for each pastel color
uniform float u_gain;
uniform float u_pedistal;
uniform vec3 u_color;


//================================================================
// Noise functions By Morgan McGuire @morgan3d, http://graphicscodex.com
// Reuse permitted under the BSD license.

// All noise functions are designed for values on integer scale.
// They are tuned to avoid visible periodicity for both positive and
// negative coordinates within a few orders of magnitude.

// For multiple octaves
#define NOISE fbm
#define NUM_NOISE_OCTAVES 9

// Precision-adjusted variations of https://www.shadertoy.com/view/4djSRW
float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }

//----------------------------------------------------------------

float noise(float x) {
  float i = floor(x);
  float f = fract(x);
  float u = f * f * (3.0 - 2.0 * f);
  return mix(hash(i), hash(i + 1.0), u);
}

float noise(vec2 x) {
  vec2 i = floor(x);
  vec2 f = fract(x);

  // Four corners in 2D of a tile
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));

  // Simple 2D lerp using smoothstep envelope between the values.
  // return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
  //      mix(c, d, smoothstep(0.0, 1.0, f.x)),
  //      smoothstep(0.0, 1.0, f.y)));

  // Same code, with the clamps in smoothstep and common subexpressions
  // optimized away.
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float noise(vec3 x) {
  const vec3 step = vec3(110, 241, 171);

  vec3 i = floor(x);
  vec3 f = fract(x);
 
  // For performance, compute the base input to a 1D hash from the integer part of the argument and the 
  // incremental change to the 1D based on the 3D -> 1D wrapping
  float n = dot(i, step);

  vec3 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),
           mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
         mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),
           mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);
}

//----------------------------------------------------------------

float fbm(float x) {
  float v = 0.0;
  float a = 0.5;
  float shift = 100.0;
  for (int i = 0; i < NUM_NOISE_OCTAVES; ++i) {
    v += a * noise(x);
    x = x * 2.0 + shift;
    a *= 0.5;
  }
  return v;
}

float fbm(vec2 x) {
  float v = 0.0;
  float a = 0.5;
  vec2 shift = vec2(100.0);
  // Rotate to reduce axial bias
  mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
  for (int i = 0; i < NUM_NOISE_OCTAVES; ++i) {
    v += a * noise(x);
    x = rot * x * 2.0 + shift;
    a *= 0.5;
  }
  return v;
}

float fbm(vec3 x) {
  float v = 0.0;
  float a = 0.5;
  vec3 shift = vec3(100.0);
  for (int i = 0; i < NUM_NOISE_OCTAVES; ++i) {
    v += a * noise(x);
    x = x * 2.0 + shift;
    a *= 0.5;
  }
  return v;
}

//================================================================
// SHAPERS

// sigmoid function adapted from
// https://www.flong.com/archive/texts/code/shapers_exp/index.html
float doubleExponentialSigmoid (float x, float a){

  float epsilon = 0.00001;
  float min_param_a = 0.0 + epsilon;
  float max_param_a = 1.0 - epsilon;
  a = clamp(a , min_param_a, max_param_a);
  a = 1.0 - a; // for sensible results

  float y = 0.0;

  if (x <= 0.5){
    y = (pow(2.0 * x, 1.0 / a)) / 2.0;
  } else {
    y = 1.0 - (pow(2.0 * (1.0 - x), 1.0 / a)) / 2.0;
  }

  return y;
}

float smoothstepSigmoid(float x, float center, float width){
  width = clamp(width, 0.0, 1.0);
  center = clamp(center, -1.0, 2.0);
  float start = clamp(center - width, 0.0, 1.0);
  float end = clamp(center + width, 0.0, 1.0);

  return smoothstep(start, end, x);
}

//  Function from Iñigo Quiles
//  www.iquilezles.org/www/articles/functions/functions.htm
float cubicPulse( float x , float center, float width){
  x = abs(x - center);
  if( x > width ) return 0.0;
  x /= width;
  return 1.0 - x * x * (3.0 - 2.0 * x);
}

//================================================================

vec2 zoom(vec2 coord, vec2 center, float factor){
  return (coord - center) * factor + center;
}

//================================================================

void main() {

  vec2 st = vec2(gl_FragCoord.x/u_resolution.x, gl_FragCoord.y/u_resolution.x);
  vec2 noiseZoomCenter = vec2(0.5, 0.5 * u_resolution.y / u_resolution.x);
  st = zoom(st, noiseZoomCenter, u_zoom);

  vec2 q = vec2(0.0);
  q.x = fbm( st + 0.01 * u_time);
  q.y = fbm( st + vec2(-3.70,2.705) - 0.01 * u_time);

  vec2 r = vec2(0.0);
  r.x = fbm( st + 1.0 * q + vec2(-1.570,2.430) + 0.01 * u_time);
  r.y = fbm( st + 1.0 * q + vec2(3.600,-4.610) + 0.01 * u_time);

  vec3 pos1 = vec3(st+r, u_offset);

  float alpha = clamp(fbm(pos1), 0, 1.0);

  vec4 color = vec4(u_color, cubicPulse(alpha, u_gain + u_pedistal, 0.05));

  gl_FragColor = vec4(color);
}

