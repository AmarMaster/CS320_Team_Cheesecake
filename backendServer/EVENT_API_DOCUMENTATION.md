# Event Creation API Documentation

## Overview
This document describes the Event Creation API endpoints for the EventTracker application. The API handles creating, retrieving, and managing events in the database.

## Base URL
```
http://localhost:3000/api
```

## Authentication
Most endpoints require JWT (JSON Web Token) authentication. The token should be sent in the `Authorization` header:
```
Authorization: Bearer <your_jwt_token>
```

---

## Endpoints

### 1. Create Event
**POST** `/api/events`

Creates a new event in the database.

**Required Headers:**
- `Content-Type: application/json`
- `Authorization: Bearer <jwt_token>`

**Request Body:**
```json
{
  "name": "String (max 100 chars)",
  "location": "String (max 255 chars)",
  "time": "ISO 8601 timestamp (e.g., 2025-12-15T10:30:00Z)",
  "duration": "PostgreSQL INTERVAL (e.g., '1 hour', '2 days', '30 minutes')",
  "details": "String (max 120 chars)",
  "description": "String (detailed event description)"
}
```

**Response (Success - 201):**
```json
{
  "success": true,
  "message": "Event created successfully",
  "data": {
    "id": 1,
    "name": "University Hackathon",
    "location": "Engineering Building",
    "time": "2025-12-15T10:30:00Z",
    "duration": "1 hour",
    "details": "Annual university hackathon event",
    "description": "Join us for an exciting day of coding and innovation...",
    "owner_id": 5,
    "created_at": "2025-11-12T14:30:00Z"
  }
}
```

**Response (Failure - 400):**
```json
{
  "success": false,
  "message": "Event name must be a non-empty string (max 100 characters)"
}
```

**Response (Failure - 401):**
```json
{
  "success": false,
  "message": "Invalid or expired token"
}
```

**Validation Rules:**
- All fields are **required**
- `name`: Non-empty string, max 100 characters
- `location`: Non-empty string, max 255 characters
- `details`: Non-empty string, max 120 characters
- `description`: Non-empty string
- `time`: Valid ISO 8601 timestamp, must be in the future
- `duration`: Valid PostgreSQL INTERVAL format

---

### 2. Get All Events
**GET** `/api/events`

Retrieves all events from the database, ordered by start time.

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Events retrieved successfully",
  "data": [
    {
      "id": 1,
      "name": "University Hackathon",
      "location": "Engineering Building",
      "time": "2025-12-15T10:30:00Z",
      "duration": "1 hour",
      "details": "Annual university hackathon event",
      "description": "Join us for an exciting day of coding and innovation...",
      "owner_id": 5,
      "owner_name": "john_doe",
      "created_at": "2025-11-12T14:30:00Z"
    },
    {
      "id": 2,
      "name": "Career Fair",
      "location": "Student Center",
      "time": "2025-12-20T09:00:00Z",
      "duration": "4 hours",
      "details": "Meet with top tech companies",
      "description": "Connect with recruiters from leading companies...",
      "owner_id": 3,
      "owner_name": "admin",
      "created_at": "2025-11-10T10:00:00Z"
    }
  ]
}
```

---

### 3. Get Single Event
**GET** `/api/events/:id`

Retrieves a specific event by ID.

**URL Parameters:**
- `id` (required): Event ID (number)

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Event retrieved successfully",
  "data": {
    "id": 1,
    "name": "University Hackathon",
    "location": "Engineering Building",
    "time": "2025-12-15T10:30:00Z",
    "duration": "1 hour",
    "details": "Annual university hackathon event",
    "description": "Join us for an exciting day of coding and innovation...",
    "owner_id": 5,
    "owner_name": "john_doe",
    "created_at": "2025-11-12T14:30:00Z"
  }
}
```

**Response (Failure - 404):**
```json
{
  "success": false,
  "message": "Event not found"
}
```

---

### 4. Delete Event
**DELETE** `/api/events/:id`

Deletes an event (only the event owner can delete).

**Required Headers:**
- `Authorization: Bearer <jwt_token>`

**URL Parameters:**
- `id` (required): Event ID (number)

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Event deleted successfully"
}
```

**Response (Failure - 403):**
```json
{
  "success": false,
  "message": "You are not authorized to delete this event"
}
```

**Response (Failure - 404):**
```json
{
  "success": false,
  "message": "Event not found"
}
```

---

## Usage Examples

### Example 1: Create an Event using cURL
```bash
curl -X POST http://localhost:3000/api/events \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "name": "University Hackathon",
    "location": "Engineering Building",
    "time": "2025-12-15T10:30:00Z",
    "duration": "1 hour",
    "details": "Annual university hackathon event",
    "description": "Join us for an exciting day of coding and innovation. Teams of up to 4 students..."
  }'
```

### Example 2: Get All Events using JavaScript Fetch
```javascript
async function getAllEvents() {
  try {
    const response = await fetch('http://localhost:3000/api/events', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    const data = await response.json();
    console.log(data);
  } catch (error) {
    console.error('Error:', error);
  }
}
```

### Example 3: Create Event using JavaScript Fetch
```javascript
async function createEvent(eventData, jwtToken) {
  try {
    const response = await fetch('http://localhost:3000/api/events', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${jwtToken}`
      },
      body: JSON.stringify({
        name: eventData.name,
        location: eventData.location,
        time: eventData.time,
        duration: eventData.duration,
        details: eventData.details,
        description: eventData.description
      })
    });
    const data = await response.json();
    
    if (data.success) {
      console.log('Event created:', data.data);
      // Redirect to event feed page
      window.location.href = '/events';
    } else {
      console.error('Error:', data.message);
      // Show error message to user
      alert(data.message);
    }
  } catch (error) {
    console.error('Error:', error);
  }
}

// Usage
createEvent({
  name: 'Tech Talk',
  location: 'Room 101',
  time: '2025-12-20T15:00:00Z',
  duration: '1 hour',
  details: 'Industry experts discussing AI',
  description: 'A comprehensive talk on AI trends...'
}, jwtToken);
```

---

## Error Handling

### Common Error Codes:
- **400**: Bad Request - Invalid input or missing required fields
- **401**: Unauthorized - Missing or invalid token
- **403**: Forbidden - User lacks permission (e.g., not the event owner)
- **404**: Not Found - Event doesn't exist
- **500**: Internal Server Error - Database or server error

### Error Response Format:
```json
{
  "success": false,
  "message": "Description of what went wrong"
}
```

---

## Environment Variables

Make sure to set the following environment variable for JWT authentication:
```
JWT_SECRET=your_jwt_secret_key
```

If not set, the app defaults to `'your_jwt_secret'` (not recommended for production).

---

## Database Schema Reference

### Events Table
```sql
CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    time TIMESTAMP NOT NULL,
    duration INTERVAL NOT NULL,
    details VARCHAR(120) NOT NULL,
    description TEXT NOT NULL,
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## Setup Instructions

1. **Install Dependencies:**
   ```bash
   cd backendServer
   npm install
   ```

2. **Configure Database:**
   Update the database connection string in `routes/events.js`:
   ```javascript
   const db = pgp('postgres://username:password@host:port/eventtracker-db');
   ```

3. **Start the Server:**
   ```bash
   npm start
   ```
   The server will run on `http://localhost:3000`

4. **Test the API:**
   Use the examples above or a tool like Postman to test the endpoints.

