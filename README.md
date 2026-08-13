# Speed Runner

Proyecto de un juego de plataformas y movimiento rapido desarrollado en Godot 4.7.

## Ejecutar el proyecto

1. Abrir la carpeta `speed-runner` desde Godot.
2. Ejecutar el proyecto con `F6` para probar la escena actual o `F5` para iniciar desde el menu principal.

La escena inicial configurada es `Menu/Main_menu.tscn`.

## Controles actuales

| Accion | Tecla o boton |
| --- | --- |
| Moverse | W / A / S / D |
| Saltar | Barra espaciadora |
| Correr | Shift |
| Agacharse / deslizarse | Ctrl o C |
| Dash | Boton derecho del raton |
| Grapple | Boton izquierdo del raton |
| Zoom | Z |
| Liberar o recuperar el raton | Esc |

## Escenas de menu

- `Menu/Main_menu.tscn`: menu principal.
- `Menu/Ranking_menu.tscn`: ranking local, actualmente preparado para leer `user://ranking.json`.
- `Menu/Victory_menu.tscn`: pantalla de victoria con tres tiempos mockup.
- `Menu/Defeat_menu.tscn`: pantalla de derrota.

El guardado real de tiempos todavia no esta conectado al gameplay.
