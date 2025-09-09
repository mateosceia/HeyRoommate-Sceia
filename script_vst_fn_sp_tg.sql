CREATE VIEW vista_reservas_activas AS
SELECT 
    r.id_reserva,
    u.nombre AS inquilino_nombre,
    u.apellido AS inquilino_apellido,
    p.titulo AS propiedad,
    p.ciudad,
    p.pais,
    r.fecha_inicio,
    r.fecha_fin,
    r.estado
FROM reservas r
JOIN usuarios u ON r.id_usuario = u.id_usuario
JOIN propiedades p ON r.id_propiedad = p.id_propiedad
WHERE r.estado = 'aceptada'
  AND r.fecha_inicio <= CURDATE()
  AND r.fecha_fin >= CURDATE();
  
CREATE VIEW vista_reservas_pendientes AS
SELECT 
    r.id_reserva,
    u.nombre AS inquilino_nombre,
    u.apellido AS inquilino_apellido,
    p.titulo AS propiedad,
    p.ciudad,
    p.pais,
    r.fecha_inicio,
    r.fecha_fin,
    r.fecha_creacion
FROM reservas r
JOIN usuarios u ON r.id_usuario = u.id_usuario
JOIN propiedades p ON r.id_propiedad = p.id_propiedad
WHERE r.estado = 'pendiente';


CREATE VIEW vista_propiedades_calificacion AS
SELECT 
    p.id_propiedad,
    p.titulo,
    p.ciudad,
    p.pais,
    AVG(r.calificacion) AS calificacion_promedio,
    COUNT(r.id_resena) AS cantidad_resenas
FROM propiedades p
LEFT JOIN resenas r ON p.id_propiedad = r.id_propiedad
GROUP BY p.id_propiedad, p.titulo, p.ciudad, p.pais
ORDER BY calificacion_promedio DESC;

CREATE VIEW vista_ingresos_propiedades AS
SELECT 
    p.id_propiedad,
    p.titulo,
    p.ciudad,
    p.pais,
    SUM(DATEDIFF(r.fecha_fin, r.fecha_inicio) * p.precio_noche) AS ingresos_estimados
FROM propiedades p
JOIN reservas r ON p.id_propiedad = r.id_propiedad
WHERE r.estado = 'aceptada'
GROUP BY p.id_propiedad, p.titulo, p.ciudad, p.pais
ORDER BY ingresos_estimados DESC;

CREATE VIEW vista_inquilinos_reservas AS
SELECT 
    u.id_usuario,
    u.nombre,
    u.apellido,
    COUNT(r.id_reserva) AS total_reservas
FROM usuarios u
JOIN reservas r ON u.id_usuario = r.id_usuario
WHERE u.rol = 'inquilino'
GROUP BY u.id_usuario, u.nombre, u.apellido
ORDER BY total_reservas DESC;

CREATE VIEW vista_propiedades_vencidas AS
SELECT 
    p.id_propiedad,
    p.titulo,
    p.ciudad,
    p.pais,
    p.disponible_desde,
    p.disponible_hasta
FROM propiedades p
WHERE p.disponible_hasta IS NOT NULL
  AND p.disponible_hasta < CURDATE();

CREATE VIEW vista_usuarios_inactivos AS
SELECT 
    u.id_usuario,
    u.nombre,
    u.apellido,
    u.email,
    u.fecha_registro
FROM usuarios u
LEFT JOIN reservas r ON u.id_usuario = r.id_usuario
LEFT JOIN propiedades p ON u.id_usuario = p.id_usuario
WHERE r.id_reserva IS NULL
  AND p.id_propiedad IS NULL;

CREATE VIEW vista_auditoria_reciente AS
SELECT *
FROM auditoria
WHERE fecha_evento >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY fecha_evento DESC;

CREATE VIEW vista_auditoria_usuarios_eliminados AS
SELECT id_registro AS id_usuario,
       fecha_evento,
       detalle
FROM auditoria
WHERE tabla = 'usuarios' AND accion = 'DELETE'
ORDER BY fecha_evento DESC;

CREATE VIEW vista_auditoria_reservas_estado AS
SELECT id_registro AS id_reserva,
       fecha_evento,
       detalle
FROM auditoria
WHERE tabla = 'reservas' AND accion = 'UPDATE'
ORDER BY fecha_evento DESC;

CREATE VIEW vista_auditoria_propiedades AS
SELECT id_registro AS id_propiedad,
       accion,
       fecha_evento,
       detalle
FROM auditoria
WHERE tabla = 'propiedades' AND accion IN ('INSERT','DELETE')
ORDER BY fecha_evento DESC;

CREATE VIEW vista_auditoria_resumen AS
SELECT tabla,
       accion,
       COUNT(*) AS total_acciones
FROM auditoria
GROUP BY tabla, accion
ORDER BY tabla, accion;

DELIMITER //

CREATE FUNCTION fn_promedio_calificacion(idProp INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(3,2);
    SELECT AVG(calificacion) INTO promedio
    FROM resenas
    WHERE id_propiedad = idProp;
    RETURN IFNULL(promedio, 0);
END//

DELIMITER ;

DELIMITER //

CREATE FUNCTION fn_cantidad_resenas_propiedad(idProp INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM resenas
    WHERE id_propiedad = idProp;
    RETURN total;
END//

DELIMITER ;


DELIMITER //

CREATE FUNCTION fn_total_noches_propiedad(idProp INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_noches INT;
    SELECT SUM(DATEDIFF(fecha_fin, fecha_inicio)) INTO total_noches
    FROM reservas
    WHERE id_propiedad = idProp AND estado = 'aceptada';
    RETURN IFNULL(total_noches, 0);
END//

DELIMITER ;

DELIMITER //

CREATE FUNCTION fn_ingresos_propiedad(idProp INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE ingresos DECIMAL(10,2);
    SELECT SUM(DATEDIFF(fecha_fin, fecha_inicio) * precio_noche) INTO ingresos
    FROM reservas r
    JOIN propiedades p ON r.id_propiedad = p.id_propiedad
    WHERE r.id_propiedad = idProp AND r.estado = 'aceptada';
    RETURN IFNULL(ingresos, 0.00);
END//

DELIMITER ;

DELIMITER //

CREATE FUNCTION fn_cantidad_reservas_usuario(idUser INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM reservas
    WHERE id_usuario = idUser;
    RETURN total;
END//

DELIMITER ;
DELIMITER //

CREATE PROCEDURE sp_registrar_usuario(
    IN p_rol ENUM('propietario','inquilino','admin'),
    IN p_nombre VARCHAR(50),
    IN p_apellido VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_codigo_telefonico VARCHAR(5),
    IN p_telefono VARCHAR(20),
    IN p_nacionalidad VARCHAR(50),
    IN p_fecha_nacimiento DATE
)
BEGIN
    IF EXISTS (SELECT 1 FROM usuarios WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El email ya está registrado';
    ELSE
        INSERT INTO usuarios (
            rol, nombre, apellido, email, codigo_telefonico, telefono,
            nacionalidad, fecha_nacimiento, fecha_registro
        ) VALUES (
            p_rol, p_nombre, p_apellido, p_email, p_codigo_telefonico, p_telefono,
            p_nacionalidad, p_fecha_nacimiento, CURDATE()
        );
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_registrar_propiedad(
    IN p_id_usuario INT,
    IN p_titulo VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_tipo VARCHAR(50),
    IN p_habitaciones INT,
    IN p_capacidad_maxima INT,
    IN p_precio_noche DECIMAL(10,2),
    IN p_direccion VARCHAR(150),
    IN p_ciudad VARCHAR(50),
    IN p_pais VARCHAR(50),
    IN p_disponible_desde DATE,
    IN p_disponible_hasta DATE
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id_usuario = p_id_usuario AND rol = 'propietario') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no es propietario válido';
    ELSE
        INSERT INTO propiedades (
            id_usuario, titulo, descripcion, tipo, habitaciones, capacidad_maxima,
            precio_noche, direccion, ciudad, pais, disponible_desde, disponible_hasta
        ) VALUES (
            p_id_usuario, p_titulo, p_descripcion, p_tipo, p_habitaciones, p_capacidad_maxima,
            p_precio_noche, p_direccion, p_ciudad, p_pais, p_disponible_desde, p_disponible_hasta
        );
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_registrar_reserva(
    IN p_id_usuario INT,
    IN p_id_propiedad INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM usuarios 
        WHERE id_usuario = p_id_usuario AND rol = 'inquilino'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no es un inquilino válido';
    
    ELSEIF p_fecha_inicio >= p_fecha_fin THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha de inicio debe ser menor a la de fin';

    ELSE
        INSERT INTO reservas (
            id_usuario, id_propiedad, fecha_inicio, fecha_fin, estado
        ) VALUES (
            p_id_usuario, p_id_propiedad, p_fecha_inicio, p_fecha_fin, 'pendiente'
        );
    END IF;
END//

DELIMITER ;


DELIMITER //

CREATE PROCEDURE sp_cambiar_estado_reserva(
    IN p_id_reserva INT,
    IN p_estado ENUM('pendiente','aceptada','rechazada','cancelada','finalizada')
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM reservas WHERE id_reserva = p_id_reserva) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La reserva no existe';
    ELSE
        UPDATE reservas
        SET estado = p_estado
        WHERE id_reserva = p_id_reserva;
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_insertar_resena(
    IN p_id_usuario INT,
    IN p_id_propiedad INT,
    IN p_calificacion INT,
    IN p_comentario VARCHAR(500)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM reservas
        WHERE id_usuario = p_id_usuario
          AND id_propiedad = p_id_propiedad
          AND estado = 'aceptada'
          AND fecha_fin < CURDATE()
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no puede reseñar esta propiedad';
    ELSE
        INSERT INTO resenas (id_usuario, id_propiedad, calificacion, comentario)
		VALUES (p_id_usuario, p_id_propiedad, p_calificacion, p_comentario);
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_no_borrar_usuario_con_propiedades
BEFORE DELETE ON usuarios
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM propiedades WHERE id_usuario = OLD.id_usuario) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar el usuario: tiene propiedades activas';
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_validar_reserva
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM reservas
        WHERE id_propiedad = NEW.id_propiedad
          AND estado = 'aceptada'
          AND (
              NEW.fecha_inicio BETWEEN fecha_inicio AND fecha_fin
              OR NEW.fecha_fin BETWEEN fecha_inicio AND fecha_fin
              OR fecha_inicio BETWEEN NEW.fecha_inicio AND NEW.fecha_fin
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La propiedad ya está reservada en esas fechas';
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_finalizar_reserva
AFTER UPDATE ON reservas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'aceptada' AND NEW.fecha_fin < CURDATE() THEN
        UPDATE reservas
        SET estado = 'finalizada'
        WHERE id_reserva = NEW.id_reserva;
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_aud_usuarios_insert
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('usuarios', 'INSERT', NEW.id_usuario, null,
            CONCAT('Usuario creado: ', NEW.nombre, ' ', NEW.apellido));
END//

CREATE TRIGGER trg_aud_usuarios_update
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('usuarios', 'UPDATE', NEW.id_usuario, null,
            'Datos de usuario modificados');
END//

CREATE TRIGGER trg_aud_usuarios_delete
AFTER DELETE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('usuarios', 'DELETE', OLD.id_usuario, null,
            CONCAT('Usuario eliminado: ', OLD.nombre, ' ', OLD.apellido));
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_aud_propiedades_insert
AFTER INSERT ON propiedades
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('propiedades', 'INSERT', NEW.id_propiedad, NEW.id_usuario,
            CONCAT('Propiedad publicada: ', NEW.titulo, ' en ', NEW.ciudad));
END//

CREATE TRIGGER trg_aud_propiedades_update
AFTER UPDATE ON propiedades
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('propiedades', 'UPDATE', NEW.id_propiedad, NEW.id_usuario,
            CONCAT('Propiedad modificada: ', NEW.titulo));
END//

CREATE TRIGGER trg_aud_propiedades_delete
AFTER DELETE ON propiedades
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('propiedades', 'DELETE', OLD.id_propiedad, OLD.id_usuario,
            CONCAT('Propiedad eliminada: ', OLD.titulo));
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_aud_reservas_insert
AFTER INSERT ON reservas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('reservas', 'INSERT', NEW.id_reserva, NEW.id_usuario,
            CONCAT('Reserva creada: propiedad ', NEW.id_propiedad, 
                   ' desde ', NEW.fecha_inicio, ' hasta ', NEW.fecha_fin));
END//

CREATE TRIGGER trg_aud_reservas_update
AFTER UPDATE ON reservas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('reservas', 'UPDATE', NEW.id_reserva, NEW.id_usuario,
            CONCAT('Reserva actualizada: estado = ', NEW.estado));
END//

CREATE TRIGGER trg_aud_reservas_delete
AFTER DELETE ON reservas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('reservas', 'DELETE', OLD.id_reserva, OLD.id_usuario,
            'Reserva eliminada');
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_aud_resenas_insert
AFTER INSERT ON resenas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('resenas', 'INSERT', NEW.id_resena, NEW.id_usuario,
            CONCAT('Reseña creada: calificación ', NEW.calificacion));
END//

CREATE TRIGGER trg_aud_resenas_update
AFTER UPDATE ON resenas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('resenas', 'UPDATE', NEW.id_resena, NEW.id_usuario,
            'Reseña modificada');
END//

CREATE TRIGGER trg_aud_resenas_delete
AFTER DELETE ON resenas
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla, accion, id_registro, id_usuario_responsable, detalle)
    VALUES ('resenas', 'DELETE', OLD.id_resena, OLD.id_usuario,
            'Reseña eliminada');
END//

DELIMITER ;
