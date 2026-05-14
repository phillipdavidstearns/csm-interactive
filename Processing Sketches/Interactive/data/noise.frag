#define PROCESSING_COLOR_SHADER

#ifdef GL_ES
precision mediump float;
#endif

// #define PROCESSING_COLOR_SHADER

uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 u_offset;

uniform vec3 u_wind;

uniform float u_amp;

uniform float u_zoom;
uniform float u_warp;

// gain and offsets for each pastel color
uniform vec3 u_color;

// shaping function controls for alpha mask
uniform float u_center;
uniform float u_width;

// for brightening edges of clouds and darkening centers
uniform float u_darken;
uniform float u_brighten;


uniform float u_brightness;
uniform float u_contrast;
uniform float u_saturation;

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
  mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5));
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
// From: https://github.com/SableRaf/Filters4Processing/blob/master/sketches/ContrastSaturationBrightness/data/ContrastSaturationBrightness.glsl

/*
** Contrast, saturation, brightness
** Code of this function is from TGM's shader pack
** http://irrlicht.sourceforge.net/phpBB2/viewtopic.php?t=21057
*/

// For all settings: 1.0 = 100% 0.5=50% 1.5 = 150%
vec3 ContrastSaturationBrightness(vec3 color, float brt, float sat, float con)
{
  // Increase or decrease theese values to adjust r, g and b color channels seperately
  const float AvgLumR = 0.5;
  const float AvgLumG = 0.5;
  const float AvgLumB = 0.5;

  const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);

  vec3 AvgLumin  = vec3(AvgLumR, AvgLumG, AvgLumB);
  vec3 brtColor  = color * brt;
  vec3 intensity = vec3(dot(brtColor, LumCoeff));
  vec3 satColor  = mix(intensity, brtColor, sat);
  vec3 conColor  = mix(AvgLumin, satColor, con);

  return conColor;
}

//================================================================


void main() {

  // scale the coordinate system and connect aspect ratio "squishing"
  vec2 st = vec2(gl_FragCoord.x/u_resolution.x, gl_FragCoord.y/u_resolution.x);

  // zoom effect acheived by scaling st coordinates
  vec2 noiseZoomCenter = vec2(0.5, 0.5 * u_resolution.y / u_resolution.x);
  st = zoom(st, noiseZoomCenter, u_zoom);

  // this shifts the st coordinates by a fixed amount, u_time moves in z axis
  // produces an 2D fbm noise map
  vec2 q = vec2(0.0);

  q.x = fbm( vec3(
    st.x - 1.013,
    st.y + 0.512,
    0.01 * u_time
  ));

  q.y = fbm( vec3(
    st.x + 2.705,
    st.y - 3.561,
    0.01 * u_time
  ));

  // again, u_time moves in z axis
  // uses the above fbm as a warped ST domain 2D fbm noise map
  vec2 r = vec2(0.0);

  r.x = fbm( vec3(
    st.x + u_warp * q.x + u_wind.x,
    st.y + u_warp * q.y + u_wind.y,
    0.01 * u_time + u_wind.z
  ));

  r.y = fbm( vec3(
    st.x + u_warp * q.x,
    st.y + u_warp * q.y,
    0.01 * u_time
  ));

  //warp the original coordinates by multiplying by the warped domain
  st *= r;

  vec3 pos1 = vec3(u_offset.x + st.x, u_offset.y + st.y, u_offset.z );

  float alpha = clamp(fbm(pos1), 0, 1.0);

  alpha = cubicPulse(alpha*alpha, u_center + u_amp, u_width);

  vec3 darker = u_color * (1 - u_darken * alpha);

  vec3 brighter = clamp(u_color + u_brighten * (1 - alpha), 0, 1.0);

  vec3 color = mix(
    darker, brighter, 0.5
  );

  gl_FragColor = vec4(ContrastSaturationBrightness(
    color, u_brightness, u_saturation, u_contrast
  ), alpha);
}

