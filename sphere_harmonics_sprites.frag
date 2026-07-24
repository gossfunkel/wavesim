#version 430

in vec2 texcoord;
uniform float osg_FrameTime;
uniform sampler2D p3d_Texture0;
uniform uint num_sprites;

layout (std430, binding = 0) buffer sprite_buff {
    vec3 pos[];
};

out vec4 p3d_FragColor;
flat in uint sprite_idx;

void main() {
    vec4 col_sample = texture(p3d_Texture0, texcoord);
    col_sample.x *= mod(float(sprite_idx)/float(num_sprites) + .5, 1.);
    col_sample.y *= mod(.25 + float(sprite_idx)/float(num_sprites) + .5, 1.);
    col_sample.z *= mod(.75 + float(sprite_idx)/float(num_sprites) + .5, 1.);
    //col_sample.y *= sin(osg_FrameTime*2. + sprite_idx);
    //col_sample.z *= -sin(osg_FrameTime*3. + sprite_idx);
    p3d_FragColor = col_sample;
}