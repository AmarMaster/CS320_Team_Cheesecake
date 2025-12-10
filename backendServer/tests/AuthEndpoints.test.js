// AuthEndpoints.test.js using pg-promise
jest.mock('pg-promise');
const request = require('supertest');
const app = require('../app');
const pgp = require('pg-promise');
const mockDb = pgp.__mockDb;

describe('Auth Endpoints (mocked DB)', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  // LOGIN TESTS
  describe('POST /login', () => {
    test('Login: happy path (valid credentials)', async () => {
      mockDb.one.mockResolvedValue({ password: 'testpass' });
      const res = await request(app)
        .post('/login')
        .send({ data: { userID: 'testuser', password: 'testpass' } });
      expect(res.statusCode).toBe(200);
      expect(res.body.data.success).toBe(true);
      expect(res.body.data).toHaveProperty('jwt');
    });

    test('Login: invalid password', async () => {
      mockDb.one.mockResolvedValue({ password: 'testpass' });
      const res = await request(app)
        .post('/login')
        .send({ data: { userID: 'testuser', password: 'wrongpass' } });
      expect(res.statusCode).toBe(401);
      expect(res.body.data.success).toBe(false);
      expect(res.body.data.jwt).toBe('');
    });

    test('Login: user not found', async () => {
      mockDb.one.mockRejectedValue(new Error('Not found'));
      const res = await request(app)
        .post('/login')
        .send({ data: { userID: 'nouser', password: 'any' } });
      expect(res.statusCode).toBe(401);
      expect(res.body.data.success).toBe(false);
      expect(res.body.data.jwt).toBe('');
    });

    test('Login: missing password', async () => {
      const res = await request(app)
        .post('/login')
        .send({ data: { userID: 'testuser' } });
      expect(res.statusCode).toBe(401);
      expect(res.body.data.success).toBe(false);
    });

    test('Login: missing userID', async () => {
      const res = await request(app)
        .post('/login')
        .send({ data: { password: 'testpass' } });
      expect(res.statusCode).toBe(401);
      expect(res.body.data.success).toBe(false);
    });
  });

  // REGISTER TESTS
  describe('POST /createAccount', () => {
    test('Register: happy path (valid registration)', async () => {
      // No user found, so registration proceeds
      mockDb.many.mockResolvedValue([]); // No user found
      mockDb.none.mockResolvedValue();   // simulate successful insert
      const res = await request(app)
        .post('/createAccount')
        .send({ data: { name: 'newuser', password: 'newpass', email: 'new@user.com' } });
      expect(res.statusCode).toBe(201);
      expect(res.body.data.success).toBe(true);
      expect(res.body.data).toHaveProperty('jwt');
    });

    test('Register: missing email', async () => {
      const res = await request(app)
        .post('/createAccount')
        .send({ data: { name: 'newuser', password: 'newpass' } });
      expect(res.statusCode).toBe(400);
      expect(res.body.data.success).toBe(false);
    });

    test('Register: invalid email format', async () => {
      mockDb.many.mockRejectedValue(new Error('Not found'));
      const res = await request(app)
        .post('/createAccount')
        .send({ data: { name: 'newuser', password: 'newpass', email: 'notanemail' } });
      expect(res.statusCode).toBe(400);
      expect(res.body.data.success).toBe(false);
    });

    test('Register: existing username/email', async () => {
      mockDb.many.mockResolvedValue([{ name: 'newuser', email: 'new@user.com' }]);
      const res = await request(app)
        .post('/createAccount')
        .send({ data: { name: 'newuser', password: 'newpass', email: 'new@user.com' } });
      expect(res.statusCode).toBe(409);
      expect(res.body.data.success).toBe(false);
    });

    test('Register: large input (long username/email)', async () => {
      mockDb.many.mockRejectedValue(new Error('Not found'));
      const longName = 'a'.repeat(300);
      const longEmail = 'b'.repeat(300) + '@test.com';
      const res = await request(app)
        .post('/createAccount')
        .send({ data: { name: longName, password: 'newpass', email: longEmail } });
      expect([400, 409]).toContain(res.statusCode);
      expect(res.body.data.success).toBe(false);
    });
  });
});
