shader_type spatial;

uniform vec4 new_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float selection_amount : hint_range(0.0, 1.0) = 0.1;

void fragment()
{
	ALBEDO = new_color.rgb;
	ALPHA = selection_amount;
}