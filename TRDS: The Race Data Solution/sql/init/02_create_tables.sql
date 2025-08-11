-- ═══════════════════════════════════════════════════════════════════════════════
-- 📊 TRMS Tables Schema
-- ═══════════════════════════════════════════════════════════════════════════════

USE trms_db;

-- =============================================
-- RACES TABLE (Shared by TRRS and TRTS)
-- =============================================
CREATE TABLE IF NOT EXISTS races (
    race_id INT AUTO_INCREMENT PRIMARY KEY,
    race_name VARCHAR(255) NOT NULL,
    race_description TEXT,
    race_date DATE NOT NULL,
    race_time TIME,
    race_venue VARCHAR(255),
    race_type ENUM('road_race', 'cross_country', 'track', 'trail', 'virtual', 'triathlon') DEFAULT 'road_race',
    race_distances VARCHAR(500),
    course_link VARCHAR(500),
    registration_link VARCHAR(500),
    
    -- TRRS specific fields
    registration_open BOOLEAN DEFAULT TRUE,
    registration_limit INT,
    entry_fee DECIMAL(10,2),
    
    -- TRTS specific fields
    timing_method VARCHAR(50),
    chip_timing BOOLEAN DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_race_date (race_date),
    INDEX idx_race_type (race_type),
    INDEX idx_race_name (race_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- PARTICIPANTS TABLE (TRRS)
-- =============================================
CREATE TABLE IF NOT EXISTS participants (
    participant_id INT AUTO_INCREMENT PRIMARY KEY,
    race_id INT NOT NULL,
    
    -- Personal information
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    
    -- Address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Race specific
    distance VARCHAR(50),
    bib_number VARCHAR(20),
    t_shirt_size ENUM('XS', 'S', 'M', 'L', 'XL', 'XXL'),
    
    -- Emergency contact
    emergency_contact_name VARCHAR(255),
    emergency_contact_phone VARCHAR(20),
    
    -- Registration
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    registration_status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending',
    payment_status ENUM('pending', 'paid', 'refunded') DEFAULT 'pending',
    amount_paid DECIMAL(10,2),
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (race_id) REFERENCES races(race_id) ON DELETE CASCADE,
    INDEX idx_race_participant (race_id, last_name, first_name),
    INDEX idx_email (email),
    INDEX idx_bib_number (bib_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- RACE_TIMES TABLE (TRTS)
-- =============================================
CREATE TABLE IF NOT EXISTS race_times (
    time_id INT AUTO_INCREMENT PRIMARY KEY,
    race_id INT NOT NULL,
    participant_id INT,
    bib_number VARCHAR(20),
    
    -- Timing data
    start_time TIMESTAMP,
    finish_time TIMESTAMP,
    net_time TIME GENERATED ALWAYS AS (
        CASE 
            WHEN finish_time IS NOT NULL AND start_time IS NOT NULL 
            THEN TIMEDIFF(finish_time, start_time)
            ELSE NULL 
        END
    ) STORED,
    
    -- Split times (JSON format for flexibility)
    split_times JSON,
    
    -- Placement
    overall_place INT,
    gender_place INT,
    age_group_place INT,
    
    -- Status
    timing_status ENUM('started', 'finished', 'dnf', 'dsq') DEFAULT 'started',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (race_id) REFERENCES races(race_id) ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES participants(participant_id) ON DELETE SET NULL,
    INDEX idx_race_times (race_id, finish_time),
    INDEX idx_bib_number (bib_number),
    INDEX idx_participant (participant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- SYSTEM_SETTINGS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,
    component ENUM('TRMS', 'TRRS', 'TRTS', 'TRWS', 'TRDS') DEFAULT 'TRMS',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default settings
INSERT IGNORE INTO system_settings (setting_key, setting_value, description, component) VALUES
('trms_version', '1.0.0', 'TRMS version', 'TRMS'),
('default_race_type', 'road_race', 'Default race type for new races', 'TRRS'),
('enable_chip_timing', 'false', 'Enable chip timing by default', 'TRTS'),
('registration_email_enabled', 'true', 'Send confirmation emails', 'TRRS');
