shader_type canvas_item;
uniform int frame_size;
uniform int frames;
uniform float anim_time;

void fragment(){
	ivec2 texsize = textureSize(TEXTURE,0);
	float uv_frame_size = float(frame_size) / float(texsize.x);
	float frame_time = anim_time / float(frames);
	float time = mod(TIME, anim_time);
	float frame = floor(time / frame_time);

	vec2 uv = vec2(UV.x + (uv_frame_size*frame), UV.y);
	COLOR = texture(TEXTURE, uv);
}

