-- Create tables for Node 2 (Region B)
-- This node stores only Region B data

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT Creating Tables on Node 2 (Region B)
PROMPT =====================================================

-- Drop tables if they exist
DROP TABLE prestamo CASCADE CONSTRAINTS;
DROP TABLE sucursal CASCADE CONSTRAINTS;

-- Create sucursal table (branches)
CREATE TABLE sucursal (
    idsucursal VARCHAR2(5),
    nombresucursal VARCHAR2(15),
    ciudadsucursal VARCHAR2(15),
    activos NUMBER,
    region VARCHAR2(2),
    PRIMARY KEY(idsucursal),
    CONSTRAINT chk_region_b CHECK (region = 'B')
);

-- Create prestamo table (loans)
CREATE TABLE prestamo (
    noprestamo VARCHAR2(15),
    idsucursal VARCHAR2(5),
    cantidad NUMBER,
    PRIMARY KEY(noprestamo),
    FOREIGN KEY(idsucursal) REFERENCES sucursal(idsucursal)
);

-- Insert Region B data
PROMPT Inserting Region B data...

INSERT INTO sucursal VALUES ('S0005', 'Round Hill', 'Horseneck', 8000000, 'B');
INSERT INTO sucursal VALUES ('S0006', 'Pownal', 'Bennington', 400000, 'B');
INSERT INTO sucursal VALUES ('S0007', 'North Town', 'Rye', 3700000, 'B');
INSERT INTO sucursal VALUES ('S0008', 'Brighton', 'Brooklyn', 7000000, 'B');
INSERT INTO sucursal VALUES ('S0009', 'Central', 'Rye', 400280, 'B');

INSERT INTO prestamo VALUES ('L-11', 'S0005', 900);
INSERT INTO prestamo VALUES ('L-20', 'S0007', 7500);
INSERT INTO prestamo VALUES ('L-21', 'S0009', 570);

COMMIT;

-- Verify data
PROMPT Verifying Region B data...
SELECT 'Sucursales in Region B: ' || COUNT(*) AS info FROM sucursal;
SELECT 'Prestamos in Region B: ' || COUNT(*) AS info FROM prestamo;

PROMPT 
PROMPT Node 2 (Region B) setup complete!
EXIT;

