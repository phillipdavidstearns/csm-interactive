#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec4 vertTexCoord;
uniform sampler2D texture;
uniform float u_alpha;
uniform vec2 u_c_fb; // feedback center coords
uniform vec2 u_c_rot; // rotation center coords
uniform float u_feedbackZoom; // scale amount
uniform float u_rotation;

//================================================================

mat2 scale(vec2 _scale){
  return mat2(
    _scale.x, 0.0,
    0.0, _scale.y
  );
}

//================================================================
// pulled from the book of shaders
// https://thebookofshaders.com/08/

mat2 rotate2d(float _angle){
  return mat2(
    cos(_angle), -sin(_angle),
    sin(_angle), cos(_angle)
  );
}

//================================================================

void main ()
{
    // Sample the input pixel
    vec2 st = vertTexCoord.st;

    //apply rotation matrix to st coords
    st -= u_c_rot;
    st *= rotate2d(u_rotation);
    st += u_c_rot;

    //apply scale matrix to st coords
    st -= u_c_fb;
    st *= scale(vec2(u_feedbackZoom,u_feedbackZoom));
    st += u_c_fb;

    vec4 color = texture2D(texture, st).rgba;
    color.a = u_alpha;
    gl_FragColor = color;
}