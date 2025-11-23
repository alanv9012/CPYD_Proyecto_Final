-- Create tables for Node 1 (Region A)
-- This node stores only Region A data

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT Creating Tables on Node 1 (Region A)
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
    CONSTRAINT chk_region_a CHECK (region = 'A')
);

-- Create prestamo table (loans)
CREATE TABLE prestamo (
    noprestamo VARCHAR2(15),
    idsucursal VARCHAR2(5),
    cantidad NUMBER,
    PRIMARY KEY(noprestamo),
    FOREIGN KEY(idsucursal) REFERENCES sucursal(idsucursal)
);

-- Insert Region A data
PROMPT Inserting Region A data...

INSERT INTO sucursal VALUES ('S0001', 'Downtown', 'Brooklyn', 900000, 'A');
INSERT INTO sucursal VALUES ('S0002', 'Redwood', 'Palo Alto', 2100000, 'A');
INSERT INTO sucursal VALUES ('S0003', 'Perryridge', 'Horseneck', 1700000, 'A');
INSERT INTO sucursal VALUES ('S0004', 'Mianus', 'Horseneck', 400200, 'A');

INSERT INTO prestamo VALUES ('L-17', 'S0001', 1000);
INSERT INTO prestamo VALUES ('L-23', 'S0002', 2000);
INSERT INTO prestamo VALUES ('L-15', 'S0003', 1500);
INSERT INTO prestamo VALUES ('L-14', 'S0001', 1500);
INSERT INTO prestamo VALUES ('L-93', 'S0004', 500);
INSERT INTO prestamo VALUES ('L-16', 'S0003', 1300);

COMMIT;

-- Verify data
PROMPT Verifying Region A data...
SELECT 'Sucursales in Region A: ' || COUNT(*) AS info FROM sucursal;
SELECT 'Prestamos in Region A: ' || COUNT(*) AS info FROM prestamo;

PROMPT 
PROMPT Node 1 (Region A) setup complete!
EXIT;

