-- ============================================
-- SCRIPT DE BASE DE DATOS PARA SUPABASE
-- ============================================

-- Eliminar tipos si existen (para re-ejecución)
DROP TYPE IF EXISTS rol_usuario CASCADE;
DROP TYPE IF EXISTS estado_usuario CASCADE;
DROP TYPE IF EXISTS tipo_experiencia CASCADE;
DROP TYPE IF EXISTS nivel_idioma CASCADE;
DROP TYPE IF EXISTS tipo_oferta CASCADE;
DROP TYPE IF EXISTS status_aplicacion CASCADE;
DROP TYPE IF EXISTS metodo_pago_tipo CASCADE;
DROP TYPE IF EXISTS prioridad_busqueda_tipo CASCADE;
DROP TYPE IF EXISTS estado_suscripcion CASCADE;
DROP TYPE IF EXISTS visibilidad_cv CASCADE;

-- Creación de tipos ENUM
CREATE TYPE rol_usuario AS ENUM ('admin', 'empresa', 'universidad', 'docente', 'estudiante');
CREATE TYPE estado_usuario AS ENUM ('activo', 'inactivo', 'suspendido', 'pendiente');
CREATE TYPE tipo_experiencia AS ENUM ('pasantia', 'tiempo_completo', 'medio_tiempo', 'voluntariado');
CREATE TYPE nivel_idioma AS ENUM ('basico', 'intermedio', 'avanzado');
CREATE TYPE tipo_oferta AS ENUM ('tiempo_completo', 'medio_tiempo', 'pasantia');
CREATE TYPE status_aplicacion AS ENUM ('pendiente', 'revisado', 'rechazado', 'aceptado');
CREATE TYPE metodo_pago_tipo AS ENUM ('credito', 'debito', 'paypal');
CREATE TYPE prioridad_busqueda_tipo AS ENUM ('alto', 'medio', 'bajo');
CREATE TYPE estado_suscripcion AS ENUM ('activo', 'cancelada', 'expirada', 'prueba');
CREATE TYPE visibilidad_cv AS ENUM ('si', 'no');

-- Tabla Usuario (vinculada con auth.users de Supabase)
CREATE TABLE Usuario (
    id_usuario UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    rol rol_usuario NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado estado_usuario NOT NULL
);

-- Tabla Perfil
CREATE TABLE Perfil (
    id_perfil SERIAL PRIMARY KEY,
    id_usuario UUID REFERENCES Usuario(id_usuario) ON DELETE CASCADE,
    nombre_completo VARCHAR(80) NOT NULL,
    foto_perfil VARCHAR(255),
    biografia TEXT NOT NULL,
    ubicacion TEXT NOT NULL,
    telefono VARCHAR(30) NOT NULL,
    sitio_web VARCHAR(500)
);

ALTER TABLE Perfil
ADD COLUMN pais VARCHAR(80) NOT NULL DEFAULT 'El Salvador';

ALTER TABLE Perfil
ALTER COLUMN pais DROP DEFAULT;

-- Tabla Perfil_empresa
CREATE TABLE Perfil_empresa (
    id_perfil INTEGER PRIMARY KEY REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    nombre_comercial VARCHAR(20) NOT NULL,
    anio_fundacion INTEGER NOT NULL,
    total_empleados INTEGER NOT NULL,
    doc_verificacion VARCHAR(500) NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    foto_portada VARCHAR(500)
);

-- Tabla Perfil_universidad
CREATE TABLE Perfil_universidad (
    id_perfil INTEGER PRIMARY KEY REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    nombre_oficial VARCHAR(20) NOT NULL,
    anio_fundacion INTEGER NOT NULL,
    total_docentes INTEGER NOT NULL,
    total_estudiantes INTEGER NOT NULL,
    doc_verificacion VARCHAR(500) NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    foto_portada VARCHAR(500)
);

-- Tabla Perfil_estudiante
CREATE TABLE Perfil_estudiante (
    id_perfil INTEGER PRIMARY KEY REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    nombre_comercial VARCHAR(20) NOT NULL,
    carrera VARCHAR(25) NOT NULL,
    universidad_actual VARCHAR(30),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE Perfil_estudiante
ALTER COLUMN nombre_comercial DROP NOT NULL;

-- Tabla Experiencia
CREATE TABLE Experiencia (
    id_experiencia SERIAL PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    empresa VARCHAR(255) NOT NULL,
    tipo tipo_experiencia NOT NULL,
    puesto TEXT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    descripcion TEXT,
    ubicacion TEXT
);

-- Tabla Formacion
CREATE TABLE Formacion (
    id_formacion SERIAL PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    institucion VARCHAR(255) NOT NULL,
    campo_estudio VARCHAR(255) NOT NULL,
    grado VARCHAR(255) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL
);

-- Tabla Investigacion
CREATE TABLE Investigacion (
    id_investigacion SERIAL PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    rol VARCHAR(60),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    fecha_publicacion DATE NOT NULL,
    ubicacion TEXT
);

-- Tabla Certificacion
CREATE TABLE Certificacion (
    id_certificacion SERIAL PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    imagen TEXT NOT NULL,
    institucion TEXT NOT NULL,
    fecha_obtencion DATE NOT NULL
);

-- Tabla Habilidad
CREATE TABLE Habilidad (
    id_habilidad SERIAL PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    nombre TEXT NOT NULL
);

-- Tabla Idioma
CREATE TABLE Idioma (
    id_idioma SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    nivel nivel_idioma NOT NULL
);

-- Tabla CV_archivo
CREATE TABLE CV_archivo (
    id_cv SERIAL PRIMARY KEY,
    id_perfil INTEGER REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    nombre VARCHAR(30) NOT NULL,
    url_cv VARCHAR(255) NOT NULL,
    fecha_subida DATE NOT NULL DEFAULT CURRENT_DATE,
    visible visibilidad_cv NOT NULL DEFAULT 'si'
);

-- Tabla Suscripcion_plan
CREATE TABLE Suscripcion_plan (
    id_suscripcion_plan SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    precio_mensual DECIMAL(6,2) NOT NULL,
    max_pub_dia INTEGER NOT NULL,
    max_caracteres_pub INTEGER NOT NULL,
    prioridad_busqueda prioridad_busqueda_tipo NOT NULL,
    agregar_ads BOOLEAN NOT NULL,
    max_cv_subida INTEGER NOT NULL,
    max_ofertas_trabajo INTEGER NOT NULL,
    mostrar_anuncios BOOLEAN NOT NULL
);

-- Tabla Suscripciones
CREATE TABLE Suscripciones (
    id_suscripcion SERIAL PRIMARY KEY,
    id_perfil INTEGER REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    id_suscripcion_plan INTEGER REFERENCES Suscripcion_plan(id_suscripcion_plan),
    estatus estado_suscripcion NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    proximo_fecha_pago DATE NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Pago
CREATE TABLE Pago (
    id_pago SERIAL PRIMARY KEY,
    id_suscripcion INTEGER REFERENCES Suscripciones(id_suscripcion) ON DELETE SET NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    metodo_pago metodo_pago_tipo NOT NULL,
    fecha_pago DATE NOT NULL
);

-- Tabla Publicacion
CREATE TABLE Publicacion (
    id_publicacion SERIAL PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    likes_contador INTEGER NOT NULL DEFAULT 0,
    comentarios_contador INTEGER NOT NULL DEFAULT 0,
    fecha_publicacion DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Tabla Recurso_publicacion
CREATE TABLE Recurso_publicacion (
    id_recurso SERIAL PRIMARY KEY,
    id_publicacion INTEGER NOT NULL REFERENCES Publicacion(id_publicacion) ON DELETE CASCADE,
    url_recurso VARCHAR(600) NOT NULL
);

-- Tabla Publicacion_like
CREATE TABLE Publicacion_like (
    id_publicacion_like SERIAL PRIMARY KEY,
    id_publicacion INTEGER REFERENCES Publicacion(id_publicacion) ON DELETE CASCADE,
    id_perfil INTEGER REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(id_publicacion, id_perfil)
);

-- Tabla Comentario
CREATE TABLE Comentario (
    id_comentario SERIAL PRIMARY KEY,
    id_publicacion INTEGER NOT NULL REFERENCES Publicacion(id_publicacion) ON DELETE CASCADE,
    id_perfil_autor INTEGER NOT NULL REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    contenido TEXT NOT NULL
);

-- Tabla Favorito
CREATE TABLE Favorito (
    id_favorito SERIAL PRIMARY KEY,
    id_publicacion INTEGER REFERENCES Publicacion(id_publicacion) ON DELETE CASCADE,
    id_perfil INTEGER REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(id_publicacion, id_perfil)
);

-- Tabla Oferta
CREATE TABLE Oferta (
    id_oferta SERIAL PRIMARY KEY,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    titulo VARCHAR(50) NOT NULL,
    descripcion TEXT NOT NULL,
    salario_rango VARCHAR(60) NOT NULL,
    tipo_oferta tipo_oferta NOT NULL,
    ubicacion VARCHAR(255) NOT NULL,
    es_activa BOOLEAN NOT NULL DEFAULT true,
    fecha_publicacion DATE NOT NULL DEFAULT CURRENT_DATE,
    fecha_limite DATE
);

-- Tabla Requisito
CREATE TABLE Requisito (
    id_requisito SERIAL PRIMARY KEY,
    id_oferta INTEGER NOT NULL REFERENCES Oferta(id_oferta) ON DELETE CASCADE,
    nombre_requisito VARCHAR(255) NOT NULL
);

-- Tabla Beneficio
CREATE TABLE Beneficio (
    id_beneficio SERIAL PRIMARY KEY,
    id_oferta INTEGER NOT NULL REFERENCES Oferta(id_oferta) ON DELETE CASCADE,
    nombre_beneficio VARCHAR(255) NOT NULL
);

-- Tabla Aplicacion
CREATE TABLE Aplicacion (
    id_aplicacion SERIAL PRIMARY KEY,
    id_oferta INTEGER NOT NULL REFERENCES Oferta(id_oferta) ON DELETE CASCADE,
    id_perfil INTEGER NOT NULL REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    id_cv INTEGER REFERENCES CV_archivo(id_cv) ON DELETE SET NULL,
    status status_aplicacion NOT NULL DEFAULT 'pendiente',
    recomendacion_premium BOOLEAN NOT NULL DEFAULT false,
    carta_presentacion TEXT,
    email_contacto VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    disponibilidad VARCHAR(255) NOT NULL,
    fecha_aplicacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Anuncio
CREATE TABLE Anuncio (
    id_anuncio SERIAL PRIMARY KEY,
    id_empresa INTEGER NOT NULL REFERENCES Perfil_empresa(id_perfil) ON DELETE CASCADE,
    titulo VARCHAR(50) NOT NULL,
    descripcion VARCHAR(500) NOT NULL,
    vista_contador INTEGER NOT NULL DEFAULT 0,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL
);

-- Tabla Recurso_anuncio
CREATE TABLE Recurso_anuncio (
    id_recurso SERIAL PRIMARY KEY,
    id_anuncio INTEGER REFERENCES Anuncio(id_anuncio) ON DELETE CASCADE,
    url_recurso VARCHAR(500) NOT NULL
);

-- Tabla Perfil_Favorito
CREATE TABLE Perfil_Favorito (
    id_perfil_empresa INTEGER REFERENCES Perfil_empresa(id_perfil) ON DELETE CASCADE,
    id_perfil_estudiante INTEGER REFERENCES Perfil_estudiante(id_perfil) ON DELETE CASCADE,
    nota VARCHAR(100),
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_perfil_empresa, id_perfil_estudiante)
);

-- Tabla Destacado
CREATE TABLE Destacado (
    id_destacado SERIAL PRIMARY KEY,
    id_universidad INTEGER REFERENCES Perfil_universidad(id_perfil) ON DELETE CASCADE,
    id_estudiante INTEGER REFERENCES Perfil_estudiante(id_perfil) ON DELETE CASCADE,
    comentario TEXT
);

-- Tabla Seguidor
CREATE TABLE Seguidor (
    id_seguidor INTEGER REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    id_seguido INTEGER REFERENCES Perfil(id_perfil) ON DELETE CASCADE,
    PRIMARY KEY (id_seguidor, id_seguido),
    CHECK (id_seguidor != id_seguido)
);

-- ============================================
-- ÍNDICES PARA MEJORAR EL RENDIMIENTO
-- ============================================
CREATE INDEX idx_perfil_usuario ON Perfil(id_usuario);
CREATE INDEX idx_experiencia_perfil ON Experiencia(id_perfil);
CREATE INDEX idx_formacion_perfil ON Formacion(id_perfil);
CREATE INDEX idx_publicacion_perfil ON Publicacion(id_perfil);
CREATE INDEX idx_publicacion_fecha ON Publicacion(fecha_publicacion);
CREATE INDEX idx_oferta_perfil ON Oferta(id_perfil);
CREATE INDEX idx_oferta_activa ON Oferta(es_activa);
CREATE INDEX idx_aplicacion_oferta ON Aplicacion(id_oferta);
CREATE INDEX idx_aplicacion_perfil ON Aplicacion(id_perfil);
CREATE INDEX idx_usuario_rol ON Usuario(rol);
CREATE INDEX idx_usuario_estado ON Usuario(estado);