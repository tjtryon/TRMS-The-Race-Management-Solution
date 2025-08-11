-- ═══════════════════════════════════════════════════════════════════════════════
-- 🗄️ TRMS Database Schema
-- ═══════════════════════════════════════════════════════════════════════════════

-- Create database
CREATE DATABASE IF NOT EXISTS trms_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user
CREATE USER IF NOT EXISTS 'trms'@'%' IDENTIFIED BY 'trms_password_2024';
GRANT ALL PRIVILEGES ON trms_db.* TO 'trms'@'%';
FLUSH PRIVILEGES;

USE trms_db;
