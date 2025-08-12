# HeyRoommate-Sceia

# HeyRoommate – Trabajo Práctico de SQL

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
!(Diagrama_ER.png)

## 5. Listado de Tablas

### Tabla: `usuarios`
| Campo              | Descripción                                        | Tipo de dato    | Clave        |
|--------------------|----------------------------------------------------|-----------------|--------------|
| id_usuario         | Identificador único del usuario                     | INT             | PK           |
| nombre             | Nombre del usuario                                 | VARCHAR(50)     |              |
| apellido           | Apellido del usuario                               | VARCHAR(50)     |              |
| email              | Correo electrónico (único)                         | VARCHAR(100)    | UNIQUE       |
| codigo_telefonico  | Código internacional del teléfono                  | VARCHAR(5)      |              |
| telefono           | Número de teléfono                                 | VARCHAR(20)     |              |
| nacionalidad       | Nacionalidad del usuario                           | VARCHAR(50)     |              |
| fecha_nacimiento   | Fecha de nacimiento del usuario                    | DATE            |              |

### Tabla: `propietarios`
| Campo             | Descripción                                        | Tipo de dato    | Clave        |
|-------------------|----------------------------------------------------|-----------------|--------------|
| id_propietario    | Identificador único del propietario                 | INT             | PK           |
| nombre            | Nombre del propietario                             | VARCHAR(50)     |              |
| apellido          | Apellido del propietario                           | VARCHAR(50)     |              |
| email             | Correo electrónico (único)                         | VARCHAR(100)    | UNIQUE       |
| fecha_registro    | Fecha en que el propietario se unió a la plataforma | DATE            |              |

### Tabla: `propiedades`
| Campo               | Descripción                                        | Tipo de dato    | Clave        |
|---------------------|----------------------------------------------------|-----------------|--------------|
| id_propiedad        | Identificador único de la propiedad                 | INT             | PK           |
| id_propietario      | Identificador del propietario                       | INT             | FK           |
| direccion           | Dirección completa de la propiedad                  | VARCHAR(255)    |              |
| ciudad              | Ciudad donde se ubica la propiedad                  | VARCHAR(100)    |              |
| pais                | País de la propiedad                                | VARCHAR(100)    |              |
| capacidad_maxima    | Cantidad máxima de usuarios que pueden habitarla    | INT             |              |
| habitaciones        | Número de habitaciones disponibles                  | INT             |              |
| banos               | Número de baños disponibles                         | INT             |              |

### Tabla: `reservas`
| Campo            | Descripción                                        | Tipo de dato    | Clave        |
|------------------|----------------------------------------------------|-----------------|--------------|
| id_reserva       | Identificador único de la reserva                   | INT             | PK           |
| id_usuario       | Identificador del usuario                           | INT             | FK           |
| id_propiedad     | Identificador de la propiedad                       | INT             | FK           |
| fecha_inicio     | Fecha de inicio de la reserva                       | DATE            |              |
| fecha_fin        | Fecha de finalización de la reserva                 | DATE            |              |

### Tabla: `resenas`
| Campo            | Descripción                                        | Tipo de dato    | Clave        |
|------------------|----------------------------------------------------|-----------------|--------------|
| id_resena        | Identificador único de la reseña                    | INT             | PK           |
| id_usuario       | Usuario que dejó la reseña                          | INT             | FK           |
| id_propiedad     | Propiedad evaluada                                  | INT             | FK           |
| comentario       | Texto con la opinión del usuario                    | TEXT            |              |
| puntuacion       | Calificación numérica (1 a 5)                       | INT             |              |
| fecha_resena     | Fecha en que se dejó la reseña                      | DATE            |              |
