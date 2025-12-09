// login.test.js using pg-promise mock style
// login.test.js using pg-promise mock style
jest.mock('pg-promise');
const request = require('supertest');
const app = require('../app');
const pgp = require('pg-promise');
const mockDb = pgp.__mockDb;

describe('POST /login (mocked DB)', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('Login: happy path (valid credentials)', async () => {
    // Mock db.one to return user with password 'testpass'
    mockDb.one.mockResolvedValue({ password: 'testpass' });

    const res = await request(app)
      .post('/login')
      .send({ data: { userID: 'testuser', password: 'testpass' } });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data).toHaveProperty('jwt');
  });

  test('Login: invalid password', async () => {
    // Mock db.one to return user with password 'testpass'
    mockDb.one.mockResolvedValue({ password: 'testpass' });

    const res = await request(app)
      .post('/login')
      .send({ data: { userID: 'testuser', password: 'wrongpass' } });

    expect(res.statusCode).toBe(401);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.jwt).toBe('');
  });

  test('Login: user not found', async () => {
    // Mock db.one to reject (user not found)
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
