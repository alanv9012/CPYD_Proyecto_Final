-- Create tables in MySQL


USE bankdb;

DROP TABLE IF EXISTS prestamo;
DROP TABLE IF EXISTS sucursal;

-- Create sucursal table
CREATE TABLE sucursal (
    idsucursal VARCHAR(5),
    nombresucursal VARCHAR(15),
    ciudadsucursal VARCHAR(15),
    activos DECIMAL(15,2),
    region VARCHAR(2),
    PRIMARY KEY(idsucursal)
);

-- Create prestamo table
CREATE TABLE prestamo (
    noprestamo VARCHAR(15),
    idsucursal VARCHAR(5),
    cantidad DECIMAL(15,2),
    PRIMARY KEY(noprestamo),
    FOREIGN KEY(idsucursal) REFERENCES sucursal(idsucursal)
);

SELECT 'MySQL tables created successfully' AS status;
SELECT COUNT(*) AS total_sucursales FROM sucursal;
SELECT COUNT(*) AS total_prestamos FROM prestamo;

