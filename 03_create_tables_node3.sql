-- Create tables for Node 3 (Full Replication)
-- This node stores all data from both regions

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT Creating Tables on Node 3 (Full Replication)
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
    PRIMARY KEY(idsucursal)
);

-- Create prestamo table (loans)
CREATE TABLE prestamo (
    noprestamo VARCHAR2(15),
    idsucursal VARCHAR2(5),
    cantidad NUMBER,
    PRIMARY KEY(noprestamo),
    FOREIGN KEY(idsucursal) REFERENCES sucursal(idsucursal)
);

-- Insert ALL data (Region A + Region B)
PROMPT Inserting all data (Region A + Region B)...

-- Region A
INSERT INTO sucursal VALUES ('S0001', 'Downtown', 'Brooklyn', 900000, 'A');
INSERT INTO sucursal VALUES ('S0002', 'Redwood', 'Palo Alto', 2100000, 'A');
INSERT INTO sucursal VALUES ('S0003', 'Perryridge', 'Horseneck', 1700000, 'A');
INSERT INTO sucursal VALUES ('S0004', 'Mianus', 'Horseneck', 400200, 'A');

-- Region B
INSERT INTO sucursal VALUES ('S0005', 'Round Hill', 'Horseneck', 8000000, 'B');
INSERT INTO sucursal VALUES ('S0006', 'Pownal', 'Bennington', 400000, 'B');
INSERT INTO sucursal VALUES ('S0007', 'North Town', 'Rye', 3700000, 'B');
INSERT INTO sucursal VALUES ('S0008', 'Brighton', 'Brooklyn', 7000000, 'B');
INSERT INTO sucursal VALUES ('S0009', 'Central', 'Rye', 400280, 'B');

-- Loans Region A
INSERT INTO prestamo VALUES ('L-17', 'S0001', 1000);
INSERT INTO prestamo VALUES ('L-23', 'S0002', 2000);
INSERT INTO prestamo VALUES ('L-15', 'S0003', 1500);
INSERT INTO prestamo VALUES ('L-14', 'S0001', 1500);
INSERT INTO prestamo VALUES ('L-93', 'S0004', 500);
INSERT INTO prestamo VALUES ('L-16', 'S0003', 1300);

-- Loans Region B
INSERT INTO prestamo VALUES ('L-11', 'S0005', 900);
INSERT INTO prestamo VALUES ('L-20', 'S0007', 7500);
INSERT INTO prestamo VALUES ('L-21', 'S0009', 570);

COMMIT;

-- Verify data
PROMPT Verifying all data...
SELECT 'Total Sucursales: ' || COUNT(*) AS info FROM sucursal;
SELECT 'Total Prestamos: ' || COUNT(*) AS info FROM prestamo;
SELECT 'Region A Sucursales: ' || COUNT(*) AS info FROM sucursal WHERE region = 'A';
SELECT 'Region B Sucursales: ' || COUNT(*) AS info FROM sucursal WHERE region = 'B';

PROMPT 
PROMPT Node 3 (Full Replication) setup complete!
EXIT;

