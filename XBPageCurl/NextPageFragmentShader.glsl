precision mediump float;

uniform sampler2D s_tex;
varying vec2 v_texCoord;

void main()
{
    gl_FragColor = vec4(texture2D(s_tex, v_texCoord).rgb, 1.0);
}
