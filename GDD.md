# **Game Design Document — Speed-run**

---

## **1\. Gameplay Core**

### **1.1 Core Loop**

> El jugador avanza hasta la meta, esquivando obstáculos, haciendo parkour, eliminando enemigos, con el objetivo de llegar a la meta en el menor tiempo posible. Los niveles cuentan con un alto nivel de dificultad y mucho espacio para la habilidad. Los jugadores buscan la mejor forma de recortar su tiempo, ya sea encontrando caminos secundarios o afilando sus habilidades. Al terminar el nivel, se muestra un ranking con el nombre de los jugadores que alcanzaron el mejor tiempo. 

### **1.2 Mecánicas Principales**

| Mecánica | Descripción |
| ----- | ----- |
| Sistema de movimiento “fluido” | El movimiento del jugador debe ser veloz y fluido. Cada movimiento se conecta con el siguiente. El jugador mantiene su inercia, recompensando el juego rápido sin pausas. |
| Dash | El jugador puede realizar un dash, ganando velocidad y permitiendo esquivar obstáculos y cambiar de dirección en el aire. Tiene un cooldown. |
| Wallrun | El jugador puede correr por las paredes por un tiempo limitado. Para hacerlo solo debe acercarse a la pared cuando está en el aire.  |
| Doble Salto | El jugador cuenta con un segundo salto que puede realizar en el aire. Le permite ganar más altura, ajustar su trayectoria o cambiar de dirección en el aire. |
| Arma | El jugador cuenta con un arma de fuego para disparar a los enemigos y objetos destruibles. |
| Enemigos | Enemigos en el mapa que disparan al jugador. Dan un bonus de velocidad al ser destruidos |
| Objetos destructibles | Se encuentran por el mapa y se destruyen al ser disparados, permitiendo el paso del jugador. |
| Obstáculos / plataformas móviles | Obstáculos y plataformas que se mueven, por ejemplo, de lado a lado. |

### **1.3 Controles**

| Acción | Input (PC) |
| ----- | ----- |
| Movimiento | W/A/S/D |
| Saltar / Doble Salto | Barra espaciadora |
| Agacharse / Deslizarse | Ctrl o C |
| Volar | F |
| Dash | Click derecho del ratón |
| Grapple / Gancho | Click izquierdo del ratón |
| Zoom | Z |
| Liberar o recuperar el ratón | Esc |

### **1.4 Objetivos del Jugador**

* **Corto plazo:** Esquivar los obstáculos y avanzar   
* **Mediano plazo:** Llegar hasta la meta  
* **Largo plazo:** Conseguir el mejor tiempo posible

### **1.5 Condiciones de Victoria/Derrota**

* Victoria: llegar a la meta  
* Derrota:   
  * Caerse a la lava, vacío o lo que haya si te caes del mapa.  
  * Ser alcanzado por un proyectil

### **1.6 Curva de Dificultad**

> El juego no aumenta la dificultad por si dicho, sino que el jugador siempre desafiará sus propias habilidades para querer mejorar su tiempo, tomando caminos más riesgosos, tomando menos tiempo para medir sus saltos, etc.

---

## **2\. Sistemas de Juego**

### **2.1 Combate**

* **Sistema de daño:** El sistema de daño es muy directo, tanto los enemigos como el jugador mueren de un disparo.  
* **Stats relevantes:**  
* **IA enemiga:** Los enemigos no cuentan con un sistema de pathfinding, ya que estos se mantienen inmóviles.   
* **Tipos de enemigos:**   
  * **Enemigo pacifico:** Este enemigo no cuenta con un arma, por lo que no podrá atacar al jugador. Su función principal es proporcionar un boost de velocidad al jugador al ser derrotado. Funciona como un “blanco de tiro”.  
  * **Enemigo hostil:** Este enemigo puede dispararle al jugador cuando este se encuentre en su rango. Lanza un proyectil en la dirección del jugador. El proyectil es grande, para que el jugador lo vea fácilmente y deba moverse cierta distancia para esquivarlo, y lento, para que tenga el suficiente tiempo de reacción como para esquivarlo. Este enemigo también bonifica al jugador con un boost de velocidad al ser derrotado.

### **2.2 Ranking Competitivo**

* Antes de comenzar cada nivel, el jugador ingresara su nombre. Al terminar cada nivel, se mostrara su tiempo y un ranking con los mejores tiempos y los nombres correspondientes. El ranking sera local y persistente. Si un jugador hace varios intentos con el mismo nombre, solo se guardara su menor tiempo.
* Estado actual: el menu de ranking lee `user://ranking.json`; la pantalla de victoria usa tres tiempos mockup y el guardado desde el gameplay aun no esta conectado.

---

## **5\. Arte y Audio**

### **5.1 Dirección de Arte**

* **Estilo visual:** Low-Poly Cyberpunk / Sci-Fi Minimalista / Entrada Runner  
  * Un estilo gráfico limpio y de pocos polígonos para que permita: Mantener altos FPS y tener claridad visual absoluta a altas velocidades.  
* **Paleta de colores:**   
  * **Suelo/Paredes:** Color gris y azul marino.  
  * **Puntos de Parkour:** Color contrario (si el piso es azul marino, que sea gris. O al revés)  
  * **Enemigos:** Patovas cibernéticos. Color rojo carmesí  
* **Referencias:** Karlson (por la simplicidad física y estética)

### **5.2 UI/UX**

* **Menús:** menu principal, controles, creditos, ranking, victoria y derrota.
* **Estilo:** Pantalla interactiva tipo **"Consola de DJ"**   
* **Diseño planeado:** Botones mínimos y angulares en azul neón sobre fondo oscuro.
* **Estado actual:** menus funcionales con controles y texto plano para priorizar el flujo de juego.
* **HUD durante gameplay:**

### **5.3 Audio**

* **Música:** (estilo, referencias)  
* **SFX:** (lista de sonidos clave)  
* **Voces:** (si aplica)

---

## **6\. Interfaz de Usuario**

### **6.1 Menús**

* **Menú principal:** Jugar, controles, ranking, creditos y salir.
* **Menú de pausa:** Pendiente.
* **Configuración:** Pendiente.

### **6.2 HUD**

> Qué información se muestra en pantalla durante el juego y dónde.

### **6.3 Flujo de Pantallas**

> Menu principal -> Gameplay -> Victoria o Derrota. El menu principal tambien permite abrir Controles, Ranking y Creditos.

---

## **7\. Aspectos Técnicos**

### **7.1 Motor / Engine**

* Godot 4.7 \- GD Script

### **7.3 Arquitectura**

> El sistema de movimientos del jugador será implementado con una state machine, para distribuir el código en distintos scripts. 

### **7.4 Sistema de Guardado**

* Sistema de guardado local planeado.
* **Qué se guarda:**  
  * Nombres y tiempos en el ranking, mediante `user://ranking.json`
