// Blue light reduction shader (warm tint)
precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
void main() {
    vec4 color = texture2D(tex, v_texcoord);
    color.b = color.b * 0.8;
    color.g = color.g * 0.95;
    gl_FragColor = color;
}
