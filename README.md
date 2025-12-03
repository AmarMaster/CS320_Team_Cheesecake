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

### 4. Gain Access to the Database

Find your IP address and Subnet:

Windows:
```bash
ipconfig
```
Linux/Mac:
```bash
ifconfig
```

Find both the IP address of your local machine (ex. inet 198.162.0.x) and the netmask (ex. 255.255.255.0).

Send both of these to [colbygross@umass.edu](malito:colbygross@umass.edu) to have the subnet permitted in an AWS security group.

A different submission must be used for the different networks that the app will be run on.

Make sure the .env file is inside the project with the correct database credentials. 

### 5. Run the Backend
```bash
cd backendServer
npm start
```
The following message should be shown and the backend will run until it is exited.
"EventMapper backend listening on port xxx"
