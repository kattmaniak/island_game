#include <flutter/runtime_effect.glsl>

uniform vec4 color;
uniform vec2 startpos;
uniform float time;
uniform float successf;
uniform vec2 offset;

out vec4 fragColor;

void main() {
    if(time == 0.0) {
        fragColor = color;
        return;
    }
    vec2 pos = FlutterFragCoord().xy + offset;
    vec2 dir = pos - startpos;
    float dist = length(dir);

    if(time/dist < 0.01){
        fragColor = color;
        return;
    }

    vec4 resultColor = mix(vec4(1.0, 0.0, 0.0, 1.0), vec4(0.0, 1.0, 0.0, 1.0), successf);
    fragColor = mix(resultColor, color, 0.2);
}