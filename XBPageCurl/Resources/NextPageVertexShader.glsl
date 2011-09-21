
uniform mat4 u_mvpMatrix;
uniform vec2 u_texSize;

attribute vec4 a_position;
attribute vec2 a_texCoord;

varying vec2 v_texCoord;


void main()
{
    gl_Position = u_mvpMatrix * a_position;
    v_texCoord = a_texCoord/u_texSize;
}

