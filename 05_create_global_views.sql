-- Create global views that union data from all nodes
-- Run this on each Oracle node to enable transparent access

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT Creating Global Views for Transparent Access
PROMPT =====================================================

-- Drop existing views
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW global_sucursal';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW global_prestamo';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Create global view for sucursal (union from all nodes)
PROMPT Creating global_sucursal view...

CREATE VIEW global_sucursal AS
SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region, 'NODE1' AS source_node
FROM sucursal
WHERE region = 'A'
UNION ALL
SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region, 'NODE2' AS source_node
FROM sucursal@link_to_node2
WHERE region = 'B';

-- Create global view for prestamo (union from all nodes)
PROMPT Creating global_prestamo view...

CREATE VIEW global_prestamo AS
SELECT p.noprestamo, p.idsucursal, p.cantidad, s.region, 'NODE1' AS source_node
FROM prestamo p
JOIN sucursal s ON p.idsucursal = s.idsucursal
WHERE s.region = 'A'
UNION ALL
SELECT p.noprestamo, p.idsucursal, p.cantidad, s.region, 'NODE2' AS source_node
FROM prestamo@link_to_node2 p
JOIN sucursal@link_to_node2 s ON p.idsucursal = s.idsucursal
WHERE s.region = 'B';

PROMPT 
PROMPT Global views created successfully!
PROMPT 
PROMPT You can now query:
PROMPT   SELECT * FROM global_sucursal;
PROMPT   SELECT * FROM global_prestamo;
PROMPT

-- Test the views
PROMPT Testing global views...
SELECT 'Total branches in global view: ' || COUNT(*) AS info FROM global_sucursal;
SELECT 'Total loans in global view: ' || COUNT(*) AS info FROM global_prestamo;

EXIT;

