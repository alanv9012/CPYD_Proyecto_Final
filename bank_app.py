#!/usr/bin/env python3
"""
Distributed Banks/Loans Application
Connects to one node and provides transparent access to all regions
"""

import oracledb
import mysql.connector
from mysql.connector import Error
import sys
from typing import Optional, List, Tuple

# oracledb uses thin mode by default (no Oracle Client required)

class BankDatabase:
    """Manages connections to distributed database nodes"""
    
    def __init__(self, node: str = 'node1'):
        """
        Initialize database connection
        node: 'node1', 'node2', 'node3', or 'mysql'
        """
        self.node = node
        self.connection = None
        self.cursor = None
        self.connect()
    
    def connect(self):
        """Establish connection to the specified node"""
        try:
            if self.node == 'node1':
                # Oracle Node 1 (Region A)
                self.connection = oracledb.connect(
                    user='system',
                    password='Oracle123',
                    host='localhost',
                    port=1521,
                    service_name='XE'
                )
                print("✓ Connected to Oracle Node 1 (Region A)")
                
            elif self.node == 'node2':
                # Oracle Node 2 (Region B)
                self.connection = oracledb.connect(
                    user='system',
                    password='Oracle123',
                    host='localhost',
                    port=1522,
                    service_name='XE'
                )
                print("✓ Connected to Oracle Node 2 (Region B)")
                
            elif self.node == 'node3':
                # Oracle Node 3 (Full Replication)
                self.connection = oracledb.connect(
                    user='system',
                    password='Oracle123',
                    host='localhost',
                    port=1523,
                    service_name='XE'
                )
                print("✓ Connected to Oracle Node 3 (Full Replication)")
                
            elif self.node == 'mysql':
                # MySQL Database
                self.connection = mysql.connector.connect(
                    host='localhost',
                    port=3306,
                    database='bankdb',
                    user='bankuser',
                    password='bankpass123'
                )
                print("✓ Connected to MySQL Database")
            else:
                raise ValueError(f"Unknown node: {self.node}")
            
            self.cursor = self.connection.cursor()
            
        except Exception as e:
            print(f"✗ Error connecting to {self.node}: {e}")
            sys.exit(1)
    
    def query_all_branches(self) -> List[Tuple]:
        """Query all branches from all regions"""
        if self.node == 'mysql':
            query = "SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region FROM sucursal"
            self.cursor.execute(query)
        else:
            # Use global view if available, otherwise query local + remote
            query = """
                SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region 
                FROM global_sucursal
                ORDER BY region, idsucursal
            """
            self.cursor.execute(query)
        
        return self.cursor.fetchall()
    
    def query_branches_by_region(self, region: str) -> List[Tuple]:
        """Query branches by region"""
        if self.node == 'mysql':
            query = "SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region FROM sucursal WHERE region = %s"
            self.cursor.execute(query, (region,))
        else:
            query = """
                SELECT idsucursal, nombresucursal, ciudadsucursal, activos, region 
                FROM global_sucursal
                WHERE region = :region
                ORDER BY idsucursal
            """
            self.cursor.execute(query, {'region': region})
        
        return self.cursor.fetchall()
    
    def query_all_loans(self) -> List[Tuple]:
        """Query all loans from all regions"""
        if self.node == 'mysql':
            query = """
                SELECT p.noprestamo, p.idsucursal, p.cantidad, s.region
                FROM prestamo p
                JOIN sucursal s ON p.idsucursal = s.idsucursal
                ORDER BY s.region, p.noprestamo
            """
            self.cursor.execute(query)
        else:
            query = """
                SELECT noprestamo, idsucursal, cantidad, region 
                FROM global_prestamo
                ORDER BY region, noprestamo
            """
            self.cursor.execute(query)
        
        return self.cursor.fetchall()
    
    def query_loans_by_region(self, region: str) -> List[Tuple]:
        """Query loans by region"""
        if self.node == 'mysql':
            query = """
                SELECT p.noprestamo, p.idsucursal, p.cantidad, s.region
                FROM prestamo p
                JOIN sucursal s ON p.idsucursal = s.idsucursal
                WHERE s.region = %s
                ORDER BY p.noprestamo
            """
            self.cursor.execute(query, (region,))
        else:
            query = """
                SELECT noprestamo, idsucursal, cantidad, region 
                FROM global_prestamo
                WHERE region = :region
                ORDER BY noprestamo
            """
            self.cursor.execute(query, {'region': region})
        
        return self.cursor.fetchall()
    
    def insert_branch(self, idsucursal: str, nombresucursal: str, 
                     ciudadsucursal: str, activos: float, region: str) -> bool:
        """
        Insert a new branch, routing to correct node based on region
        Returns True if successful
        """
        try:
            # Determine target node based on region
            if region == 'A':
                target_node = 'node1'
            elif region == 'B':
                target_node = 'node2'
            else:
                print(f"✗ Invalid region: {region}. Must be 'A' or 'B'")
                return False
            
            # If we're not on the target node, we need to route
            if self.node != target_node and self.node != 'node3':
                print(f"⚠ Note: Branch belongs to Region {region}, should be inserted on {target_node}")
                print(f"  Currently connected to {self.node}. Inserting anyway...")
            
            if self.node == 'mysql':
                query = """
                    INSERT INTO sucursal (idsucursal, nombresucursal, ciudadsucursal, activos, region)
                    VALUES (%s, %s, %s, %s, %s)
                """
                self.cursor.execute(query, (idsucursal, nombresucursal, ciudadsucursal, activos, region))
            else:
                query = """
                    INSERT INTO sucursal (idsucursal, nombresucursal, ciudadsucursal, activos, region)
                    VALUES (:1, :2, :3, :4, :5)
                """
                self.cursor.execute(query, (idsucursal, nombresucursal, ciudadsucursal, activos, region))
            
            self.connection.commit()
            print(f"✓ Branch {idsucursal} inserted successfully")
            return True
            
        except Exception as e:
            print(f"✗ Error inserting branch: {e}")
            self.connection.rollback()
            return False
    
    def insert_loan(self, noprestamo: str, idsucursal: str, cantidad: float) -> bool:
        """
        Insert a new loan, routing to correct node based on branch region
        Returns True if successful
        """
        try:
            # First, find the branch to determine its region
            if self.node == 'mysql':
                query = "SELECT region FROM sucursal WHERE idsucursal = %s"
                self.cursor.execute(query, (idsucursal,))
            else:
                query = "SELECT region FROM global_sucursal WHERE idsucursal = :1"
                self.cursor.execute(query, (idsucursal,))
            
            result = self.cursor.fetchone()
            if not result:
                print(f"✗ Branch {idsucursal} not found")
                return False
            
            region = result[0]
            target_node = 'node1' if region == 'A' else 'node2'
            
            if self.node != target_node and self.node != 'node3':
                print(f"⚠ Note: Loan belongs to Region {region} branch, should be inserted on {target_node}")
            
            if self.node == 'mysql':
                query = """
                    INSERT INTO prestamo (noprestamo, idsucursal, cantidad)
                    VALUES (%s, %s, %s)
                """
                self.cursor.execute(query, (noprestamo, idsucursal, cantidad))
            else:
                query = """
                    INSERT INTO prestamo (noprestamo, idsucursal, cantidad)
                    VALUES (:1, :2, :3)
                """
                self.cursor.execute(query, (noprestamo, idsucursal, cantidad))
            
            self.connection.commit()
            print(f"✓ Loan {noprestamo} inserted successfully")
            return True
            
        except Exception as e:
            print(f"✗ Error inserting loan: {e}")
            self.connection.rollback()
            return False
    
    def get_statistics(self) -> dict:
        """Get statistics about branches and loans"""
        stats = {}
        
        try:
            if self.node == 'mysql':
                # MySQL queries
                self.cursor.execute("SELECT COUNT(*) FROM sucursal")
                stats['total_branches'] = self.cursor.fetchone()[0]
                
                self.cursor.execute("SELECT COUNT(*) FROM prestamo")
                stats['total_loans'] = self.cursor.fetchone()[0]
                
                self.cursor.execute("SELECT SUM(activos) FROM sucursal")
                stats['total_assets'] = self.cursor.fetchone()[0] or 0
                
                self.cursor.execute("SELECT SUM(cantidad) FROM prestamo")
                stats['total_loans_amount'] = self.cursor.fetchone()[0] or 0
            else:
                # Oracle queries using global views
                self.cursor.execute("SELECT COUNT(*) FROM global_sucursal")
                stats['total_branches'] = self.cursor.fetchone()[0]
                
                self.cursor.execute("SELECT COUNT(*) FROM global_prestamo")
                stats['total_loans'] = self.cursor.fetchone()[0]
                
                self.cursor.execute("SELECT SUM(activos) FROM global_sucursal")
                stats['total_assets'] = self.cursor.fetchone()[0] or 0
                
                self.cursor.execute("SELECT SUM(cantidad) FROM global_prestamo")
                stats['total_loans_amount'] = self.cursor.fetchone()[0] or 0
                
        except Exception as e:
            print(f"Error getting statistics: {e}")
        
        return stats
    
    def close(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()

def print_menu():
    """Print the main menu"""
    print("\n" + "="*60)
    print("  DISTRIBUTED BANKS/LOANS DATABASE SYSTEM")
    print("="*60)
    print("1. View all branches")
    print("2. View branches by region (A or B)")
    print("3. View all loans")
    print("4. View loans by region (A or B)")
    print("5. Insert new branch")
    print("6. Insert new loan")
    print("7. View statistics")
    print("8. Switch database node")
    print("9. Exit")
    print("="*60)

def print_branches(branches: List[Tuple]):
    """Print branches in a formatted table"""
    if not branches:
        print("No branches found.")
        return
    
    print(f"\n{'ID':<8} {'Name':<15} {'City':<15} {'Assets':<15} {'Region':<8}")
    print("-" * 70)
    for branch in branches:
        print(f"{branch[0]:<8} {branch[1]:<15} {branch[2]:<15} {branch[3]:<15} {branch[4]:<8}")

def print_loans(loans: List[Tuple]):
    """Print loans in a formatted table"""
    if not loans:
        print("No loans found.")
        return
    
    print(f"\n{'Loan ID':<12} {'Branch ID':<10} {'Amount':<15} {'Region':<8}")
    print("-" * 50)
    for loan in loans:
        print(f"{loan[0]:<12} {loan[1]:<10} {loan[2]:<15} {loan[3]:<8}")

def main():
    """Main application loop"""
    # Default to node1
    current_node = 'node1'
    db = BankDatabase(current_node)
    
    print(f"\nConnected to {current_node.upper()}")
    print("You can query data from all regions transparently!")
    
    while True:
        print_menu()
        choice = input("\nEnter your choice: ").strip()
        
        if choice == '1':
            print("\n--- All Branches ---")
            branches = db.query_all_branches()
            print_branches(branches)
            
        elif choice == '2':
            region = input("Enter region (A or B): ").strip().upper()
            if region in ['A', 'B']:
                print(f"\n--- Branches in Region {region} ---")
                branches = db.query_branches_by_region(region)
                print_branches(branches)
            else:
                print("✗ Invalid region. Must be 'A' or 'B'")
                
        elif choice == '3':
            print("\n--- All Loans ---")
            loans = db.query_all_loans()
            print_loans(loans)
            
        elif choice == '4':
            region = input("Enter region (A or B): ").strip().upper()
            if region in ['A', 'B']:
                print(f"\n--- Loans in Region {region} ---")
                loans = db.query_loans_by_region(region)
                print_loans(loans)
            else:
                print("✗ Invalid region. Must be 'A' or 'B'")
                
        elif choice == '5':
            print("\n--- Insert New Branch ---")
            idsucursal = input("Branch ID (e.g., S0010): ").strip()
            nombresucursal = input("Branch Name: ").strip()
            ciudadsucursal = input("City: ").strip()
            try:
                activos = float(input("Assets: ").strip())
            except ValueError:
                print("✗ Invalid assets value")
                continue
            region = input("Region (A or B): ").strip().upper()
            
            if region in ['A', 'B']:
                db.insert_branch(idsucursal, nombresucursal, ciudadsucursal, activos, region)
            else:
                print("✗ Invalid region. Must be 'A' or 'B'")
                
        elif choice == '6':
            print("\n--- Insert New Loan ---")
            noprestamo = input("Loan ID (e.g., L-100): ").strip()
            idsucursal = input("Branch ID: ").strip()
            try:
                cantidad = float(input("Amount: ").strip())
            except ValueError:
                print("✗ Invalid amount value")
                continue
            
            db.insert_loan(noprestamo, idsucursal, cantidad)
            
        elif choice == '7':
            print("\n--- Statistics ---")
            stats = db.get_statistics()
            print(f"Total Branches: {stats.get('total_branches', 0)}")
            print(f"Total Loans: {stats.get('total_loans', 0)}")
            print(f"Total Assets: ${stats.get('total_assets', 0):,.2f}")
            print(f"Total Loans Amount: ${stats.get('total_loans_amount', 0):,.2f}")
            
        elif choice == '8':
            print("\n--- Switch Database Node ---")
            print("Available nodes: node1 (Region A), node2 (Region B), node3 (Replication), mysql")
            new_node = input("Enter node name: ").strip().lower()
            if new_node in ['node1', 'node2', 'node3', 'mysql']:
                db.close()
                current_node = new_node
                db = BankDatabase(current_node)
                print(f"✓ Switched to {current_node.upper()}")
            else:
                print("✗ Invalid node name")
                
        elif choice == '9':
            print("\nExiting...")
            db.close()
            break
        else:
            print("✗ Invalid choice. Please try again.")

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nExiting...")
        sys.exit(0)

