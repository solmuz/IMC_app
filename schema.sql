CREATE DATABASE imc_app;
USE imc_app;

CREATE TABLE users (
    -- Clave Primaria e identificador
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,

    -- Credenciales y autenticación
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL COMMENT 'Almacena el hash de la contraseña (e.g., bcrypt)',

    -- Control de acceso y estado
    user_role ENUM('Administrador', 'Calidad', 'Usuario') NOT NULL DEFAULT 'Usuario',
    user_status ENUM('Activo', 'Inactivo') NOT NULL DEFAULT 'Activo',

    -- Auditoría (Timestamps y usuario creador)
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT UNSIGNED COMMENT 'Referencia al ID del usuario que creó este registro',

    -- Definiciones de claves
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email),

    -- Clave Foránea para Auditoría (Opcional pero Recomendada)
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

