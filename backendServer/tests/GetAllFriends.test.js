// tests/GetAllFriends.test.js
jest.mock("pg-promise");

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /getAllFriends (mocked DB)", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Returns list of friends with success", async () => {
    mockDb.any.mockResolvedValue([
      { username: "friend1" },
      { username: "friend2" }
    ]);
    const res = await request(app)
      .post("/getAllFriends")
      .send({ data: { username: "user1" } });
    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(Array.isArray(res.body.data.friends)).toBe(true);
  });

  test("Internal server error returns 500", async () => {
    mockDb.any.mockRejectedValue(new Error("DB error"));
    const res = await request(app)
      .post("/getAllFriends")
      .send({ data: { username: "user1" } });
    expect(res.statusCode).toBe(500);
    expect(res.body.data.success).toBe(false);
  });
});
