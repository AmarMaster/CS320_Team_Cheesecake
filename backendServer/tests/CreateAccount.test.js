// tests/CreateAccount.test.js
jest.mock("pg-promise"); // <-- use our mock

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /createAccount (mocked DB)", () => {

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Username already taken returns 403", async () => {
    // Simulate db.many resolving (user found)
    mockDb.many.mockResolvedValue([{ username: "taken" }]);

    const res = await request(app)
      .post("/createAccount")
      .send({ data: { name: "taken", password: "pw", email: "a@b.com" } });

    expect(res.statusCode).toBe(403);
    expect(res.body.data.success).toBe(false);
  });

  test("New username creates account and returns 200 with jwt", async () => {
    // Simulate db.many rejecting (no user found), and db.none resolving for insert
    mockDb.many.mockRejectedValue(new Error("No user"));
    mockDb.none.mockResolvedValue(undefined);
    // After insert, lookup id for the new username
    mockDb.one.mockResolvedValueOnce(321);

    const res = await request(app)
      .post("/createAccount")
      .send({ data: { name: "newuser", password: "passw0rd1", email: "new@b.com" } });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(typeof res.body.data.jwt).toBe("string");
    expect(res.body.data.jwt.length).toBeGreaterThan(0);
  });

  test("Invalid password (too short or missing digit) returns 400", async () => {
    // username not taken
    mockDb.many.mockRejectedValue(new Error("No user"));

    const res = await request(app)
      .post("/createAccount")
      .send({ data: { name: "anotherNewUser", password: "short", email: "a@b.com" } });

    expect(res.statusCode).toBe(400);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toBeDefined();
    expect(res.body.data.message).toMatch(/at least 8 characters/i);
  });
});
