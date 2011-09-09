precision mediump float;

uniform sampler2D s_tex;
varying vec4 v_color;
varying vec2 v_texCoord;
varying vec3 v_normal;

void main()
{
    vec3 n = normalize(v_normal);
    
    gl_FragColor = vec4(texture2D(s_tex, v_texCoord).rgb * (n.z * (float(gl_FrontFacing)-0.5)*2.0), 1.0);
}
