# CS 320 Team Cheesecake

## Overview
Event Tracker is a mobile application that centralizes UMass Amherst and local Amherst events into one platform.

Currently, event listings are scattered across sites like Campus Pulse and the UMass website.
This app aggregates all events (academic, social, and community) into a unified feed and map view for simpler discovery, creation, and attendance tracking.

## Installation & Setup
Follow these steps to install and run **Event Tracker** locally.

### 1. Prerequisites
Make sure the following are installed on your system:
- **Node.js** (v18 or higher)
- **npm**
- **PostgreSQL**
- **Xcode** (for Swift frontend development)


###  2. Clone the Repository
```bash
git clone https://github.com/AmarMaster/CS320_Team_Cheesecake.git
cd CS320_Team_Cheesecake
```

### 3. Install Dependencies
```bash
cd backendServer
npm install
cd ..
```
This installs all necessary Node.js packages listed in package.json

### 4. Set Up the Database
```bash
psql -U postgres
```

This runs the psql process from the terminal as the Postgres user

```SQL
CREATE DATABASE event_tracker_db;
```
This creates the database on the local machine

```SQL
\q
```
Exit the terminal

```bash
psql -U <your_user> -d event_tracker_db -f <path_to_datatabase_init.sql>
```
Run this from the terminal replacing the username and path to the database initialization file to create the tables in the datbase with their relations

```bash
psql -U <your_username> -d event_tracker_db
```
Connect to the database from the terminal again

```SQL
\COPY users (id, username, email, password, role, created_at)
FROM 'mock_users.csv'
DELIMITER ','
CSV HEADER;
```

```SQL
\COPY events (id, name, location, time, duration, details, description, adult_only, isUMASS, cost, outdoor, category, owner_id)
FROM 'mock_events.csv'
DELIMITER ','
CSV HEADER;
```

Run these two commands once connected to the SQL database to input the mock data into the tables.

### 5. Run the Backend
```bash
cd backendServer
npm start
```
The following message should be shown and the backend will run until it is exited.
"EventMapper backend listening on port xxx"
