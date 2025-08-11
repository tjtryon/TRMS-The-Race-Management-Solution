#!/usr/bin/env python3

"""
═══════════════════════════════════════════════════════════════════════════════
🏁 Race Models for TRMS
═══════════════════════════════════════════════════════════════════════════════

📝 DESCRIPTION:
    Shared race models used by both TRRS and TRTS.

👤 AUTHOR: TRMS Development Team
📅 CREATED: 2024
🏷️ VERSION: 1.0.0

═══════════════════════════════════════════════════════════════════════════════
"""

from typing import Optional, List
from datetime import datetime, date, time
from pydantic import BaseModel, Field, validator
from ..database.connection import db_manager

class Race(BaseModel):
    """Race model for TRMS ecosystem."""
    race_id: Optional[int] = Field(None, description="Race ID")
    race_name: str = Field(..., description="Race name")
    race_description: Optional[str] = Field(None, description="Description")
    race_date: date = Field(..., description="Race date")
    race_time: Optional[time] = Field(None, description="Start time")
    race_venue: Optional[str] = Field(None, description="Venue")
    race_type: str = Field(default="road_race", description="Race type")
    race_distances: Optional[str] = Field(None, description="Distances")
    course_link: Optional[str] = Field(None, description="Course link")
    registration_link: Optional[str] = Field(None, description="Registration link")
    created_at: Optional[datetime] = Field(None, description="Created timestamp")
    updated_at: Optional[datetime] = Field(None, description="Updated timestamp")
    
    # TRRS specific fields
    registration_open: bool = Field(default=True, description="Registration open")
    registration_limit: Optional[int] = Field(None, description="Max participants")
    entry_fee: Optional[float] = Field(None, description="Entry fee")
    
    # TRTS specific fields
    timing_method: Optional[str] = Field(None, description="Timing method")
    chip_timing: bool = Field(default=False, description="Use chip timing")
    
    @validator('race_type')
    def validate_race_type(cls, v):
        """Validate race type."""
        valid_types = ['road_race', 'cross_country', 'track', 'trail', 'virtual', 'triathlon']
        if v not in valid_types:
            raise ValueError(f"Race type must be one of {valid_types}")
        return v

class RaceManager:
    """Manager for race database operations."""
    
    def __init__(self):
        """Initialize race manager."""
        self.table_name = "races"
    
    def create_race(self, race: Race) -> Optional[int]:
        """Create new race."""
        query = f"""
            INSERT INTO {self.table_name} 
            (race_name, race_description, race_date, race_time, race_venue,
             race_type, race_distances, course_link, registration_link,
             registration_open, registration_limit, entry_fee,
             timing_method, chip_timing)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        
        params = (
            race.race_name, race.race_description, race.race_date, race.race_time,
            race.race_venue, race.race_type, race.race_distances,
            race.course_link, race.registration_link,
            race.registration_open, race.registration_limit, race.entry_fee,
            race.timing_method, race.chip_timing
        )
        
        try:
            result = db_manager.execute_update(query, params)
            return result
        except Exception as e:
            print(f"Error creating race: {e}")
            return None
    
    def get_all_races(self) -> List[Race]:
        """Get all races."""
        query = f"SELECT * FROM {self.table_name} ORDER BY race_date DESC"
        
        try:
            results = db_manager.execute_query(query)
            return [Race(**row) for row in results]
        except Exception as e:
            print(f"Error fetching races: {e}")
            return []
    
    def get_race_by_id(self, race_id: int) -> Optional[Race]:
        """Get race by ID."""
        query = f"SELECT * FROM {self.table_name} WHERE race_id = %s"
        
        try:
            results = db_manager.execute_query(query, (race_id,))
            if results:
                return Race(**results[0])
            return None
        except Exception as e:
            print(f"Error fetching race: {e}")
            return None
    
    def update_race(self, race_id: int, race: Race) -> bool:
        """Update existing race."""
        query = f"""
            UPDATE {self.table_name}
            SET race_name = %s, race_description = %s, race_date = %s,
                race_time = %s, race_venue = %s, race_type = %s,
                race_distances = %s, course_link = %s, registration_link = %s,
                registration_open = %s, registration_limit = %s, entry_fee = %s,
                timing_method = %s, chip_timing = %s,
                updated_at = CURRENT_TIMESTAMP
            WHERE race_id = %s
        """
        
        params = (
            race.race_name, race.race_description, race.race_date, race.race_time,
            race.race_venue, race.race_type, race.race_distances,
            race.course_link, race.registration_link,
            race.registration_open, race.registration_limit, race.entry_fee,
            race.timing_method, race.chip_timing,
            race_id
        )
        
        try:
            result = db_manager.execute_update(query, params)
            return result > 0
        except Exception as e:
            print(f"Error updating race: {e}")
            return False
    
    def delete_race(self, race_id: int) -> bool:
        """Delete race."""
        query = f"DELETE FROM {self.table_name} WHERE race_id = %s"
        
        try:
            result = db_manager.execute_update(query, (race_id,))
            return result > 0
        except Exception as e:
            print(f"Error deleting race: {e}")
            return False
    
    def get_upcoming_races(self) -> List[Race]:
        """Get upcoming races."""
        query = f"""
            SELECT * FROM {self.table_name} 
            WHERE race_date >= CURDATE() 
            ORDER BY race_date ASC
        """
        
        try:
            results = db_manager.execute_query(query)
            return [Race(**row) for row in results]
        except Exception as e:
            print(f"Error fetching upcoming races: {e}")
            return []

# Global race manager
race_manager = RaceManager()
