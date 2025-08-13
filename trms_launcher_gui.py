#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
🏁 TRMS: The Race Management Solution - Comprehensive GTK4 Launcher
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Complete launcher with web server management, database configuration,
    and integrated race management features.

👤 AUTHOR: TRMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 2.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
gi.require_version('Vte', '3.91')

from gi.repository import Gtk, Adw, Gio, GLib, Vte, Pango
import os
import sys
import subprocess
import socket
import json
from pathlib import Path
from datetime import datetime, date, timedelta
from typing import Optional, Dict, List
import hashlib
import threading

# Try to import database modules
try:
    import mysql.connector
    from mysql.connector import Error
    DB_AVAILABLE = True
except ImportError:
    DB_AVAILABLE = False
    print("⚠ MySQL connector not available")

class EnvironmentConfig:
    """Manages environment configuration"""
    
    def __init__(self):
        self.environment_type = self.detect_environment()
        self.python_cmd = None
        self.venv_path = None
        self.trms_base = Path.cwd()
        self.config_file = self.trms_base / 'config' / 'launcher_config.json'
        self.load_config()
        
    def detect_environment(self):
        """Detect current environment"""
        if os.path.exists('/.dockerenv'):
            return 'docker'
        elif os.environ.get('VIRTUAL_ENV'):
            return 'virtual'
        else:
            return 'local'
    
    def load_config(self):
        """Load configuration from file"""
        if self.config_file.exists():
            with open(self.config_file, 'r') as f:
                config = json.load(f)
                self.db_config = config.get('database', {})
                self.web_config = config.get('web', {})
        else:
            self.db_config = {
                'host': 'localhost',
                'port': 3306,
                'user': 'trms',
                'password': '',
                'database': 'race_management'
            }
            self.web_config = {
                'host': '0.0.0.0',
                'port': 5000,
                'ssl_port': 443
            }
    
    def save_config(self):
        """Save configuration to file"""
        config = {
            'database': self.db_config,
            'web': self.web_config,
            'environment': self.environment_type
        }
        
        self.config_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.config_file, 'w') as f:
            json.dump(config, f, indent=2)
    
    def activate_environment(self, env_type):
        """Activate the appropriate environment"""
        self.environment_type = env_type
        
        if env_type == 'local':
            # Look for local venv
            venv_paths = ['.venv', 'venv', '~/.venv']
            for venv in venv_paths:
                venv_path = Path(venv).expanduser()
                if venv_path.exists():
                    self.venv_path = venv_path
                    self.python_cmd = str(venv_path / 'bin' / 'python')
                    return True
        
        elif env_type == 'virtual':
            # Use system virtual environment
            if os.environ.get('VIRTUAL_ENV'):
                self.venv_path = Path(os.environ['VIRTUAL_ENV'])
                self.python_cmd = str(self.venv_path / 'bin' / 'python')
                return True
        
        elif env_type == 'docker':
            self.python_cmd = 'python3'
            return True
        
        return False
    
    def get_ip_addresses(self):
        """Get all available IP addresses"""
        ips = {
            'local': '127.0.0.1',
            'docker': None,
            'network': []
        }
        
        # Get local network IPs
        try:
            hostname = socket.gethostname()
            local_ip = socket.gethostbyname(hostname)
            ips['network'].append(local_ip)
            
            # Get all network interfaces
            for interface in socket.getaddrinfo(hostname, None):
                ip = interface[4][0]
                if ip not in ips['network'] and not ip.startswith('127.'):
                    ips['network'].append(ip)
        except:
            pass
        
        # Get Docker IP if in Docker
        if self.environment_type == 'docker':
            try:
                result = subprocess.run(['hostname', '-i'], capture_output=True, text=True)
                if result.returncode == 0:
                    ips['docker'] = result.stdout.strip()
            except:
                pass
        
        return ips

class DatabaseManager:
    """Manages database connections and operations"""
    
    def __init__(self, config):
        self.config = config
        self.connection = None
        
    def test_connection(self):
        """Test database connection"""
        if not DB_AVAILABLE:
            return False, "MySQL connector not installed"
        
        try:
            conn = mysql.connector.connect(
                host=self.config['host'],
                port=self.config['port'],
                user=self.config['user'],
                password=self.config['password'],
                database=self.config.get('database', 'race_management')
            )
            
            if conn.is_connected():
                conn.close()
                return True, "Connection successful"
            
        except Error as e:
            return False, str(e)
        
        return False, "Unknown error"
    
    def create_race_tables(self, race_info):
        """Create race-specific tables"""
        # Implementation for creating race tables
        pass

class TRMSLauncher(Adw.Application):
    """Main application class for TRMS Launcher"""
    
    def __init__(self):
        super().__init__(
            application_id='com.trms.comprehensive',
            flags=Gio.ApplicationFlags.DEFAULT_FLAGS
        )
        self.env_config = EnvironmentConfig()
        self.db_manager = DatabaseManager(self.env_config.db_config)
        self.window = None
        
    def do_activate(self):
        """Called when the application is activated"""
        if not self.window:
            self.window = TRMSMainWindow(self)
        self.window.present()

class TRMSMainWindow(Adw.ApplicationWindow):
    """Main window for TRMS Launcher"""
    
    def __init__(self, app):
        super().__init__(application=app)
        self.app = app
        
        # Window properties - original layout preference
        self.set_title("TRMS: The Race Management Solution")
        self.set_default_size(900, 700)
        
        # Apply custom CSS for better appearance
        self.apply_custom_css()
        
        # Build UI
        self.build_ui()
        
        # Start status monitoring
        GLib.timeout_add_seconds(5, self.update_status)
    
    def apply_custom_css(self):
        """Apply custom CSS styling"""
        css_provider = Gtk.CssProvider()
        css_provider.load_from_data(b"""
            .title-1 { 
                font-size: 24pt; 
                font-weight: bold;
                margin: 12px;
            }
            
            .app-card {
                padding: 20px;
                margin: 10px;
                border-radius: 12px;
                background: alpha(@accent_bg_color, 0.1);
            }
            
            .console-output {
                font-family: monospace;
                font-size: 10pt;
                padding: 8px;
                background: #1e1e1e;
                color: #ffffff;
                border-radius: 6px;
            }
            
            .status-good { color: @success_color; }
            .status-warning { color: @warning_color; }
            .status-error { color: @error_color; }
        """)
        
        Gtk.StyleContext.add_provider_for_display(
            self.get_display(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
    
    def build_ui(self):
        """Build the main UI"""
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_content(main_box)
        
        # Header bar
        header_bar = Adw.HeaderBar()
        
        # Menu button
        menu_button = Gtk.MenuButton()
        menu_button.set_icon_name("open-menu-symbolic")
        menu_button.set_menu_model(self.create_menu())
        header_bar.pack_end(menu_button)
        
        # Settings button
        settings_btn = Gtk.Button()
        settings_btn.set_icon_name("emblem-system-symbolic")
        settings_btn.set_tooltip_text("Settings")
        settings_btn.connect("clicked", self.open_settings)
        header_bar.pack_end(settings_btn)
        
        # Refresh button
        refresh_btn = Gtk.Button()
        refresh_btn.set_icon_name("view-refresh-symbolic")
        refresh_btn.set_tooltip_text("Refresh Status")
        refresh_btn.connect("clicked", self.on_refresh)
        header_bar.pack_end(refresh_btn)
        
        main_box.append(header_bar)
        
        # Scrolled window for content
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scrolled.set_vexpand(True)
        main_box.append(scrolled)
        
        # Content box
        content_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        content_box.set_margin_top(20)
        content_box.set_margin_bottom(20)
        content_box.set_margin_start(20)
        content_box.set_margin_end(20)
        scrolled.set_child(content_box)
        
        # Add sections
        self.add_title_section(content_box)
        self.add_environment_section(content_box)
        self.add_database_section(content_box)
        self.add_application_cards(content_box)
        self.add_web_management_card(content_box)
        self.add_mini_console(content_box)
    
    def add_title_section(self, parent):
        """Add title section"""
        title_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        title_box.set_halign(Gtk.Align.CENTER)
        parent.append(title_box)
        
        title = Gtk.Label()
        title.set_markup("<span size='x-large' weight='bold'>🏁 TRMS: The Race Management Solution</span>")
        title.add_css_class("title-1")
        title_box.append(title)
        
        subtitle = Gtk.Label()
        subtitle.set_text("Comprehensive Race Management System")
        subtitle.add_css_class("dim-label")
        title_box.append(subtitle)
    
    def add_environment_section(self, parent):
        """Add environment configuration section"""
        env_group = Adw.PreferencesGroup()
        env_group.set_title("Environment Configuration")
        env_group.set_description("Select and configure the runtime environment")
        parent.append(env_group)
        
        # Environment selector row
        env_row = Adw.ActionRow()
        env_row.set_title("Environment Type")
        
        self.env_dropdown = Gtk.DropDown()
        self.env_dropdown.set_model(Gtk.StringList.new(["Local", "Virtual", "Docker"]))
        
        # Set current environment
        env_map = {'local': 0, 'virtual': 1, 'docker': 2}
        self.env_dropdown.set_selected(env_map.get(self.app.env_config.environment_type, 0))
        self.env_dropdown.connect("notify::selected", self.on_environment_changed)
        
        env_row.add_suffix(self.env_dropdown)
        env_group.add(env_row)
        
        # Python path row
        python_row = Adw.ActionRow()
        python_row.set_title("Python Interpreter")
        python_row.set_subtitle(self.app.env_config.python_cmd or "Not configured")
        env_group.add(python_row)
        
        # Activate button
        activate_row = Adw.ActionRow()
        activate_row.set_title("Environment Status")
        
        activate_btn = Gtk.Button(label="Activate")
        activate_btn.connect("clicked", self.activate_environment)
        activate_row.add_suffix(activate_btn)
        env_group.add(activate_row)
    
    def add_database_section(self, parent):
        """Add database configuration section"""
        db_group = Adw.PreferencesGroup()
        db_group.set_title("Database Configuration")
        db_group.set_description("Configure and test database connection")
        parent.append(db_group)
        
        # Database type selector
        db_type_row = Adw.ActionRow()
        db_type_row.set_title("Database Location")
        
        self.db_dropdown = Gtk.DropDown()
        self.db_dropdown.set_model(Gtk.StringList.new(["Local", "Remote", "Docker"]))
        self.db_dropdown.connect("notify::selected", self.on_database_changed)
        
        db_type_row.add_suffix(self.db_dropdown)
        db_group.add(db_type_row)
        
        # Connection info
        host_row = Adw.EntryRow()
        host_row.set_title("Host")
        host_row.set_text(self.app.env_config.db_config.get('host', 'localhost'))
        self.db_host_entry = host_row
        db_group.add(host_row)
        
        port_row = Adw.EntryRow()
        port_row.set_title("Port")
        port_row.set_text(str(self.app.env_config.db_config.get('port', 3306)))
        self.db_port_entry = port_row
        db_group.add(port_row)
        
        # Test connection button
        test_row = Adw.ActionRow()
        test_row.set_title("Connection Status")
        
        test_btn = Gtk.Button(label="Test Connection")
        test_btn.connect("clicked", self.test_database_connection)
        test_row.add_suffix(test_btn)
        
        self.db_status_label = Gtk.Label(label="Not tested")
        test_row.add_suffix(self.db_status_label)
        
        db_group.add(test_row)
    
    def add_application_cards(self, parent):
        """Add application launcher cards"""
        apps_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        parent.append(apps_box)
        
        # TRRS Card with race management features
        self.add_trrs_card(apps_box)
        
        # TRTS Card
        self.add_trts_card(apps_box)
    
    def add_trrs_card(self, parent):
        """Add TRRS card with race management features"""
        trrs_card = self.create_app_card(
            "🏁 TRRS: The Race Registration Solution",
            "Complete race registration and management system",
            "#4a9eff"
        )
        
        # Launch buttons row
        launch_row = Adw.ActionRow()
        launch_row.set_title("Launch Applications")
        
        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        
        console_btn = Gtk.Button(label="Console")
        console_btn.connect("clicked", self.launch_trrs_console)
        button_box.append(console_btn)
        
        gui_btn = Gtk.Button(label="GUI")
        gui_btn.connect("clicked", self.launch_trrs_gui)
        button_box.append(gui_btn)
        
        launch_row.add_suffix(button_box)
        trrs_card.add(launch_row)
        
        # Race management row
        race_mgmt_row = Adw.ActionRow()
        race_mgmt_row.set_title("Race Management")
        
        race_buttons = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        
        new_race_btn = Gtk.Button(label="New Race")
        new_race_btn.connect("clicked", self.new_race)
        race_buttons.append(new_race_btn)
        
        modify_race_btn = Gtk.Button(label="Modify")
        modify_race_btn.connect("clicked", self.modify_race)
        race_buttons.append(modify_race_btn)
        
        view_race_btn = Gtk.Button(label="View")
        view_race_btn.connect("clicked", self.view_race)
        race_buttons.append(view_race_btn)
        
        stats_btn = Gtk.Button(label="Statistics")
        stats_btn.connect("clicked", self.race_statistics)
        race_buttons.append(stats_btn)
        
        export_btn = Gtk.Button(label="Export")
        export_btn.connect("clicked", self.export_race)
        race_buttons.append(export_btn)
        
        race_mgmt_row.add_suffix(race_buttons)
        trrs_card.add(race_mgmt_row)
        
        parent.append(trrs_card)
    
    def add_trts_card(self, parent):
        """Add TRTS card"""
        trts_card = self.create_app_card(
            "⏱️ TRTS: The Race Timing Solution",
            "Professional race timing and results management",
            "#00c853"
        )
        
        # Launch buttons row
        launch_row = Adw.ActionRow()
        launch_row.set_title("Launch Applications")
        
        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        
        console_btn = Gtk.Button(label="Console")
        console_btn.connect("clicked", self.launch_trts_console)
        button_box.append(console_btn)
        
        gui_btn = Gtk.Button(label="GUI")
        gui_btn.connect("clicked", self.launch_trts_gui)
        button_box.append(gui_btn)
        
        launch_row.add_suffix(button_box)
        trts_card.add(launch_row)
        
        parent.append(trts_card)
    
    def add_web_management_card(self, parent):
        """Add web server management card"""
        web_card = self.create_app_card(
            "🌐 TRWS: The Race Web Solution",
            "Unified web interface for registration and results",
            "#ff6b6b"
        )
        
        # Web server control
        server_row = Adw.ActionRow()
        server_row.set_title("Web Server")
        
        server_buttons = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        
        start_btn = Gtk.Button(label="Start")
        start_btn.connect("clicked", self.start_web_server)
        server_buttons.append(start_btn)
        
        stop_btn = Gtk.Button(label="Stop")
        stop_btn.connect("clicked", self.stop_web_server)
        server_buttons.append(stop_btn)
        
        config_btn = Gtk.Button(label="Configure")
        config_btn.connect("clicked", self.configure_web_server)
        server_buttons.append(config_btn)
        
        server_row.add_suffix(server_buttons)
        web_card.add(server_row)
        
        # IP addresses row
        ip_row = Adw.ActionRow()
        ip_row.set_title("Access URLs")
        
        ips = self.app.env_config.get_ip_addresses()
        ip_text = f"Local: http://127.0.0.1:5000"
        if ips['network']:
            ip_text += f"\nNetwork: http://{ips['network'][0]}:5000"
        
        ip_label = Gtk.Label(label=ip_text)
        ip_label.set_selectable(True)
        ip_row.add_suffix(ip_label)
        web_card.add(ip_row)
        
        parent.append(web_card)
    
    def add_mini_console(self, parent):
        """Add mini console for output"""
        console_group = Adw.PreferencesGroup()
        console_group.set_title("Console Output")
        parent.append(console_group)
        
        # Console text view
        console_frame = Gtk.Frame()
        console_frame.set_margin_top(6)
        
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_min_content_height(100)
        scrolled.set_max_content_height(200)
        
        self.console_view = Gtk.TextView()
        self.console_view.set_editable(False)
        self.console_view.set_monospace(True)
        self.console_view.set_wrap_mode(Gtk.WrapMode.WORD)
        self.console_view.add_css_class("console-output")
        
        self.console_buffer = self.console_view.get_buffer()
        self.append_console("TRMS Launcher ready.\n")
        
        scrolled.set_child(self.console_view)
        console_frame.set_child(scrolled)
        
        console_row = Adw.ActionRow()
        console_row.set_child(console_frame)
        console_group.add(console_row)
    
    def create_app_card(self, title, description, color):
        """Create an application card"""
        card = Adw.PreferencesGroup()
        card.add_css_class("app-card")
        card.set_title(title)
        card.set_description(description)
        return card
    
    def create_menu(self):
        """Create application menu"""
        menu = Gio.Menu()
        
        file_section = Gio.Menu()
        file_section.append("Settings", "app.settings")
        file_section.append("Refresh", "app.refresh")
        menu.append_section("File", file_section)
        
        help_section = Gio.Menu()
        help_section.append("Documentation", "app.docs")
        help_section.append("About", "app.about")
        menu.append_section("Help", help_section)
        
        menu.append("Quit", "app.quit")
        
        # Create actions
        self.create_actions()
        
        return menu
    
    def create_actions(self):
        """Create application actions"""
        actions = [
            ("settings", self.open_settings),
            ("refresh", lambda *args: self.on_refresh(None)),
            ("docs", self.open_documentation),
            ("about", self.show_about),
            ("quit", lambda *args: self.app.quit())
        ]
        
        for name, callback in actions:
            action = Gio.SimpleAction.new(name, None)
            action.connect("activate", callback)
            self.app.add_action(action)
    
    # Launch methods
    def launch_trrs_console(self, button):
        """Launch TRRS console in new VTE window"""
        self.launch_console_app("TRRS", "run_trrs_console.sh")
    
    def launch_trrs_gui(self, button):
        """Launch TRRS GUI"""
        self.launch_gui_app("TRRS", "run_trrs_gui.sh")
    
    def launch_trts_console(self, button):
        """Launch TRTS console in new VTE window"""
        self.launch_console_app("TRTS", "run_trts_console.sh")
    
    def launch_trts_gui(self, button):
        """Launch TRTS GUI"""
        self.launch_gui_app("TRTS", "run_trts_gui.sh")
    
    def launch_console_app(self, name, script):
        """Launch console app in new VTE terminal window"""
        window = ConsoleWindow(self, name, script)
        window.present()
    
    def launch_gui_app(self, name, script):
        """Launch GUI application"""
        self.append_console(f"Launching {name} GUI...\n")
        
        env = os.environ.copy()
        if self.app.env_config.venv_path:
            env['VIRTUAL_ENV'] = str(self.app.env_config.venv_path)
        
        try:
            subprocess.Popen([script], env=env, cwd=str(self.app.env_config.trms_base))
            self.append_console(f"{name} GUI started.\n")
        except Exception as e:
            self.append_console(f"Error: {e}\n")
    
    # Environment methods
    def on_environment_changed(self, dropdown, param):
        """Handle environment change"""
        env_types = ['local', 'virtual', 'docker']
        selected = env_types[dropdown.get_selected()]
        self.append_console(f"Environment changed to: {selected}\n")
    
    def activate_environment(self, button):
        """Activate selected environment"""
        env_types = ['local', 'virtual', 'docker']
        selected = env_types[self.env_dropdown.get_selected()]
        
        if self.app.env_config.activate_environment(selected):
            self.append_console(f"✓ {selected} environment activated\n")
            button.set_label("Activated")
        else:
            self.append_console(f"✗ Failed to activate {selected} environment\n")
    
    # Database methods
    def on_database_changed(self, dropdown, param):
        """Handle database location change"""
        db_types = ['local', 'remote', 'docker']
        selected = db_types[dropdown.get_selected()]
        
        if selected == 'local':
            self.db_host_entry.set_text('localhost')
        elif selected == 'docker':
            self.db_host_entry.set_text('trms-db')
    
    def test_database_connection(self, button):
        """Test database connection"""
        # Update config from UI
        self.app.env_config.db_config['host'] = self.db_host_entry.get_text()
        self.app.env_config.db_config['port'] = int(self.db_port_entry.get_text())
        
        success, message = self.app.db_manager.test_connection()
        
        if success:
            self.db_status_label.set_markup("<span color='green'>✓ Connected</span>")
            self.append_console(f"✓ Database connected: {message}\n")
        else:
            self.db_status_label.set_markup("<span color='red'>✗ Failed</span>")
            self.append_console(f"✗ Database error: {message}\n")
    
    # Race management methods
    def new_race(self, button):
        """Open new race dialog"""
        dialog = RaceDialog(self, None)
        dialog.present()
    
    def modify_race(self, button):
        """Open modify race dialog"""
        dialog = RaceSelectionDialog(self, "modify")
        dialog.present()
    
    def view_race(self, button):
        """Open view race dialog"""
        dialog = RaceSelectionDialog(self, "view")
        dialog.present()
    
    def race_statistics(self, button):
        """Open race statistics dialog"""
        dialog = RaceSelectionDialog(self, "statistics")
        dialog.present()
    
    def export_race(self, button):
        """Open export race dialog"""
        dialog = RaceSelectionDialog(self, "export")
        dialog.present()
    
    # Web server methods
    def start_web_server(self, button):
        """Start web server"""
        self.append_console("Starting web server...\n")
        # Implementation for starting Flask server
    
    def stop_web_server(self, button):
        """Stop web server"""
        self.append_console("Stopping web server...\n")
        # Implementation for stopping Flask server
    
    def configure_web_server(self, button):
        """Open web server configuration"""
        dialog = WebServerDialog(self)
        dialog.present()
    
    # Utility methods
    def append_console(self, text):
        """Append text to console"""
        end_iter = self.console_buffer.get_end_iter()
        self.console_buffer.insert(end_iter, text)
        
        # Auto-scroll to bottom
        mark = self.console_buffer.get_insert()
        self.console_view.scroll_mark_onscreen(mark)
    
    def on_refresh(self, button):
        """Refresh status"""
        self.append_console("Refreshing status...\n")
        # Update all status displays
    
    def update_status(self):
        """Periodic status update"""
        # Update status displays
        return True  # Continue updates
    
    def open_settings(self, button=None):
        """Open settings dialog"""
        dialog = SettingsDialog(self)
        dialog.present()
    
    def open_documentation(self, *args):
        """Open documentation"""
        import webbrowser
        webbrowser.open("https://github.com/tjtryon/TRMS")
    
    def show_about(self, *args):
        """Show about dialog"""
        about = Adw.AboutWindow()
        about.set_transient_for(self)
        about.set_application_name("TRMS Launcher")
        about.set_version("2.0.0")
        about.set_developer_name("TRMS Development Team")
        about.set_comments("Comprehensive Race Management Solution")
        about.present()

class ConsoleWindow(Adw.Window):
    """VTE terminal window for running console applications"""
    
    def __init__(self, parent, app_name, script):
        super().__init__()
        self.set_transient_for(parent)
        self.set_title(f"{app_name} Console")
        self.set_default_size(800, 600)
        
        self.parent_window = parent
        self.app_name = app_name
        self.script = script
        
        # Main container
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_content(box)
        
        # Header bar
        header = Adw.HeaderBar()
        box.append(header)
        
        # Create VTE terminal
        self.terminal = Vte.Terminal()
        self.terminal.set_size(80, 24)
        self.terminal.set_font(Pango.FontDescription("monospace 11"))
        self.terminal.set_scroll_on_output(True)
        self.terminal.set_scroll_on_keystroke(True)
        self.terminal.set_scrollback_lines(10000)
        
        # Set colors
        self.terminal.set_color_background(Gdk.RGBA(red=0.12, green=0.12, blue=0.12, alpha=1.0))
        self.terminal.set_color_foreground(Gdk.RGBA(red=1.0, green=1.0, blue=1.0, alpha=1.0))
        
        # Create scrolled window
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        scrolled.set_child(self.terminal)
        box.append(scrolled)
        
        # Start the application
        self.launch_application()
    
    def launch_application(self):
        """Launch the console application in terminal"""
        env = os.environ.copy()
        
        # Set up environment based on configuration
        if self.parent_window.app.env_config.venv_path:
            activate_script = self.parent_window.app.env_config.venv_path / 'bin' / 'activate'
            
            # Create a wrapper script that sources venv and runs the app
            wrapper_script = f"""#!/bin/bash
cd {self.parent_window.app.env_config.trms_base}
source {activate_script}
./{self.script}
echo ""
echo "Press any key to close..."
read -n 1
"""
            
            # Write wrapper script
            wrapper_path = Path("/tmp") / f"trms_{self.app_name.lower()}_wrapper.sh"
            wrapper_path.write_text(wrapper_script)
            wrapper_path.chmod(0o755)
            
            # Spawn the wrapper script
            self.terminal.spawn_async(
                Vte.PtyFlags.DEFAULT,
                str(self.parent_window.app.env_config.trms_base),
                ["/bin/bash", str(wrapper_path)],
                [],
                GLib.SpawnFlags.DEFAULT,
                None, None,
                -1,
                None,
                None,
                None
            )
        else:
            # Direct spawn without venv
            self.terminal.spawn_async(
                Vte.PtyFlags.DEFAULT,
                str(self.parent_window.app.env_config.trms_base),
                ["/bin/bash", "-c", f"./{self.script}"],
                [],
                GLib.SpawnFlags.DEFAULT,
                None, None,
                -1,
                None,
                None,
                None
            )

class RaceDialog(Adw.Window):
    """Dialog for creating/editing races"""
    
    def __init__(self, parent, race_data=None):
        super().__init__()
        self.set_transient_for(parent)
        self.set_modal(True)
        self.set_title("New Race" if race_data is None else "Edit Race")
        self.set_default_size(700, 800)
        
        self.parent_window = parent
        self.race_data = race_data or {}
        
        # Main container
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_content(box)
        
        # Header bar
        header = Adw.HeaderBar()
        
        cancel_btn = Gtk.Button(label="Cancel")
        cancel_btn.connect("clicked", lambda x: self.close())
        header.pack_start(cancel_btn)
        
        save_btn = Gtk.Button(label="Save")
        save_btn.add_css_class("suggested-action")
        save_btn.connect("clicked", self.save_race)
        header.pack_end(save_btn)
        
        box.append(header)
        
        # Scrolled content
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        box.append(scrolled)
        
        content = Adw.PreferencesPage()
        scrolled.set_child(content)
        
        # Basic Information
        basic_group = Adw.PreferencesGroup()
        basic_group.set_title("Basic Information")
        content.add(basic_group)
        
        self.name_entry = Adw.EntryRow()
        self.name_entry.set_title("Race Name")
        basic_group.add(self.name_entry)
        
        self.date_entry = Adw.EntryRow()
        self.date_entry.set_title("Date (YYYY-MM-DD)")
        basic_group.add(self.date_entry)
        
        self.time_entry = Adw.EntryRow()
        self.time_entry.set_title("Start Time (HH:MM)")
        basic_group.add(self.time_entry)
        
        # Race type selector
        self.type_row = Adw.ComboRow()
        self.type_row.set_title("Race Type")
        type_model = Gtk.StringList()
        type_model.append("Road Race")
        type_model.append("Cross Country")
        self.type_row.set_model(type_model)
        basic_group.add(self.type_row)
        
        # Distance selector
        self.distance_row = Adw.ComboRow()
        self.distance_row.set_title("Distance")
        self.update_distance_options(0)  # Default to road race
        self.type_row.connect("notify::selected", self.on_type_changed)
        basic_group.add(self.distance_row)
        
        # Venue Information
        venue_group = Adw.PreferencesGroup()
        venue_group.set_title("Venue Information")
        content.add(venue_group)
        
        self.venue_entry = Adw.EntryRow()
        self.venue_entry.set_title("Venue Name")
        venue_group.add(self.venue_entry)
        
        self.description_entry = Adw.EntryRow()
        self.description_entry.set_title("Description")
        venue_group.add(self.description_entry)
        
        # URLs
        url_group = Adw.PreferencesGroup()
        url_group.set_title("Links and Resources")
        content.add(url_group)
        
        self.map_url_entry = Adw.EntryRow()
        self.map_url_entry.set_title("Race Map URL")
        url_group.add(self.map_url_entry)
        
        self.logo_url_entry = Adw.EntryRow()
        self.logo_url_entry.set_title("Race Logo URL")
        url_group.add(self.logo_url_entry)
        
        self.shirt_url_entry = Adw.EntryRow()
        self.shirt_url_entry.set_title("Shirt Design URL")
        url_group.add(self.shirt_url_entry)
        
        self.website_url_entry = Adw.EntryRow()
        self.website_url_entry.set_title("Race Website URL")
        url_group.add(self.website_url_entry)
        
        self.registration_url_entry = Adw.EntryRow()
        self.registration_url_entry.set_title("Registration URL")
        url_group.add(self.registration_url_entry)
        
        self.video_url_entry = Adw.EntryRow()
        self.video_url_entry.set_title("Finish Video URL")
        url_group.add(self.video_url_entry)
        
        # Registration Details
        reg_group = Adw.PreferencesGroup()
        reg_group.set_title("Registration Details")
        content.add(reg_group)
        
        self.deadline_entry = Adw.EntryRow()
        self.deadline_entry.set_title("Registration Deadline (YYYY-MM-DD)")
        reg_group.add(self.deadline_entry)
        
        self.cost_entry = Adw.EntryRow()
        self.cost_entry.set_title("Entry Fee")
        reg_group.add(self.cost_entry)
        
        self.race_number_entry = Adw.EntryRow()
        self.race_number_entry.set_title("Race Number (for the day)")
        reg_group.add(self.race_number_entry)
        
        # Populate if editing
        if self.race_data:
            self.populate_fields()
    
    def update_distance_options(self, race_type):
        """Update distance options based on race type"""
        distance_model = Gtk.StringList()
        
        if race_type == 1:  # Cross Country
            distances = ["3K", "4K", "5K", "10K"]
        else:  # Road Race
            distances = ["3K", "4K", "5K", "10K", "5M", "10M", "13.1M", "26.2M", "Other"]
        
        for distance in distances:
            distance_model.append(distance)
        
        self.distance_row.set_model(distance_model)
    
    def on_type_changed(self, row, param):
        """Handle race type change"""
        self.update_distance_options(row.get_selected())
    
    def populate_fields(self):
        """Populate fields with existing race data"""
        # Implementation to populate fields
        pass
    
    def save_race(self, button):
        """Save race data"""
        race_info = {
            'name': self.name_entry.get_text(),
            'date': self.date_entry.get_text(),
            'time': self.time_entry.get_text(),
            'type': 'cross_country' if self.type_row.get_selected() == 1 else 'road_race',
            'venue': self.venue_entry.get_text(),
            'description': self.description_entry.get_text(),
            # ... collect all other fields
        }
        
        # Create race tables based on type
        table_name = f"{race_info['date'].replace('-', '')}_reg_{race_info['type']}_{race_info['name'].replace(' ', '_').lower()}_info"
        
        self.parent_window.append_console(f"Creating race: {race_info['name']}\n")
        self.parent_window.append_console(f"Table: {table_name}\n")
        
        # Here you would actually create the database tables
        # self.parent_window.app.db_manager.create_race_tables(race_info)
        
        self.close()

class RaceSelectionDialog(Adw.Window):
    """Dialog for selecting a race for various operations"""
    
    def __init__(self, parent, operation):
        super().__init__()
        self.set_transient_for(parent)
        self.set_modal(True)
        self.set_title(f"Select Race - {operation.title()}")
        self.set_default_size(600, 400)
        
        self.parent_window = parent
        self.operation = operation
        
        # Main container
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_content(box)
        
        # Header bar
        header = Adw.HeaderBar()
        box.append(header)
        
        # Content
        content = Adw.PreferencesPage()
        box.append(content)
        
        # Race selection group
        selection_group = Adw.PreferencesGroup()
        selection_group.set_title("Select Race")
        selection_group.set_description("Races from past month and future")
        content.add(selection_group)
        
        # Get races from database (mock data for now)
        races = self.get_races()
        
        for race in races:
            race_row = Adw.ActionRow()
            race_row.set_title(race['name'])
            race_row.set_subtitle(f"{race['date']} - {race['venue']}")
            
            select_btn = Gtk.Button(label="Select")
            select_btn.connect("clicked", self.on_race_selected, race)
            race_row.add_suffix(select_btn)
            
            selection_group.add(race_row)
    
    def get_races(self):
        """Get races from past month and future"""
        # Mock data - would query database
        today = date.today()
        past_month = today - timedelta(days=30)
        
        return [
            {'id': 1, 'name': 'Spring 5K', 'date': '2024-03-15', 'venue': 'City Park'},
            {'id': 2, 'name': 'Marathon 2024', 'date': '2024-04-01', 'venue': 'Downtown'},
            {'id': 3, 'name': 'Trail Run', 'date': '2024-04-15', 'venue': 'Mountain Trail'},
        ]
    
    def on_race_selected(self, button, race):
        """Handle race selection"""
        if self.operation == 'modify':
            dialog = RaceDialog(self.parent_window, race)
            dialog.present()
        elif self.operation == 'view':
            self.show_race_details(race)
        elif self.operation == 'statistics':
            self.show_race_statistics(race)
        elif self.operation == 'export':
            self.export_race_data(race)
        
        self.close()
    
    def show_race_details(self, race):
        """Show race details"""
        self.parent_window.append_console(f"Viewing race: {race['name']}\n")
    
    def show_race_statistics(self, race):
        """Show race statistics"""
        self.parent_window.append_console(f"Statistics for: {race['name']}\n")
    
    def export_race_data(self, race):
        """Export race data"""
        self.parent_window.append_console(f"Exporting: {race['name']}\n")

class WebServerDialog(Adw.Window):
    """Web server configuration dialog"""
    
    def __init__(self, parent):
        super().__init__()
        self.set_transient_for(parent)
        self.set_modal(True)
        self.set_title("Web Server Configuration")
        self.set_default_size(700, 500)
        
        self.parent_window = parent
        
        # Main container
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.set_content(box)
        
        # Header bar
        header = Adw.HeaderBar()
        box.append(header)
        
        # Content
        content = Adw.PreferencesPage()
        box.append(content)
        
        # Server Configuration
        server_group = Adw.PreferencesGroup()
        server_group.set_title("Server Configuration")
        content.add(server_group)
        
        host_row = Adw.EntryRow()
        host_row.set_title("Host")
        host_row.set_text("0.0.0.0")
        server_group.add(host_row)
        
        port_row = Adw.EntryRow()
        port_row.set_title("Port")
        port_row.set_text("5000")
        server_group.add(port_row)
        
        ssl_row = Adw.ActionRow()
        ssl_row.set_title("SSL/HTTPS")
        ssl_switch = Gtk.Switch()
        ssl_row.add_suffix(ssl_switch)
        server_group.add(ssl_row)
        
        ssl_port_row = Adw.EntryRow()
        ssl_port_row.set_title("SSL Port")
        ssl_port_row.set_text("443")
        server_group.add(ssl_port_row)
        
        # IP Addresses
        ip_group = Adw.PreferencesGroup()
        ip_group.set_title("Access Points")
        content.add(ip_group)
        
        ips = self.parent_window.app.env_config.get_ip_addresses()
        
        local_row = Adw.ActionRow()
        local_row.set_title("Local Access")
        local_row.set_subtitle(f"http://127.0.0.1:5000")
        ip_group.add(local_row)
        
        if ips['network']:
            for ip in ips['network']:
                network_row = Adw.ActionRow()
                network_row.set_title("Network Access")
                network_row.set_subtitle(f"http://{ip}:5000")
                ip_group.add(network_row)
        
        if ips['docker']:
            docker_row = Adw.ActionRow()
            docker_row.set_title("Docker Access")
            docker_row.set_subtitle(f"http://{ips['docker']}:5000")
            ip_group.add(docker_row)
        
        # Flask Routes
        routes_group = Adw.PreferencesGroup()
        routes_group.set_title("Application Routes")
        content.add(routes_group)
        
        trrs_row = Adw.ActionRow()
        trrs_row.set_title("TRRS Registration")
        trrs_row.set_subtitle("/registration")
        routes_group.add(trrs_row)
        
        trts_row = Adw.ActionRow()
        trts_row.set_title("TRTS Results")
        trts_row.set_subtitle("/results")
        routes_group.add(trts_row)
        
        admin_row = Adw.ActionRow()
        admin_row.set_title("Admin Panel")
        admin_row.set_subtitle("/admin")
        routes_group.add(admin_row)

class SettingsDialog(Adw.PreferencesWindow):
    """Application settings dialog"""
    
    def __init__(self, parent):
        super().__init__()
        self.set_transient_for(parent)
        self.set_modal(True)
        self.set_title("Settings")
        self.set_default_size(700, 500)
        
        # General page
        general_page = Adw.PreferencesPage()
        general_page.set_title("General")
        general_page.set_icon_name("preferences-system-symbolic")
        self.add(general_page)
        
        # Database page
        db_page = Adw.PreferencesPage()
        db_page.set_title("Database")
        db_page.set_icon_name("network-server-symbolic")
        self.add(db_page)
        
        # Web page
        web_page = Adw.PreferencesPage()
        web_page.set_title("Web Server")
        web_page.set_icon_name("network-workgroup-symbolic")
        self.add(web_page)

def main():
    """Main entry point"""
    app = TRMSLauncher()
    return app.run(sys.argv)

if __name__ == "__main__":
    sys.exit(main())