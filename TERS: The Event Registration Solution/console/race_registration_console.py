#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
🏁 TERS: The Event Registration Solution - Console Application
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Console application for race registration management. Part of the TEMS
    ecosystem, working alongside TRTS for complete race management.

👤 AUTHOR: TEMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

import sys
import os
from pathlib import Path
from datetime import datetime, date, time
import logging

# Find TEMS base directory and add libraries to path
def find_tems_base():
    """Find TEMS base directory from current location."""
    current = Path(__file__).resolve()
    while current != current.parent:
        for parent in current.parents:
            if 'TEMS: The Event Management Solution' in parent.name:
                return parent
        current = current.parent
    return Path(os.environ.get('TEMS_BASE', Path.cwd()))

TEMS_BASE = find_tems_base()
TRDS_DIR = TEMS_BASE / 'TRDS: The Race Data Solution'

# Add TRDS libraries to Python path
sys.path.insert(0, str(TRDS_DIR / 'libraries'))

# Import from shared libraries
from models.race import Race, race_manager
from database.connection import db_manager
from utils.config import config
from utils.paths import paths

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(paths.get_log_dir('ters') / 'console.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class TERSConsole:
    """Main console application for TERS."""
    
    def __init__(self):
        """Initialize the console application."""
        self.running = False
        self.db_status = db_manager.get_status()
        logger.info(f"TERS Console initialized - Database: {'CLOUD' if self.db_status['is_cloud'] else 'LOCAL'}")
    
    def start(self):
        """Start the console application."""
        try:
            logger.info("Starting TERS Console Application")
            
            # Test database connection
            if not db_manager.test_connection():
                print("❌ Error: Cannot connect to database!")
                print(f"🔧 Attempted connection to: {self.db_status['host']}")
                return
            
            self.show_banner()
            self.running = True
            self.main_loop()
            
        except KeyboardInterrupt:
            print("\n\n🛑 Application interrupted by user")
        except Exception as e:
            print(f"\n❌ Application error: {e}")
            logger.error(f"Application error: {e}")
        finally:
            self.cleanup()
    
    def show_banner(self):
        """Display application banner."""
        db_type = "☁️ CLOUD" if self.db_status['is_cloud'] else "💾 LOCAL"
        
        print("\n" + "="*70)
        print("   🏁 TERS: The Event Registration Solution")
        print("   📋 Console Management Interface v1.0.0")
        print(f"   🔗 Database: {db_type} - {self.db_status['host']}")
        print("   🏃 Ready to manage race registrations!")
        print("="*70)
    
    def main_loop(self):
        """Main application loop."""
        while self.running:
            try:
                self.show_main_menu()
                choice = input("\n🎯 Select option: ").strip()
                self.handle_menu_choice(choice)
                
            except KeyboardInterrupt:
                print("\n\n👋 Goodbye!")
                self.running = False
            except Exception as e:
                logger.error(f"Menu error: {e}")
                print(f"\n❌ Error: {e}")
    
    def show_main_menu(self):
        """Display main menu."""
        print("\n" + "─"*50)
        print("📋 MAIN MENU")
        print("─"*50)
        print("1. 🏁 Race Management")
        print("2. 👥 Participant Registration")
        print("3. 📊 Registration Reports")
        print("4. 💳 Payment Management")
        print("5. 📧 Email Communications")
        print("6. ⚙️  Settings")
        print("0. 👋 Exit")
    
    def handle_menu_choice(self, choice):
        """Handle menu selection."""
        if choice == '1':
            self.race_management_menu()
        elif choice == '2':
            print("👥 Participant registration - Coming soon!")
        elif choice == '3':
            print("📊 Registration reports - Coming soon!")
        elif choice == '4':
            print("💳 Payment management - Coming soon!")
        elif choice == '5':
            print("📧 Email communications - Coming soon!")
        elif choice == '6':
            self.settings_menu()
        elif choice == '0':
            self.running = False
            print("\n👋 Thank you for using TERS!")
        else:
            print("❌ Invalid option")
    
    def race_management_menu(self):
        """Race management submenu."""
        while True:
            print("\n" + "─"*40)
            print("🏁 RACE MANAGEMENT")
            print("─"*40)
            print("1. ➕ Create New Race")
            print("2. 📋 View All Races")
            print("3. ✏️  Edit Race")
            print("4. ❌ Delete Race")
            print("5. 📅 Upcoming Races")
            print("0. ⬅️  Back")
            
            choice = input("\n🎯 Select option: ").strip()
            
            if choice == '1':
                self.create_race()
            elif choice == '2':
                self.view_all_races()
            elif choice == '3':
                self.edit_race()
            elif choice == '4':
                self.delete_race()
            elif choice == '5':
                self.view_upcoming_races()
            elif choice == '0':
                break
            else:
                print("❌ Invalid option")
    
    def create_race(self):
        """Create a new race."""
        print("\n➕ CREATE NEW RACE")
        print("="*40)
        
        try:
            race_data = {}
            race_data['race_name'] = input("Race Name: ").strip()
            race_data['race_description'] = input("Description: ").strip()
            race_data['race_date'] = datetime.strptime(
                input("Date (YYYY-MM-DD): ").strip(), '%Y-%m-%d'
            ).date()
            
            time_input = input("Time (HH:MM) or Enter to skip: ").strip()
            if time_input:
                race_data['race_time'] = datetime.strptime(time_input, '%H:%M').time()
            
            race_data['race_venue'] = input("Venue: ").strip()
            race_data['race_type'] = input("Type (road_race/cross_country): ").strip()
            race_data['race_distances'] = input("Distances: ").strip()
            race_data['registration_limit'] = int(input("Registration Limit (0 for unlimited): ") or 0)
            race_data['entry_fee'] = float(input("Entry Fee: $") or 0)
            
            race = Race(**race_data)
            race_id = race_manager.create_race(race)
            
            if race_id:
                print(f"\n✅ Race created successfully! ID: {race_id}")
            else:
                print("\n❌ Failed to create race")
                
        except Exception as e:
            print(f"\n❌ Error: {e}")
    
    def view_all_races(self):
        """View all races."""
        races = race_manager.get_all_races()
        
        if not races:
            print("\n📭 No races found")
            return
        
        print("\n📋 ALL RACES")
        print("="*80)
        print(f"{'ID':<5} {'Name':<30} {'Date':<12} {'Venue':<20} {'Type':<10}")
        print("-"*80)
        
        for race in races:
            print(f"{race.race_id:<5} {race.race_name[:28]:<30} "
                  f"{race.race_date:<12} {(race.race_venue or 'TBD')[:18]:<20} "
                  f"{race.race_type:<10}")
    
    def view_upcoming_races(self):
        """View upcoming races."""
        races = race_manager.get_upcoming_races()
        
        if not races:
            print("\n📭 No upcoming races")
            return
        
        print("\n📅 UPCOMING RACES")
        print("="*60)
        
        for race in races:
            days_until = (race.race_date - date.today()).days
            print(f"\n🏁 {race.race_name}")
            print(f"   📅 {race.race_date} ({days_until} days)")
            print(f"   📍 {race.race_venue or 'TBD'}")
            print(f"   💰 ${race.entry_fee or 0:.2f}")
    
    def edit_race(self):
        """Edit existing race."""
        race_id = input("\nEnter Race ID to edit: ").strip()
        
        try:
            race = race_manager.get_race_by_id(int(race_id))
            if not race:
                print("❌ Race not found")
                return
            
            print(f"\n✏️ Editing: {race.race_name}")
            print("Press Enter to keep current value")
            
            # Update fields
            race.race_name = input(f"Name [{race.race_name}]: ").strip() or race.race_name
            race.race_venue = input(f"Venue [{race.race_venue}]: ").strip() or race.race_venue
            
            if race_manager.update_race(int(race_id), race):
                print("✅ Race updated successfully!")
            else:
                print("❌ Failed to update race")
                
        except Exception as e:
            print(f"❌ Error: {e}")
    
    def delete_race(self):
        """Delete a race."""
        race_id = input("\nEnter Race ID to delete: ").strip()
        
        try:
            race = race_manager.get_race_by_id(int(race_id))
            if not race:
                print("❌ Race not found")
                return
            
            print(f"\n⚠️ Delete race: {race.race_name}?")
            if input("Type 'DELETE' to confirm: ").strip() == 'DELETE':
                if race_manager.delete_race(int(race_id)):
                    print("✅ Race deleted successfully!")
                else:
                    print("❌ Failed to delete race")
            else:
                print("❌ Deletion cancelled")
                
        except Exception as e:
            print(f"❌ Error: {e}")
    
    def settings_menu(self):
        """Settings menu."""
        print("\n⚙️ SETTINGS")
        print("="*40)
        print(f"Database: {'CLOUD' if self.db_status['is_cloud'] else 'LOCAL'}")
        print(f"Host: {self.db_status['host']}")
        print(f"Database: {self.db_status['database']}")
        print(f"Connected: {'Yes' if self.db_status['connected'] else 'No'}")
    
    def cleanup(self):
        """Cleanup on exit."""
        logger.info("TERS Console shutdown")

def main():
    """Main entry point."""
    app = TERSConsole()
    app.start()

if __name__ == "__main__":
    main()
