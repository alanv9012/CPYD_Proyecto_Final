-- Create global views on Node 2
-- Node 2 has Region B locally, queries Region A from Node 1

SET SERVEROUTPUT ON;

PROMPT Creating Global Views on Node 2...

BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW global_sucursal';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE VIEW global_sucursal AS
SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region, 'NODE1' AS source_node
FROM sucursal@link_to_node1
WHERE region = 'A'
UNION ALL
SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region, 'NODE2' AS source_node
FROM sucursal
WHERE region = 'B';

BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW global_prestamo';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE VIEW global_prestamo AS
SELECT p.noprestamo, p.idsucursal, p.cantidad, s.region, 'NODE1' AS source_node
FROM prestamo@link_to_node1 p
JOIN sucursal@link_to_node1 s ON p.idsucursal = s.idsucursal
WHERE s.region = 'A'
UNION ALL
SELECT p.noprestamo, p.idsucursal, p.cantidad, s.region, 'NODE2' AS source_node
FROM prestamo p
JOIN sucursal s ON p.idsucursal = s.idsucursal
WHERE s.region = 'B';

PROMPT Global views created on Node 2!
EXIT;

