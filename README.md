# HeyRoommate-Sceia

## 1. Introducción
HeyRoommate es una aplicación diseñada para facilitar que las personas encuentren compañeros de habitación (roommates) de manera segura y organizada. La plataforma permite que los usuarios se registren, busquen propiedades compartidas y realicen reservas, priorizando la experiencia de convivencia sobre el simple alquiler.

### Objetivo
El objetivo de este proyecto es diseñar, implementar y documentar una base de datos relacional que respalde las operaciones de la aplicación **HeyRoommate**.  
La base de datos está pensada para gestionar de forma eficiente la información relacionada con usuarios, propietarios, propiedades, reservas y reseñas, considerando las particularidades del modelo de negocio centrado en facilitar que personas puedan encontrar y compartir alojamiento como roommates.

Este trabajo incluye:  
- Diseño de las tablas y sus relaciones.  
- Definición de claves primarias, foráneas y restricciones necesarias para garantizar la integridad de los datos.  
- Inserción de datos de ejemplo para pruebas y validaciones.

## 2. Situación Problemática
En muchas ciudades, encontrar un roommate adecuado y una propiedad que permita compartir gastos resulta complejo y consume tiempo. HeyRoommate resuelve este problema ofreciendo una base de datos bien estructurada que permite filtrar opciones según la capacidad máxima de inquilinos y otros criterios relevantes.

## 3. Modelo de Negocio
HeyRoommate funciona como una plataforma intermediaria entre propietarios que publican propiedades disponibles y usuarios que desean alquilar parcial o totalmente dichos espacios. A diferencia de otras aplicaciones, el foco principal es permitir que varias personas compartan una propiedad como roommates, con un límite máximo definido por el propietario.

El flujo básico es:  
1. Un propietario publica una propiedad indicando su capacidad máxima de usuarios.  
2. Un usuario interesado puede reservar la propiedad.  
3. Una vez finalizada la estancia, el usuario puede dejar una reseña.

## 4. Diagrama Entidad-Relación
![Grafico Diagrama E-R](Diagrama_ER.png)

## 5. Listado de Tablas
### Tabla: `usuarios`
| Campo             | Tipo de dato          | Clave      | Descripción                                 |
|-------------------|----------------------|------------|---------------------------------------------|
| id_usuario        | INT AUTO_INCREMENT   | PK         | Identificador único del usuario              |
| nombre            | VARCHAR(50)          |            | Nombre del usuario                           |
| apellido          | VARCHAR(50)          |            | Apellido del usuario                         |
| email             | VARCHAR(100)         | UNIQUE     | Correo electrónico único                     |
| codigo_telefonico | VARCHAR(5)           |            | Código internacional del teléfono           |
| telefono          | VARCHAR(20)          |            | Número de teléfono                           |
| nacionalidad      | VARCHAR(50)          |            | Nacionalidad del usuario                      |
| fecha_nacimiento  | DATE                 |            | Fecha de nacimiento                          |
| fecha_registro    | DATE                 |            | Fecha en que se registró en la plataforma    |

---

### Tabla: `propietarios`
| Campo             | Tipo de dato          | Clave      | Descripción                                 |
|-------------------|----------------------|------------|---------------------------------------------|
| id_propietario    | INT AUTO_INCREMENT   | PK         | Identificador único del propietario          |
| nombre            | VARCHAR(50)          |            | Nombre del propietario                       |
| apellido          | VARCHAR(50)          |            | Apellido del propietario                     |
| email             | VARCHAR(100)         | UNIQUE     | Correo electrónico único                     |
| codigo_telefonico | VARCHAR(5)           |            | Código internacional del teléfono           |
| telefono          | VARCHAR(20)          |            | Número de teléfono                           |
| fecha_registro    | DATE                 |            | Fecha en que se registró como propietario    |

---

### Tabla: `propiedades`
| Campo             | Tipo de dato          | Clave      | Descripción                                 |
|-------------------|----------------------|------------|---------------------------------------------|
| id_propiedad      | INT AUTO_INCREMENT   | PK         | Identificador único de la propiedad          |
| id_propietario    | INT                  | FK         | Identificador del propietario (foránea)     |
| titulo            | VARCHAR(100)         |            | Título descriptivo de la propiedad           |
| descripcion       | TEXT                 |            | Descripción detallada                         |
| tipo              | VARCHAR(50)          |            | Tipo de propiedad (departamento, casa, etc.)|
| habitaciones      | INT                  |            | Cantidad de habitaciones                      |
| capacidad_maxima  | INT                  |            | Máximo número de usuarios permitidos         |
| precio_noche      | DECIMAL(10,2)        |            | Precio por noche                              |
| direccion         | VARCHAR(150)         |            | Dirección completa                            |
| ciudad            | VARCHAR(50)          |            | Ciudad donde se ubica                         |
| pais              | VARCHAR(50)          |            | País donde se ubica                           |
| disponible_desde  | DATE                 |            | Fecha desde la cual está disponible           |
| disponible_hasta  | DATE                 |            | Fecha hasta la cual está disponible (opcional)|

---

### Tabla: `reservas`
| Campo             | Tipo de dato          | Clave      | Descripción                                 |
|-------------------|----------------------|------------|---------------------------------------------|
| id_reserva        | INT AUTO_INCREMENT   | PK         | Identificador único de la reserva            |
| id_usuario        | INT                  | FK         | Usuario que realiza la reserva (foránea)    |
| id_propiedad      | INT                  | FK         | Propiedad reservada (foránea)                |
| fecha_inicio      | DATE                 |            | Fecha de inicio de la reserva                 |
| fecha_fin         | DATE                 |            | Fecha de fin de la reserva                     |
| estado            | ENUM                 |            | Estado de la reserva (pendiente, aceptada, rechazada, cancelada) |
| fecha_creacion    | TIMESTAMP            |            | Fecha y hora en que se creó la reserva        |

---

### Tabla: `resenas`
| Campo             | Tipo de dato          | Clave      | Descripción                                 |
|-------------------|----------------------|------------|---------------------------------------------|
| id_resena         | INT AUTO_INCREMENT   | PK         | Identificador único de la reseña             |
| id_usuario        | INT                  | FK         | Usuario que dejó la reseña (foránea)        |
| id_propiedad      | INT                  | FK         | Propiedad evaluada (foránea)                 |
| calificacion      | INT                  |            | Calificación numérica (1 a 5)                 |
| comentario        | TEXT                 |            | Comentario textual                           |
| fecha_resena      | DATE                 |            | Fecha en que se realizó la reseña            |

[Script SQL Tablas](tablas.sql)
[Script SQL Inserts de Prueba](ejemplo_inserts.sql)
