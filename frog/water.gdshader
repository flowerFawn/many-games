shader_type canvas_item;
uniform float mid_wave;
uniform float wave_height;
uniform float frequency;
uniform float waves;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//if uv.y is lower (so visibly above) then make invisible
	//+ .5 is middle of wave (sin(x) = 0), c
	//c * sin (x) then makes it +c (so 2c) at peak and -c (so 0) at pits
	if (UV.y < mid_wave + (wave_height * sin((TIME * frequency) + (UV.x * waves)))){
		COLOR.a = 0.0;
	}
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
