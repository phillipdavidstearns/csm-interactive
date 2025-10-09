#ifdef GL_ES
precision mediump float;
#endif

#define PROCESSING_COLOR_SHADER

uniform sampler2D u_texture;
uniform vec2 u_resolution;
uniform float u_time;
uniform float u_offset;
uniform float u_zoom;

// these inputs are for the individual gain and offsets for each pastel color
uniform float u_gain1;
uniform float u_gain2;
uniform float u_gain3;
uniform float u_gain4;
uniform float u_pedistal1;
uniform float u_pedistal2;
uniform float u_pedistal3;
uniform float u_pedistal4;
uniform vec4 u_background;
uniform vec4 u_palette[8];
uniform int u_paletteLength;

// By Morgan McGuire @morgan3d, http://graphicscodex.com
// Reuse permitted under the BSD license.

// All noise functions are designed for values on integer scale.
// They are tuned to avoid visible periodicity for both positive and
// negative coordinates within a few orders of magnitude.

// For a single octave
//#define NOISE noise

// For multiple octaves
#define NOISE fbm
#define NUM_NOISE_OCTAVES 5

// Precision-adjusted variations of https://www.shadertoy.com/view/4djSRW
float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }

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
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

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

void main() {
	vec4 feedback = vec4(0.0);
	vec2 uv = gl_FragCoord.xy/u_resolution.xy;
    vec2 u_zoomCenter = vec2(0.5);
	vec2 zoomedUV = (uv - u_zoomCenter) * u_zoom + u_zoomCenter;
    feedback = texture2D(u_texture, zoomedUV);

	// Scale the coordinate system to see
    // some noise in action
    vec2 st = vec2(gl_FragCoord.x/u_resolution.x, gl_FragCoord.y/u_resolution.x);
    vec3 pos = vec3(st*5.0, u_offset);

    float mixAmount1 = clamp(u_gain1 * NOISE(pos + vec3(0, 0, 1 + u_time)) + u_pedistal1, 0.0, 1.0);
	float mixAmount2 = clamp(u_gain2 * NOISE(pos + vec3(0, 0, 2 + u_time)) + u_pedistal2, 0.0, 1.0);
	float mixAmount3 = clamp(u_gain3 * NOISE(pos + vec3(0, 0, 3 + u_time)) + u_pedistal3, 0.0, 1.0);
	float mixAmount4 = clamp(u_gain4 * NOISE(pos + vec3(0, 0, 4 + u_time)) + u_pedistal4, 0.0, 1.0);

	vec4 layer1 = mix(u_background, u_palette[0], mixAmount1);	
	vec4 layer2 = mix(layer1, u_palette[1], mixAmount2);
	vec4 layer3 = mix(layer2, u_palette[2], mixAmount3);
	vec4 layer4 = mix(layer3, feedback, mixAmount4 > 0.5 ? 1.0 : 0.0);

	gl_FragColor = layer4;
}

