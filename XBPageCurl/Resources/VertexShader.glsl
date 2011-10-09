
uniform mat4 u_mvpMatrix;

attribute vec4 a_position;
attribute vec2 a_texCoord;

uniform vec2 u_texSize;
uniform vec2 u_cylinderPosition;
uniform vec2 u_cylinderDirection;
uniform float u_cylinderRadius;

varying vec2 v_texCoord;
varying vec3 v_normal;

#define M_PI 3.14159265358979323846264338327950288

void main()
{
    vec4 v = a_position;
    vec2 n = vec2(u_cylinderDirection.y, -u_cylinderDirection.x);
    vec2 w = v.xy - u_cylinderPosition;
    float d = dot(w, n);
    v_normal = vec3(0.0, 0.0, 1.0);

    //vertices after the cylinder
    if (d > 0.0) {
        //vertices that should pass over the cylinder
        if (d > M_PI*u_cylinderRadius) {
            vec2 dv = n * (2.0*d - M_PI*u_cylinderRadius);
            v.xy -=  dv;
            v.z = 2.0*u_cylinderRadius;
            v_normal = vec3(0.0, 0.0, -1.0);
        }
        //vertices that should be projected on the half of the cylinder
        else {
            float dr = d/u_cylinderRadius;//projection angle
            float s = sin(dr);
            float c = cos(dr);
            vec2 proj = v.xy - n*d;//projection of vertex on the cylinder axis projected on the xy plane
            v.xyz = vec3(s*n.x, s*n.y, 1.0 - c)*u_cylinderRadius;
            v.xy += proj;
            vec3 center = vec3(proj, u_cylinderRadius);
            v_normal = (center - v.xyz)/u_cylinderRadius;
            /*
            if (dr < M_PI/2.0) { //lower part of curl
                v_normal = -v_normal;
            }*/
        }

    }

    gl_Position = u_mvpMatrix * v;
    v_texCoord = a_texCoord/u_texSize;
}
