// EventEndpoints.test.js using pg-promise
jest.mock('pg-promise');
const request = require('supertest');
const app = require('../app');
const pgp = require('pg-promise');
const mockDb = pgp.__mockDb;

const jwt = require('jsonwebtoken');
const TEST_USER_ID = 1;
const TEST_TOKEN = jwt.sign({ id: TEST_USER_ID }, 'your_jwt_secret');

describe('Event Endpoints (mocked DB)', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  // CREATE EVENT
  describe('POST /api/events', () => {
    test('Happy path: valid event data', async () => {
      mockDb.one.mockResolvedValue({ id: 1, name: 'Party' });
      const res = await request(app)
        .post('/api/events')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({
          name: 'Party',
          location: 'Campus',
          time: '2025-12-10T18:00:00Z',
          duration: '2 hours',
          details: 'Bring snacks',
          description: 'End of semester party'
        });
      expect(res.statusCode).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('id');
    });
    test('Missing required field (name)', async () => {
      const res = await request(app)
        .post('/api/events')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({
          location: 'Campus',
          time: '2025-12-10T18:00:00Z',
          duration: '2 hours',
          details: 'Bring snacks',
          description: 'End of semester party'
        });
      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });
    test('Wrong data type (time as string)', async () => {
      const res = await request(app)
        .post('/api/events')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({
          name: 'Party',
          location: 'Campus',
          time: 'not-a-date',
          duration: '2 hours',
          details: 'Bring snacks',
          description: 'End of semester party'
        });
      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });
    test('Large input: long name', async () => {
      const longName = 'a'.repeat(200);
      const res = await request(app)
        .post('/api/events')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({
          name: longName,
          location: 'Campus',
          time: '2025-12-10T18:00:00Z',
          duration: '2 hours',
          details: 'Bring snacks',
          description: 'End of semester party'
        });
      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });
  });

  // LIST EVENTS
  describe('GET /api/events', () => {
    test('Happy path: valid request', async () => {
      mockDb.any.mockResolvedValue([{ id: 1, name: 'Party' }]);
      const res = await request(app).get('/api/events');
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
    test('Invalid filter param', async () => {
      // Pretend the backend ignores unknown filters and returns all events
      mockDb.any.mockResolvedValue([{ id: 1, name: 'Party' }]);
      const res = await request(app).get('/api/events?unknownFilter=123');
      expect(res.statusCode).toBe(200); // Should still succeed
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    test('Large input: long filter value', async () => {
      const longValue = 'a'.repeat(500);
      mockDb.any.mockResolvedValue([{ id: 1, name: 'Party' }]);
      const res = await request(app).get(`/api/events?location=${longValue}`);
      expect(res.statusCode).toBe(200); // Should still succeed
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  // GET EVENT DETAIL
  describe('GET /api/events/:id', () => {
    test('Happy path: valid event ID', async () => {
      mockDb.one.mockResolvedValue({ id: 1, name: 'Party' });
      const res = await request(app).get('/api/events/1');
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('id');
    });
    test('Non-existent event ID', async () => {
      mockDb.one.mockRejectedValue(new Error('No rows found'));
      const res = await request(app).get('/api/events/9999');
      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
    });
    test('Invalid event ID format', async () => {
      const res = await request(app).get('/api/events/abc');
      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });
  });

  // UPDATE EVENT (if implemented)
  describe('PUT /api/events/:id', () => {
    test('Happy path: valid update', async () => {
      // Pretend the event exists and is owned by the user
      mockDb.one.mockResolvedValueOnce({ owner_id: TEST_USER_ID }); // owner check
      mockDb.one.mockResolvedValueOnce({ id: 1, name: 'Updated Party' }); // updated event
      const res = await request(app)
        .put('/api/events/1')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({
          name: 'Updated Party',
          location: 'Campus',
          time: '2025-12-11T18:00:00Z',
          duration: '3 hours',
          details: 'Bring drinks',
          description: 'End of semester party updated'
        });
      expect([200, 204]).toContain(res.statusCode);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('id');
    });

    test('Non-existent event ID', async () => {
      mockDb.one.mockRejectedValue(new Error('No rows found'));
      const res = await request(app)
        .put('/api/events/9999')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({
          name: 'Updated Party',
          location: 'Campus',
          time: '2025-12-11T18:00:00Z',
          duration: '3 hours',
          details: 'Bring drinks',
          description: 'End of semester party updated'
        });
      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
    });

    test('Bad data: missing name', async () => {
      // Pretend the event exists and is owned by the user
      mockDb.one.mockResolvedValueOnce({ owner_id: TEST_USER_ID }); // owner check
      const res = await request(app)
        .put('/api/events/1')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({
          location: 'Campus',
          time: '2025-12-11T18:00:00Z',
          duration: '3 hours',
          details: 'Bring drinks',
          description: 'End of semester party updated'
        });
      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });
  });

  // DELETE EVENT
  describe('DELETE /api/events/:id', () => {
    test('Happy path: valid event ID', async () => {
      mockDb.one.mockResolvedValueOnce({ owner_id: TEST_USER_ID }); // owner check
      mockDb.one.mockResolvedValueOnce({ id: 1 }); // for delete
      const res = await request(app)
        .delete('/api/events/1')
        .set('Authorization', `Bearer ${TEST_TOKEN}`);
      expect(res.statusCode).toBe(200);
      expect(res.body.success).toBe(true);
    });
    test('Non-existent event ID', async () => {
      mockDb.one.mockRejectedValue(new Error('No rows found'));
      const res = await request(app)
        .delete('/api/events/9999')
        .set('Authorization', `Bearer ${TEST_TOKEN}`);
      expect(res.statusCode).toBe(404);
      expect(res.body.success).toBe(false);
    });
    test('Invalid event ID format', async () => {
      const res = await request(app)
        .delete('/api/events/abc')
        .set('Authorization', `Bearer ${TEST_TOKEN}`);
      expect(res.statusCode).toBe(400);
      expect(res.body.success).toBe(false);
    });
  });
});
