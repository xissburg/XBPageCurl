precision mediump float;

uniform sampler2D s_tex;
varying vec2 v_texCoord;
varying vec3 v_normal;

void main()
{
    vec3 n = normalize(v_normal);
    float fFrontFacing = float(gl_FrontFacing);
    vec4 color = texture2D(s_tex, v_texCoord);
    gl_FragColor = vec4(color.rgb * (n.z * (fFrontFacing-0.5)*2.0) + vec3(0.1,0.1,0.1)*(1.0-fFrontFacing), color.a);
}
