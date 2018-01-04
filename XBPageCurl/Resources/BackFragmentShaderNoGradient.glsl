precision mediump float;

uniform sampler2D s_tex;
uniform sampler2D s_gradient;
varying vec2 v_texCoord;
varying vec2 v_gradientTexCoord;

void main()
{
    vec4 color = texture2D(s_tex, v_texCoord);
    gl_FragColor = color;
}
