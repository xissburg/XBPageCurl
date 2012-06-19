precision mediump float;

uniform sampler2D s_tex;
varying vec2 v_texCoord;
varying vec3 v_normal;

void main()
{
    vec4 color = texture2D(s_tex, v_texCoord);
    vec3 n = normalize(v_normal);
    float fFrontFacing = float(gl_FrontFacing);
    float l = n.z * (fFrontFacing*2.0 - 1.0);
    gl_FragColor = vec4(color.rgb * l, color.a);
}
