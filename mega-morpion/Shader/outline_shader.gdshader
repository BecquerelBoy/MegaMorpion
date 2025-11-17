shader_type canvas_item;

uniform bool show_outline = false;
uniform vec4 outline_color : source_color = vec4(1.0, 0.8, 0.0, 1.0); // Jaune/orange par défaut
uniform float outline_width : hint_range(0.0, 20.0) = 5.0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	
	if (show_outline) {
		// Calculer la distance au bord
		vec2 size = vec2(textureSize(TEXTURE, 0));
		vec2 pixel_uv = UV * size;
		
		// Vérifier si on est près du bord
		float dist_left = pixel_uv.x;
		float dist_right = size.x - pixel_uv.x;
		float dist_top = pixel_uv.y;
		float dist_bottom = size.y - pixel_uv.y;
		
		float min_dist = min(min(dist_left, dist_right), min(dist_top, dist_bottom));
		
		// Si on est dans la zone de contour
		if (min_dist < outline_width) {
			// Mélanger avec la couleur du contour
			float outline_strength = 1.0 - (min_dist / outline_width);
			COLOR = mix(original_color, outline_color, outline_strength * outline_color.a);
		} else {
			COLOR = original_color;
		}
	} else {
		COLOR = original_color;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
