#include <flutter/runtime_effect.glsl>

uniform vec4 color;
uniform vec2 startpos;
uniform float time;
uniform float successf;
uniform vec2 offset;

out vec4 fragColor;

void main() {
    bool success = successf > 0.5;
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
    fragColor = color;
    if(success){
        fragColor.g = 1.0;
    } else {
        fragColor.r = 1.0;
         fragColor.g = color.g * 0.5;
         fragColor.b = color.b * 0.5;
    }
}