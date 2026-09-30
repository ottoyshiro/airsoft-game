shader_type canvas_item;

uniform sampler2D screen_texture :
	hint_screen_texture,
	repeat_disable,
	filter_nearest;

uniform bool enabled = false;

uniform float shake_power = 0.03;
uniform float shake_rate = 0.2;
uniform float shake_speed = 5.0;
uniform float shake_block_size = 30.5;
uniform float shake_color_rate = 0.01;

float random(float seed)
{
	return fract(
		543.2543 *
		sin(
			dot(
				vec2(seed, seed),
				vec2(3525.46, -54.3415)
			)
		)
	);
}

void fragment()
{
	vec2 uv = SCREEN_UV;

	if (enabled)
	{
		float enable_shift = float(
			random(trunc(TIME * shake_speed))
			< shake_rate
		);

		uv.x += (
			random(
				(
					trunc(
						SCREEN_UV.y
						* shake_block_size
					)
					/ shake_block_size
				)
				+ TIME
			) - 0.5
		) * shake_power * enable_shift;
	}

	vec4 pixel_color =
		texture(screen_texture, uv);

	if (enabled)
	{
		pixel_color.r = mix(
			pixel_color.r,
			texture(
				screen_texture,
				uv + vec2(
					shake_color_rate,
					0.0
				)
			).r,
			1.0
		);

		pixel_color.b = mix(
			pixel_color.b,
			texture(
				screen_texture,
				uv + vec2(
					-shake_color_rate,
					0.0
				)
			).b,
			1.0
		);
	}

	COLOR = pixel_color;
}