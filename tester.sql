
CALL sp_registrar_usuario('propietario','Juan','Pérez','juan@example.com','+54','111111111','Argentina','1985-05-01');
CALL sp_registrar_usuario('inquilino','María','Gómez','maria@example.com','+54','222222222','Argentina','1990-07-15');

CALL sp_registrar_propiedad(81, 'Depto en Córdoba', 'Departamento céntrico con 2 habitaciones', 'Departamento', 2, 4, 100.00, 'Av. Siempreviva 123', 'Córdoba', 'Argentina', '2025-01-01', '2025-12-31');

CALL sp_registrar_reserva(82, 31, '2025-10-01', '2025-10-05');

CALL sp_cambiar_estado_reserva(61, 'aceptada');

CALL sp_registrar_pago(61, 'tarjeta');

CALL sp_enviar_mensaje(82, 1, 'Hola, ¿la propiedad está disponible en marzo?');
CALL sp_enviar_mensaje(81, 2, 'Sí, está disponible. Puedo reservarla ahora mismo.');


INSERT INTO imagenes_propiedades (id_propiedad, url_imagen, descripcion)
VALUES (31, 'https://example.com/depto_cordoba.jpg', 'Foto del living del departamento en Córdoba');

SELECT fn_promedio_calificacion(1) AS promedio_calificacion;
SELECT fn_cantidad_resenas_propiedad(1) AS cantidad_resenas;
SELECT fn_total_noches_propiedad(1) AS noches_totales;
SELECT fn_ingresos_propiedad(1) AS ingresos_propiedad;

SELECT * FROM vista_propiedades_calificacion;
SELECT * FROM vista_ingresos_propiedades;
SELECT * FROM vista_inquilinos_reservas;
SELECT * FROM vista_auditoria_reciente;

SELECT * FROM auditoria ORDER BY fecha_evento DESC;

SELECT * FROM hechos_reservas;
