extends Control

# --- CONFIGURACIÓN DE PUNTOS ---
# Ajusta estos Vectores (x, y) para que coincidan con la forma de tu mapa
# Recuerda: (0,0) es la esquina arriba-izquierda de tu ventanita MonitorUI
var puntos = {
	"INICIO": Vector2(100, 180),   # Abajo centro
	"NODO_1": Vector2(160, 140),   # Derecha abajo
	"NODO_2": Vector2(160, 60),    # Derecha arriba
	"SALIDA": Vector2(100, 20),    # Arriba centro (Meta)
	
	# Nodos "distractores" del lado izquierdo (para que se vea completo el grafo)
	"IZQ_1": Vector2(40, 140),
	"IZQ_2": Vector2(40, 60)
}

# Definimos los tramos del camino CORRECTO en orden
var tramos_camino = [
	["INICIO", "NODO_1"],  # Tramo 1
	["NODO_1", "NODO_2"],  # Tramo 2
	["NODO_2", "SALIDA"]   # Tramo 3
]

var progreso_actual = 0 # 0 = Apagado, 1 = Primer tramo, etc.

func _draw():
	# 1. DIBUJAR EL FONDO (La red apagada)
	# Dibujamos líneas grises conectando todo para que parezca un mapa
	var color_apagado = Color(0.3, 0.3, 0.3, 1.0) # Gris oscuro
	
	# Conexiones decorativas (Izquierda)
	draw_line(puntos["INICIO"], puntos["IZQ_1"], color_apagado, 2.0)
	draw_line(puntos["IZQ_1"], puntos["IZQ_2"], color_apagado, 2.0)
	draw_line(puntos["IZQ_2"], puntos["SALIDA"], color_apagado, 2.0)
	
	# Conexiones del camino correcto (apagadas por ahora)
	for tramo in tramos_camino:
		draw_line(puntos[tramo[0]], puntos[tramo[1]], color_apagado, 2.0)

	# 2. DIBUJAR EL CAMINO "ALUMBRADO" (Según progreso)
	var color_neon = Color(0.2, 1.0, 0.2, 1.0) # Verde brillante
	var color_brillo = Color(0.2, 1.0, 0.2, 0.3) # Verde transparente para el "Glow"
	
	for i in range(progreso_actual):
		if i < tramos_camino.size():
			var p_inicio = puntos[tramos_camino[i][0]]
			var p_fin = puntos[tramos_camino[i][1]]
			
			# TRUCO DE BRILLO:
			# Dibujamos una línea muy gorda y transparente abajo
			draw_line(p_inicio, p_fin, color_brillo, 8.0) 
			# Y una línea sólida normal encima
			draw_line(p_inicio, p_fin, color_neon, 3.0)

	# 3. DIBUJAR NODOS (Puntos)
	for nombre_punto in puntos:
		var pos = puntos[nombre_punto]
		var color_nodo = Color.RED # Por defecto rojo (infectado)
		
		# Lógica para cambiar a verde si el camino ya pasó por aquí
		# (Esto es una simplificación visual)
		if progreso_actual >= 1 and (nombre_punto == "INICIO" or nombre_punto == "NODO_1"):
			color_nodo = Color.GREEN
		if progreso_actual >= 2 and nombre_punto == "NODO_2":
			color_nodo = Color.GREEN
		if progreso_actual >= 3 and nombre_punto == "SALIDA":
			color_nodo = Color.GREEN
			
		draw_circle(pos, 5.0, color_nodo)

# Esta función la llama el Nivel cuando matas un fantasma clave
func avanzar_camino():
	progreso_actual += 1
	queue_redraw() # <--- ESTO ES LA CLAVE: Fuerza a redibujar todo con los nuevos colores
