#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
🖼️ TERS: The Event Registration Solution - GUI Application
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    GTK4-based GUI application for race registration management.

👤 AUTHOR: TEMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw, Gio, GLib

import sys
import os
from pathlib import Path
from datetime import datetime, date
import logging

# Find TEMS base directory
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

# Add TRDS libraries to path
sys.path.insert(0, str(TRDS_DIR / 'libraries'))

from models.race import Race, race_manager
from database.connection import db_manager
from utils.config import config
from utils.paths import paths

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(paths.get_log_dir('ters') / 'gui.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class TERSApplication(Adw.Application):
    """Main GTK4 application class."""
    
    def __init__(self):
        """Initialize application."""
        super().__init__(application_id='com.tems.ters')
        self.window = None
        logger.info("TERS GUI Application initialized")
    
    def do_activate(self):
        """Activate application."""
        if not self.window:
            self.window = TERSMainWindow(self)
        self.window.present()
    
    def do_startup(self):
        """Application startup."""
        Adw.Application.do_startup(self)
        
        # Test database connection
        if not db_manager.test_connection():
            dialog = Adw.MessageDialog.new(
                None,
                "Database Connection Failed",
                "Cannot connect to the database. Please check your configuration."
            )
            dialog.add_response("ok", "OK")
            dialog.present()

class TERSMainWindow(Adw.ApplicationWindow):
    """Main application window."""
    
    def __init__(self, app):
        """Initialize main window."""
        super().__init__(application=app)
        
        self.set_title("TERS: The Event Registration Solution")
        self.set_default_size(1200, 800)
        
        # Get database status
        db_status = db_manager.get_status()
        db_type = "☁️ Cloud" if db_status['is_cloud'] else "💾 Local"
        
        # Create header bar
        header = Adw.HeaderBar()
        
        # Add title with database status
        title_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        title_label = Gtk.Label(label="TERS: Event Registration")
        title_label.add_css_class("title")
        subtitle_label = Gtk.Label(label=f"Database: {db_type}")
        subtitle_label.add_css_class("subtitle")
        title_box.append(title_label)
        title_box.append(subtitle_label)
        header.set_title_widget(title_box)
        
        # Add new race button
        new_race_btn = Gtk.Button(label="New Race")
        new_race_btn.add_css_class("suggested-action")
        new_race_btn.connect("clicked", self.on_new_race)
        header.pack_start(new_race_btn)
        
        # Create main content
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        main_box.set_margin_top(12)
        main_box.set_margin_bottom(12)
        main_box.set_margin_start(12)
        main_box.set_margin_end(12)
        
        # Create toolbar
        toolbar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        
        refresh_btn = Gtk.Button(label="Refresh")
        refresh_btn.connect("clicked", self.refresh_races)
        toolbar.append(refresh_btn)
        
        main_box.append(toolbar)
        
        # Create race list
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        
        self.race_list = Gtk.ListBox()
        self.race_list.add_css_class("boxed-list")
        scrolled.set_child(self.race_list)
        
        main_box.append(scrolled)
        
        # Set content
        content = Adw.ToolbarView()
        content.add_top_bar(header)
        content.set_content(main_box)
        self.set_content(content)
        
        # Load races
        self.refresh_races()
    
    def refresh_races(self, widget=None):
        """Refresh race list."""
        # Clear existing items
        while self.race_list.get_first_child():
            self.race_list.remove(self.race_list.get_first_child())
        
        # Load races
        races = race_manager.get_all_races()
        
        if not races:
            label = Gtk.Label(label="No races found")
            label.set_margin_top(50)
            label.set_margin_bottom(50)
            self.race_list.append(label)
        else:
            for race in races:
                row = self.create_race_row(race)
                self.race_list.append(row)
    
    def create_race_row(self, race):
        """Create a row for race display."""
        row = Gtk.ListBoxRow()
        
        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        box.set_margin_top(6)
        box.set_margin_bottom(6)
        box.set_margin_start(12)
        box.set_margin_end(12)
        
        # Race info
        info_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=3)
        info_box.set_hexpand(True)
        
        name_label = Gtk.Label(label=race.race_name)
        name_label.add_css_class("heading")
        name_label.set_halign(Gtk.Align.START)
        info_box.append(name_label)
        
        details = f"{race.race_date} • {race.race_venue or 'TBD'}"
        details_label = Gtk.Label(label=details)
        details_label.add_css_class("dim-label")
        details_label.set_halign(Gtk.Align.START)
        info_box.append(details_label)
        
        box.append(info_box)
        
        # Action buttons
        edit_btn = Gtk.Button(label="Edit")
        edit_btn.connect("clicked", self.on_edit_race, race)
        box.append(edit_btn)
        
        delete_btn = Gtk.Button(label="Delete")
        delete_btn.add_css_class("destructive-action")
        delete_btn.connect("clicked", self.on_delete_race, race)
        box.append(delete_btn)
        
        row.set_child(box)
        return row
    
    def on_new_race(self, widget):
        """Handle new race button."""
        dialog = RaceDialog(self, None)
        dialog.present()
    
    def on_edit_race(self, widget, race):
        """Handle edit race button."""
        dialog = RaceDialog(self, race)
        dialog.present()
    
    def on_delete_race(self, widget, race):
        """Handle delete race button."""
        dialog = Adw.MessageDialog.new(
            self,
            f"Delete {race.race_name}?",
            "This action cannot be undone."
        )
        dialog.add_response("cancel", "Cancel")
        dialog.add_response("delete", "Delete")
        dialog.set_response_appearance("delete", Adw.ResponseAppearance.DESTRUCTIVE)
        
        dialog.connect("response", self.on_delete_confirmed, race)
        dialog.present()
    
    def on_delete_confirmed(self, dialog, response, race):
        """Handle delete confirmation."""
        if response == "delete":
            if race_manager.delete_race(race.race_id):
                self.refresh_races()

class RaceDialog(Adw.Window):
    """Dialog for creating/editing races."""
    
    def __init__(self, parent, race=None):
        """Initialize race dialog."""
        super().__init__()
        
        self.parent_window = parent
        self.race = race
        
        self.set_title("Edit Race" if race else "New Race")
        self.set_default_size(500, 600)
        self.set_transient_for(parent)
        self.set_modal(True)
        
        # Create header bar
        header = Adw.HeaderBar()
        
        cancel_btn = Gtk.Button(label="Cancel")
        cancel_btn.connect("clicked", lambda x: self.close())
        header.pack_start(cancel_btn)
        
        save_btn = Gtk.Button(label="Save")
        save_btn.add_css_class("suggested-action")
        save_btn.connect("clicked", self.on_save)
        header.pack_end(save_btn)
        
        # Create form
        form_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        form_box.set_margin_top(12)
        form_box.set_margin_bottom(12)
        form_box.set_margin_start(12)
        form_box.set_margin_end(12)
        
        # Form fields
        self.name_entry = Adw.EntryRow()
        self.name_entry.set_title("Race Name")
        if race:
            self.name_entry.set_text(race.race_name)
        form_box.append(self.name_entry)
        
        self.venue_entry = Adw.EntryRow()
        self.venue_entry.set_title("Venue")
        if race:
            self.venue_entry.set_text(race.race_venue or "")
        form_box.append(self.venue_entry)
        
        self.date_entry = Adw.EntryRow()
        self.date_entry.set_title("Date (YYYY-MM-DD)")
        if race:
            self.date_entry.set_text(str(race.race_date))
        form_box.append(self.date_entry)
        
        # Set content
        content = Adw.ToolbarView()
        content.add_top_bar(header)
        
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_child(form_box)
        content.set_content(scrolled)
        
        self.set_content(content)
    
    def on_save(self, widget):
        """Save race data."""
        try:
            if self.race:
                # Update existing
                self.race.race_name = self.name_entry.get_text()
                self.race.race_venue = self.venue_entry.get_text()
                self.race.race_date = datetime.strptime(
                    self.date_entry.get_text(), '%Y-%m-%d'
                ).date()
                
                if race_manager.update_race(self.race.race_id, self.race):
                    self.parent_window.refresh_races()
                    self.close()
            else:
                # Create new
                race = Race(
                    race_name=self.name_entry.get_text(),
                    race_venue=self.venue_entry.get_text(),
                    race_date=datetime.strptime(
                        self.date_entry.get_text(), '%Y-%m-%d'
                    ).date(),
                    race_type="road_race"
                )
                
                if race_manager.create_race(race):
                    self.parent_window.refresh_races()
                    self.close()
                    
        except Exception as e:
            dialog = Adw.MessageDialog.new(self, "Error", str(e))
            dialog.add_response("ok", "OK")
            dialog.present()

def main():
    """Main entry point."""
    app = TERSApplication()
    app.run(sys.argv)

if __name__ == "__main__":
    main()
