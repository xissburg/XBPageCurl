precision mediump float;

uniform sampler2D s_tex;
uniform sampler2D s_gradient;
varying vec2 v_texCoord;
varying vec2 v_gradientTexCoord;
varying vec3 v_normal;

void main()
{
    vec4 color = texture2D(s_tex, v_texCoord);
    vec4 gradient = texture2D(s_gradient, v_gradientTexCoord);
    vec4 backColor = vec4(color.rgb*(1.0 - gradient.a) + gradient.rgb, color.a); // premultiplied alpha
    
    vec3 n = normalize(v_normal);
    vec4 frontColor = vec4(color.rgb*n.z, color.a);

    gl_FragColor = mix(backColor, frontColor, float(gl_FrontFacing));
}
