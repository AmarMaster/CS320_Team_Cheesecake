// tests/Login.test.js
jest.mock("pg-promise"); // <-- activates our mock

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /login (mocked DB)", () => {

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Successful login returns 200 and a jwt", async () => {
    // DB: first call returns user id, second call returns stored password
    mockDb.one.mockResolvedValueOnce(123);
    mockDb.one.mockResolvedValueOnce("password123");

    const res = await request(app)
      .post("/login")
      .send({ data: { username: "user1", password: "password123" } });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(typeof res.body.data.jwt).toBe("string");
    expect(res.body.data.jwt.length).toBeGreaterThan(0);
  });

  test("Incorrect password returns 401", async () => {
    // DB: id found, stored password is different
    mockDb.one.mockResolvedValueOnce(123);
    mockDb.one.mockResolvedValueOnce("correct_pass");

    const res = await request(app)
      .post("/login")
      .send({ data: { username: "user1", password: "wrong_pass" } });

    // Expected behavior: 401 on incorrect password
    expect(res.statusCode).toBe(401);
    expect(res.body.data.success).toBe(false);
  });

  test("Non-existent user returns 401", async () => {
    // DB rejects when looking up username
    mockDb.one.mockRejectedValue(new Error("Not found"));

    const res = await request(app)
      .post("/login")
      .send({ data: { username: "nouser", password: "any" } });

    expect(res.statusCode).toBe(401);
    expect(res.body.data.success).toBe(false);
  });
});
