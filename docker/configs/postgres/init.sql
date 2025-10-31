-- PostgreSQL initialization script for production

-- Create extensions if they don't exist
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create database schema for astrology API
-- This would typically be handled by an ORM like SQLAlchemy in the application

-- Create indexes for frequently queried fields
-- CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
-- CREATE INDEX IF NOT EXISTS idx_charts_user_id ON charts(user_id);

-- Any other initialization logic for the production database