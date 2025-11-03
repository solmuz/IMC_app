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

INSERT INTO users (
    username,
    email,
    user_role,
    user_status,
    created_by
) VALUES (
    'admin_root',
    'admin@imcapp.com',
    'Administrador',
    'Activo',
    NULL
);

CREATE TABLE projects (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria del Proyecto',
    
    name VARCHAR(150) NOT NULL,
    description TEXT,
    
    -- El responsable es un usuario de la tabla 'users'
    responsible_user_id INT UNSIGNED NOT NULL,
    
    -- Estado del proyecto, según requerimientos
    project_status ENUM('Activo', 'Cerrado', 'Archivado') NOT NULL DEFAULT 'Activo',
    
    start_date DATE NOT NULL COMMENT 'Fecha de inicio del proyecto',

    -- Timestamps de Auditoría
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    
    -- Clave Foránea al usuario responsable
    FOREIGN KEY (responsible_user_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE volunteers (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria del Voluntario',
    
    -- ID correlativo por proyecto (ej: "Voluntario 1")
    volunteer_correlative VARCHAR(20) NOT NULL,
    project_id INT UNSIGNED NOT NULL COMMENT 'Clave Foránea al proyecto al que pertenece',

    -- Datos Biométricos con Precisión Decimal (DECIMAL)
    gender ENUM('Male', 'Female', 'Unspecified') NOT NULL DEFAULT 'Unspecified',
    weight_kg DECIMAL(7, 2) NOT NULL COMMENT 'Peso en KG (Precision total: 7 digitos, 2 decimales)',
    height_m DECIMAL(4, 2) NOT NULL COMMENT 'Estatura en Metros (Precision total: 4 digitos, 2 decimales)',
    
    -- BMI Calculado
    bmi DECIMAL(4, 2) NOT NULL COMMENT 'Índice de Masa Corporal (IMC)',
    bmi_category ENUM('Low', 'Normal', 'High') NOT NULL,

    -- Borrado Lógico y Auditoría
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Borrado Lógico (0=Activo, 1=Eliminado)',
    
    -- Usuario que realiza el registro
    registered_by INT UNSIGNED NOT NULL,
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha/Hora del registro inicial',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    
    -- El número de voluntario debe ser único dentro de CADA proyecto
    UNIQUE KEY uk_correlative_project (project_id, volunteer_correlative), 

    -- Claves Foráneas
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (registered_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE audit_trail (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria del Registro de Auditoría',
    
    -- Identificación de la entidad afectada
    entity_type ENUM('project', 'volunteer', 'user') NOT NULL,
    entity_id INT UNSIGNED NOT NULL COMMENT 'ID del registro afectado (ej: volunteer.id)',
    
    -- El proyecto es NULLABLE porque también se auditan acciones de usuario a nivel de sistema.
    project_id INT UNSIGNED NULL,
    
    -- Acción realizada
    action_type ENUM('CREATE', 'UPDATE', 'DELETE') NOT NULL,
    
    -- Quién, cuándo y desde dónde
    user_id INT UNSIGNED NOT NULL,
    user_ip VARCHAR(45) COMMENT 'Dirección IP del usuario',
    user_agent VARCHAR(255) COMMENT 'Navegador/Agente del usuario',
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Detalles del cambio (antes/después)
    -- JSONB/JSON es el mejor tipo para almacenar estructuras de datos flexibles.
    details_before JSON COMMENT 'Datos de la entidad antes de la modificación',
    details_after JSON COMMENT 'Datos de la entidad después de la modificación',

    PRIMARY KEY (id),
    
    -- Claves Foráneas
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE reports (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria del Reporte',
    
    project_id INT UNSIGNED NOT NULL,
    generated_by INT UNSIGNED NOT NULL COMMENT 'Usuario que solicitó la generación del reporte',
    
    report_type ENUM('PDF', 'CSV') NOT NULL,
    
    -- Almacena los filtros usados para generar el reporte (útil para auditoría/reproducibilidad)
    filters TEXT COMMENT 'JSON o string con los filtros aplicados',
    
    file_path VARCHAR(255) NOT NULL COMMENT 'Ruta relativa o URL para acceder al archivo generado',
    
    generated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    
    -- Claves Foráneas
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (generated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;