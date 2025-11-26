-- Create global views on Node 3
-- Node 3 has all data locally, but we'll query from Node 1 and Node 2 for consistency
-- Or we can use local data since Node 3 has everything

SET SERVEROUTPUT ON;

PROMPT Creating Global Views on Node 3...

BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW global_sucursal';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Option 1: Use local data (Node 3 has all data)
CREATE VIEW global_sucursal AS
SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region, 'NODE3' AS source_node
FROM sucursal
ORDER BY region, idsucursal;

-- Option 2: Or query from Node 1 and Node 2 (commented out)
-- CREATE VIEW global_sucursal AS
-- SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region, 'NODE1' AS source_node
-- FROM sucursal@link_to_node1
-- WHERE region = 'A'
-- UNION ALL
-- SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region, 'NODE2' AS source_node
-- FROM sucursal@link_to_node2
-- WHERE region = 'B';

BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW global_prestamo';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Option 1: Use local data
CREATE VIEW global_prestamo AS
SELECT p.noprestamo, p.idsucursal, p.cantidad, s.region, 'NODE3' AS source_node
FROM prestamo p
JOIN sucursal s ON p.idsucursal = s.idsucursal
ORDER BY s.region, p.noprestamo;

PROMPT Global views created on Node 3!
EXIT;

