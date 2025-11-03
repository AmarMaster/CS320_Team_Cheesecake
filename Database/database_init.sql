-- This file contains SQL commands to create the tables for the eventtracker-db
-- You should run these commands using the psql command-line tool from the database directory
-- Example: psql -U your_username -d eventtracker-db -f create_tables.sql

-- If not already connected to 'eventtracker-db', connect to it first
-- If eventtracker-db does not exist download postgresql and log into psql and run:
-- CREATEDB eventtracker-db;

-- Create the users table.
-- The 'id' column uses the SERIAL type, which automatically creates a unique ID for new records
-- The 'username' is set to be UNIQUE and NOT NULL to prevent duplicate usernames
-- The 'password' column stores hashed passwords
-- The 'role' column indicates the user's role in the system (admin, user, host)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL, -- Must be unique in js as well
    password VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL, -- admin, user, host

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create the events table.
-- The 'id' column is the primary key and uses SERIAL for auto-incrementing IDs
-- The 'name' and 'location' use VARCHAR to store variable-length text
-- 'time' uses the TIMESTAMP data type to store date and time information
-- 'duration' uses the INTERVAL data type, which is ideal for storing periods of time (2 hours)
-- The 'owner_id' is a FOREIGN KEY that links each event to a user and deletes events if the user is deleted
-- If the data is scraped and not user-generated, the owner_id can be set to a default admin user
-- The 'details' column is for brief information about the event
-- The 'description' column is for a more detailed explanation of the event
CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    time TIMESTAMP NOT NULL,
    duration INTERVAL NOT NULL,
    details VARCHAR(120) NOT NULL,
    description TEXT,
    adult_only BOOLEAN default FALSE, -- True if 18+ event
    isUMASS BOOLEAN default FALSE, -- True if event is run through UMass
    cost DECIMAL(10, 2) DEFAULT 0.00,
    outdoor BOOLEAN default FALSE,
    category VARCHAR(100), -- professional, social, entertainment, educational, public service, other.
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Creates the RSVP TABLE
-- Links users to the events they are attending
-- The 'status' column indicates whether the user is attending, not attending
-- The combination of user_id and event_id is set to be UNIQUE to prevent duplicate RSVPs for the same event by the same user
CREATE TABLE IF NOT EXISTS rsvps (
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    status VARCHAR(50) NOT NULL, -- Attending, Not Attending
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,

    PRIMARY KEY (user_id, event_id)
);
