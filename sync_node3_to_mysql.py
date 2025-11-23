#!/usr/bin/env python3
"""
Sync script to copy data from Oracle Node 3 to MySQL
This script replicates all data from Node 3 (full replication node) to MySQL (backup)
"""

import oracledb
import mysql.connector
from mysql.connector import Error
import sys
from datetime import datetime

# oracledb uses thin mode by default (no Oracle Client required)

class DataSync:
    """Syncs data from Oracle Node 3 to MySQL"""
    
    def __init__(self):
        self.oracle_conn = None
        self.mysql_conn = None
        self.oracle_cursor = None
        self.mysql_cursor = None
        
    def connect_oracle(self):
        """Connect to Oracle Node 3"""
        try:
            # Use thin mode connection string (no Oracle Client needed)
            self.oracle_conn = oracledb.connect(
                user='system',
                password='Oracle123',
                host='localhost',
                port=1523,
                service_name='XE'
            )
            self.oracle_cursor = self.oracle_conn.cursor()
            print("✓ Connected to Oracle Node 3")
            return True
        except Exception as e:
            print(f"✗ Error connecting to Oracle Node 3: {e}")
            return False
    
    def connect_mysql(self):
        """Connect to MySQL"""
        try:
            self.mysql_conn = mysql.connector.connect(
                host='localhost',
                port=3306,
                database='bankdb',
                user='bankuser',
                password='bankpass123'
            )
            self.mysql_cursor = self.mysql_conn.cursor()
            print("✓ Connected to MySQL")
            return True
        except Error as e:
            print(f"✗ Error connecting to MySQL: {e}")
            return False
    
    def sync_sucursal(self):
        """Sync sucursal (branches) table"""
        print("\n--- Syncing sucursal table ---")
        
        try:
            # Fetch all data from Oracle Node 3
            self.oracle_cursor.execute("""
                SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region
                FROM sucursal
                ORDER BY idsucursal
            """)
            
            oracle_data = self.oracle_cursor.fetchall()
            print(f"Found {len(oracle_data)} branches in Oracle Node 3")
            
            # Clear MySQL table (or use upsert)
            self.mysql_cursor.execute("DELETE FROM prestamo")  # Delete loans first (FK constraint)
            self.mysql_cursor.execute("DELETE FROM sucursal")
            
            # Insert all data into MySQL
            insert_query = """
                INSERT INTO sucursal (idsucursal, nombresucursal, ciudadsucursal, activos, region)
                VALUES (%s, %s, %s, %s, %s)
            """
            
            self.mysql_cursor.executemany(insert_query, oracle_data)
            self.mysql_conn.commit()
            
            print(f"✓ Synced {len(oracle_data)} branches to MySQL")
            return True
            
        except Exception as e:
            print(f"✗ Error syncing sucursal: {e}")
            self.mysql_conn.rollback()
            return False
    
    def sync_prestamo(self):
        """Sync prestamo (loans) table"""
        print("\n--- Syncing prestamo table ---")
        
        try:
            # Fetch all data from Oracle Node 3
            self.oracle_cursor.execute("""
                SELECT noprestamo, idsucursal, cantidad
                FROM prestamo
                ORDER BY noprestamo
            """)
            
            oracle_data = self.oracle_cursor.fetchall()
            print(f"Found {len(oracle_data)} loans in Oracle Node 3")
            
            # Insert all data into MySQL
            insert_query = """
                INSERT INTO prestamo (noprestamo, idsucursal, cantidad)
                VALUES (%s, %s, %s)
            """
            
            self.mysql_cursor.executemany(insert_query, oracle_data)
            self.mysql_conn.commit()
            
            print(f"✓ Synced {len(oracle_data)} loans to MySQL")
            return True
            
        except Exception as e:
            print(f"✗ Error syncing prestamo: {e}")
            self.mysql_conn.rollback()
            return False
    
    def verify_sync(self):
        """Verify that data was synced correctly"""
        print("\n--- Verifying sync ---")
        
        try:
            # Count in Oracle
            self.oracle_cursor.execute("SELECT COUNT(*) FROM sucursal")
            oracle_sucursal_count = self.oracle_cursor.fetchone()[0]
            
            self.oracle_cursor.execute("SELECT COUNT(*) FROM prestamo")
            oracle_prestamo_count = self.oracle_cursor.fetchone()[0]
            
            # Count in MySQL
            self.mysql_cursor.execute("SELECT COUNT(*) FROM sucursal")
            mysql_sucursal_count = self.mysql_cursor.fetchone()[0]
            
            self.mysql_cursor.execute("SELECT COUNT(*) FROM prestamo")
            mysql_prestamo_count = self.mysql_cursor.fetchone()[0]
            
            print(f"Oracle Node 3 - Sucursales: {oracle_sucursal_count}, Prestamos: {oracle_prestamo_count}")
            print(f"MySQL - Sucursales: {mysql_sucursal_count}, Prestamos: {mysql_prestamo_count}")
            
            if (oracle_sucursal_count == mysql_sucursal_count and 
                oracle_prestamo_count == mysql_prestamo_count):
                print("✓ Sync verification successful - counts match!")
                return True
            else:
                print("⚠ Warning - counts don't match!")
                return False
                
        except Exception as e:
            print(f"✗ Error verifying sync: {e}")
            return False
    
    def sync(self):
        """Perform full sync"""
        print("="*60)
        print("  SYNC: Oracle Node 3 → MySQL")
        print(f"  Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*60)
        
        # Connect to databases
        if not self.connect_oracle():
            return False
        
        if not self.connect_mysql():
            self.close()
            return False
        
        # Sync tables (sucursal first due to FK constraint)
        success = True
        success = self.sync_sucursal() and success
        success = self.sync_prestamo() and success
        
        # Verify
        if success:
            self.verify_sync()
        
        # Close connections
        self.close()
        
        print("\n" + "="*60)
        if success:
            print("✓ Sync completed successfully!")
        else:
            print("✗ Sync completed with errors")
        print("="*60)
        
        return success
    
    def close(self):
        """Close all connections"""
        if self.oracle_cursor:
            self.oracle_cursor.close()
        if self.oracle_conn:
            self.oracle_conn.close()
        if self.mysql_cursor:
            self.mysql_cursor.close()
        if self.mysql_conn:
            self.mysql_conn.close()

def main():
    """Main function"""
    syncer = DataSync()
    
    try:
        success = syncer.sync()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\nSync interrupted by user")
        syncer.close()
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ Unexpected error: {e}")
        syncer.close()
        sys.exit(1)

if __name__ == '__main__':
    main()

