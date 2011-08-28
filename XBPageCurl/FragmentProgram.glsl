precision mediump float;

uniform sampler2D s_tex;
uniform lowp vec2 u_texSize;
varying lowp vec4 v_color;
varying lowp vec2 v_texCoord;
varying lowp vec3 v_normal;

void main()
{
    vec3 n = normalize(v_normal);
    gl_FragColor = texture2D(s_tex, v_texCoord/u_texSize) * n.z;
}
