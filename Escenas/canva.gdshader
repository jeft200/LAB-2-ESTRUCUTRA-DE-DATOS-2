shader_type canvas_item;

void fragment() {
    // Calcula la distancia desde el centro (0.5, 0.5)
    float dist = distance(UV, vec2(0.5));
    
    // Si la distancia es mayor a 0.5 (el radio), hazlo invisible
    if (dist > 0.5) {
        COLOR.a = 0.0;
    }
}