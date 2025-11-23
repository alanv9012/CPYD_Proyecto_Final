-- =====================================================
-- Database Link Setup for All Nodes
-- Creates database links between all Oracle nodes
-- =====================================================
-- Run this script on Node 1, Node 2, and Node 3

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT Setting up Database Links
PROMPT =====================================================

-- =====================================================
-- Node 1: Create links to Node 2 and Node 3
-- =====================================================

PROMPT Creating links from Node 1...

BEGIN
    EXECUTE IMMEDIATE 'DROP DATABASE LINK link_to_node2';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE DATABASE LINK link_to_node2
CONNECT TO system
IDENTIFIED BY "Oracle123"
USING '(DESCRIPTION=
    (ADDRESS=(PROTOCOL=TCP)(HOST=oracle-node2)(PORT=1521))
    (CONNECT_DATA=(SERVICE_NAME=XE))
)';

BEGIN
    EXECUTE IMMEDIATE 'DROP DATABASE LINK link_to_node3';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE DATABASE LINK link_to_node3
CONNECT TO system
IDENTIFIED BY "Oracle123"
USING '(DESCRIPTION=
    (ADDRESS=(PROTOCOL=TCP)(HOST=oracle-node3)(PORT=1521))
    (CONNECT_DATA=(SERVICE_NAME=XE))
)';

-- =====================================================
-- Node 2: Create links to Node 1 and Node 3
-- =====================================================

PROMPT Creating links from Node 2...

BEGIN
    EXECUTE IMMEDIATE 'DROP DATABASE LINK link_to_node1';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE DATABASE LINK link_to_node1
CONNECT TO system
IDENTIFIED BY "Oracle123"
USING '(DESCRIPTION=
    (ADDRESS=(PROTOCOL=TCP)(HOST=oracle-node1)(PORT=1521))
    (CONNECT_DATA=(SERVICE_NAME=XE))
)';

BEGIN
    EXECUTE IMMEDIATE 'DROP DATABASE LINK link_to_node3';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE DATABASE LINK link_to_node3
CONNECT TO system
IDENTIFIED BY "Oracle123"
USING '(DESCRIPTION=
    (ADDRESS=(PROTOCOL=TCP)(HOST=oracle-node3)(PORT=1521))
    (CONNECT_DATA=(SERVICE_NAME=XE))
)';

-- =====================================================
-- Node 3: Create links to Node 1 and Node 2
-- =====================================================

PROMPT Creating links from Node 3...

BEGIN
    EXECUTE IMMEDIATE 'DROP DATABASE LINK link_to_node1';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE DATABASE LINK link_to_node1
CONNECT TO system
IDENTIFIED BY "Oracle123"
USING '(DESCRIPTION=
    (ADDRESS=(PROTOCOL=TCP)(HOST=oracle-node1)(PORT=1521))
    (CONNECT_DATA=(SERVICE_NAME=XE))
)';

BEGIN
    EXECUTE IMMEDIATE 'DROP DATABASE LINK link_to_node2';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

CREATE DATABASE LINK link_to_node2
CONNECT TO system
IDENTIFIED BY "Oracle123"
USING '(DESCRIPTION=
    (ADDRESS=(PROTOCOL=TCP)(HOST=oracle-node2)(PORT=1521))
    (CONNECT_DATA=(SERVICE_NAME=XE))
)';

-- =====================================================
-- Test Connections
-- =====================================================

PROMPT Testing database links...

-- Test Node 1 links
BEGIN
    SELECT 'Node 1 -> Node 2: OK' FROM dual@link_to_node2;
    DBMS_OUTPUT.PUT_LINE('✓ Node 1 can connect to Node 2');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Node 1 cannot connect to Node 2');
END;
/

BEGIN
    SELECT 'Node 1 -> Node 3: OK' FROM dual@link_to_node3;
    DBMS_OUTPUT.PUT_LINE('✓ Node 1 can connect to Node 3');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Node 1 cannot connect to Node 3');
END;
/

-- Test Node 2 links
BEGIN
    SELECT 'Node 2 -> Node 1: OK' FROM dual@link_to_node1;
    DBMS_OUTPUT.PUT_LINE('✓ Node 2 can connect to Node 1');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Node 2 cannot connect to Node 1');
END;
/

BEGIN
    SELECT 'Node 2 -> Node 3: OK' FROM dual@link_to_node3;
    DBMS_OUTPUT.PUT_LINE('✓ Node 2 can connect to Node 3');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Node 2 cannot connect to Node 3');
END;
/

-- Test Node 3 links
BEGIN
    SELECT 'Node 3 -> Node 1: OK' FROM dual@link_to_node1;
    DBMS_OUTPUT.PUT_LINE('✓ Node 3 can connect to Node 1');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Node 3 cannot connect to Node 1');
END;
/

BEGIN
    SELECT 'Node 3 -> Node 2: OK' FROM dual@link_to_node2;
    DBMS_OUTPUT.PUT_LINE('✓ Node 3 can connect to Node 2');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Node 3 cannot connect to Node 2');
END;
/

-- =====================================================
-- Verification
-- =====================================================

PROMPT 
PROMPT Verifying database links...
SELECT db_link, username, host, created 
FROM user_db_links
ORDER BY db_link;

PROMPT 
PROMPT Database links setup complete!
PROMPT 
PROMPT Note: This script creates all links on each node.
PROMPT Run it on Node 1, Node 2, and Node 3.
PROMPT

COMMIT;
EXIT;

