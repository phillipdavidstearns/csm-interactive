#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec4 vertTexCoord;
uniform sampler2D texture;
uniform float u_alpha;
uniform float u_centerX;
uniform float u_centerY;
uniform float u_feedbackZoom;

// //================================================================

vec2 zoom(vec2 coord, vec2 center, float factor){
  return (coord - center) * factor + center;
}

// //================================================================

void main ()
{
    // Sample the input pixel
    vec2 p = vertTexCoord.st;
    vec2 feedbackZoomCenter = vec2(u_centerX, u_centerY);
    vec2 zoomed = zoom(p, feedbackZoomCenter, u_feedbackZoom);
    vec4 color = texture2D(texture, zoomed).rgba;
    color.a = u_alpha;

    gl_FragColor    = color;
}