CREATE DATABASE IF NOT EXISTS HeyRoommate;
USE HeyRoommate;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    codigo_telefonico VARCHAR(5),
    telefono VARCHAR(20),
    nacionalidad VARCHAR(50),
    fecha_nacimiento DATE,
    fecha_registro DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS propietarios (
    id_propietario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    codigo_telefonico VARCHAR(5),
    telefono VARCHAR(20),
    fecha_registro DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS propiedades (
    id_propiedad INT AUTO_INCREMENT PRIMARY KEY,
    id_propietario INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(50) NOT NULL,
    habitaciones INT NOT NULL,
    capacidad_maxima INT NOT NULL,
    precio_noche DECIMAL(10,2) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    disponible_desde DATE NOT NULL,
    disponible_hasta DATE,
    FOREIGN KEY (id_propietario) REFERENCES propietarios(id_propietario)
);

CREATE TABLE IF NOT EXISTS reservas (
    id_reserva INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_propiedad INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('pendiente', 'aceptada', 'rechazada', 'cancelada') DEFAULT 'pendiente',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_propiedad) REFERENCES propiedades(id_propiedad)
);

CREATE TABLE IF NOT EXISTS resenas (
    id_resena INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_propiedad INT NOT NULL,
    calificacion INT CHECK (calificacion BETWEEN 1 AND 5) NOT NULL,
    comentario TEXT,
    fecha_resena DATE NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario),
    FOREIGN KEY (id_propiedad) REFERENCES propiedades(id_propiedad)
);
