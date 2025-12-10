const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const pgp = require('pg-promise')(/* options */);

// NOTE: Update this with your actual database credentials
const db = pgp('postgres://username:password@host:port/eventtracker-db');

// Middleware to verify JWT token
const verifyToken = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'No token provided. Please log in first.'
    });
  }
  // Extract token from "Bearer <token>" format
  const bearerToken = token.split(' ')[1] || token;
  try {
    const decoded = jwt.verify(bearerToken, process.env.JWT_SECRET || 'your_jwt_secret');
    req.userId = decoded.id || decoded.userId;
    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired token'
    });
  }
};

// Validate event creation input
const validateEventInput = (req, res, next) => {
  const { name, location, time, duration, details, description } = req.body;
  // Check if all required fields are present
  if (!name || !location || !time || !duration || !details || !description) {
    return res.status(400).json({
      success: false,
      message: 'All fields are required: name, location, time, duration, details, description'
    });
  }
  // Validate field types and lengths
  if (typeof name !== 'string' || name.trim().length === 0 || name.length > 100) {
    return res.status(400).json({
      success: false,
      message: 'Event name must be a non-empty string (max 100 characters)'
    });
  }
  if (typeof location !== 'string' || location.trim().length === 0 || location.length > 255) {
    return res.status(400).json({
      success: false,
      message: 'Location must be a non-empty string (max 255 characters)'
    });
  }
  if (typeof details !== 'string' || details.trim().length === 0 || details.length > 120) {
    return res.status(400).json({
      success: false,
      message: 'Details must be a non-empty string (max 120 characters)'
    });
  }
  if (typeof description !== 'string' || description.trim().length === 0) {
    return res.status(400).json({
      success: false,
      message: 'Description must be a non-empty string'
    });
  }
  // Validate time is a valid ISO 8601 string or timestamp
  const eventTime = new Date(time);
  if (isNaN(eventTime.getTime())) {
    return res.status(400).json({
      success: false,
      message: 'Time must be a valid ISO 8601 date string (e.g., "2025-12-15T10:30:00Z")'
    });
  }
  // Validate time is in the future
  if (eventTime <= new Date()) {
    return res.status(400).json({
      success: false,
      message: 'Event time must be in the future'
    });
  }
  // Validate duration is a valid format (PostgreSQL INTERVAL format)
  // Expected format: "1 hour", "2 days", "30 minutes", etc.
  if (typeof duration !== 'string' || duration.trim().length === 0) {
    return res.status(400).json({
      success: false,
      message: 'Duration must be a valid interval string (e.g., "1 hour", "2 days", "30 minutes")'
    });
  }
  next();
};

// Validate event update input (reuse creation validation)
const validateEventUpdateInput = (req, res, next) => {
  // You can reuse the same validation as creation
  return validateEventInput(req, res, next);
};

// PUT /api/events/:id - Update an event (only the owner can update)
router.put('/:id', verifyToken, validateEventUpdateInput, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.userId;
    const { name, location, time, duration, details, description } = req.body;

    // Validate ID is a number
    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid event ID'
      });
    }

    // Check if event exists and user is the owner
    const checkQuery = 'SELECT owner_id FROM events WHERE id = $1';
    let event;
    try {
      event = await db.one(checkQuery, [id]);
    } catch (err) {
      if (err.message.includes('No rows found')) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }
      throw err;
    }

    if (event.owner_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'You are not authorized to update this event'
      });
    }

    // Update the event in the database
    const updateQuery = `
      UPDATE events
      SET name = $2, location = $3, time = $4, duration = $5, details = $6, description = $7
      WHERE id = $1
      RETURNING id, name, location, time, duration, details, description, owner_id, created_at
    `;
    const updatedEvent = await db.one(updateQuery, [id, name, location, time, duration, details, description]);

    return res.status(200).json({
      success: true,
      message: 'Event updated successfully',
      data: updatedEvent
    });
  } catch (err) {
    console.error('Error updating event:', err);
    if (err.message.includes('No rows found')) {
      return res.status(404).json({
        success: false,
        message: 'Event not found'
      });
    }
    return res.status(500).json({
      success: false,
      message: 'Failed to update event. Please try again later.'
    });
  }
});

// POST /api/events - Create a new event
router.post('/', verifyToken, validateEventInput, async (req, res) => {
  try {
    const { name, location, time, duration, details, description } = req.body;
    const owner_id = req.userId;

    // Insert event into database
    const query = `
      INSERT INTO events (name, location, time, duration, details, description, owner_id, created_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP)
      RETURNING id, name, location, time, duration, details, description, owner_id, created_at
    `;

    const newEvent = await db.one(query, [name, location, time, duration, details, description, owner_id]);

    return res.status(201).json({
      success: true,
      message: 'Event created successfully',
      data: newEvent
    });

  } catch (err) {
    console.error('Error creating event:', err);

    // Handle specific database errors
    if (err.message.includes('foreign key')) {
      return res.status(400).json({
        success: false,
        message: 'Invalid user ID. Please log in again.'
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to create event. Please try again later.'
    });
  }
});

// GET /api/events - Get all events
router.get('/', async (req, res) => {
  try {
    const query = `
      SELECT e.id, e.name, e.location, e.time, e.duration, e.details, e.description, 
             e.owner_id, e.created_at, u.username as owner_name
      FROM events e
      LEFT JOIN users u ON e.owner_id = u.id
      ORDER BY e.time ASC
    `;

    const events = await db.any(query);

    return res.status(200).json({
      success: true,
      message: 'Events retrieved successfully',
      data: events
    });

  } catch (err) {
    console.error('Error retrieving events:', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve events. Please try again later.'
    });
  }
});

// GET /api/events/:id - Get a single event by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Validate ID is a number
    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid event ID'
      });
    }

    const query = `
      SELECT e.id, e.name, e.location, e.time, e.duration, e.details, e.description, 
             e.owner_id, e.created_at, u.username as owner_name
      FROM events e
      LEFT JOIN users u ON e.owner_id = u.id
      WHERE e.id = $1
    `;

    const event = await db.one(query, [id]);

    return res.status(200).json({
      success: true,
      message: 'Event retrieved successfully',
      data: event
    });

  } catch (err) {
    console.error('Error retrieving event:', err);
    
    if (err.message.includes('No rows found')) {
      return res.status(404).json({
        success: false,
        message: 'Event not found'
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to retrieve event. Please try again later.'
    });
  }
});

// DELETE /api/events/:id - Delete an event (only the owner can delete)
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.userId;

    // Validate ID is a number
    if (isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid event ID'
      });
    }

    // Check if event exists and user is the owner
    const checkQuery = 'SELECT owner_id FROM events WHERE id = $1';
      let event;
      try {
        event = await db.one(checkQuery, [id]);
      } catch (err) {
        if (err.message && err.message.includes('No rows found')) {
          return res.status(404).json({
            success: false,
            message: 'Event not found'
          });
        }
        return res.status(500).json({
          success: false,
          message: 'Database error'
        });
      }

      if (!event || !event.owner_id) {
        // Defensive: should never happen, but just in case
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      if (event.owner_id !== userId) {
        return res.status(403).json({
          success: false,
          message: 'You are not authorized to delete this event'
        });
      }

      // Delete the event
      const deleteQuery = 'DELETE FROM events WHERE id = $1 RETURNING id';
      try {
        await db.one(deleteQuery, [id]);
      } catch (err) {
        if (err.message && err.message.includes('No rows found')) {
          return res.status(404).json({
            success: false,
            message: 'Event not found'
          });
        }
        return res.status(500).json({
          success: false,
          message: 'Database error'
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Event deleted successfully'
      });
  } catch (err) {
    console.error('Error deleting event:', err);

    if (err.message.includes('No rows found')) {
      return res.status(404).json({
        success: false,
        message: 'Event not found'
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Failed to delete event. Please try again later.'
    });
  }
});

// --- Slider Operations: Favorite, RSVP, Hosted ---

// Toggle Favorite
router.post('/:id/fav', verifyToken, async (req, res) => {
  const { id } = req.params;
  const userId = req.userId;
  if (isNaN(id)) {
    return res.status(400).json({ success: false, message: 'Invalid event ID' });
  }
  // Simulate DB lookup for event
  try {
    const event = await db.oneOrNone('SELECT id FROM events WHERE id = $1', [id]);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }
    // Simulate toggle logic (replace with real DB logic)
    // e.g., check if already favorited, then remove; else add
    // For now, just return success
    return res.status(200).json({ success: true, message: 'Favorite toggled', data: { eventId: id, userId } });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Toggle RSVP
router.post('/:id/rsvp', verifyToken, async (req, res) => {
  const { id } = req.params;
  const userId = req.userId;
  if (isNaN(id)) {
    return res.status(400).json({ success: false, message: 'Invalid event ID' });
  }
  try {
    const event = await db.oneOrNone('SELECT id FROM events WHERE id = $1', [id]);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }
    // Simulate toggle logic
    return res.status(200).json({ success: true, message: 'RSVP toggled', data: { eventId: id, userId } });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Toggle Hosted (for demo, just returns success)
router.post('/:id/hosted', verifyToken, async (req, res) => {
  const { id } = req.params;
  const userId = req.userId;
  if (isNaN(id)) {
    return res.status(400).json({ success: false, message: 'Invalid event ID' });
  }
  try {
    const event = await db.oneOrNone('SELECT id FROM events WHERE id = $1', [id]);
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }
    // Simulate toggle logic
    return res.status(200).json({ success: true, message: 'Hosted toggled', data: { eventId: id, userId } });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

module.exports = router;
