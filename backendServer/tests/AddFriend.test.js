// tests/AddFriend.test.js
jest.mock("pg-promise");

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /addFriend (mocked DB)", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Missing parameters returns 400", async () => {
    const res = await request(app)
      .post("/addFriend")
      .send({ data: { username: "user1" } });
    expect(res.statusCode).toBe(400);
    expect(res.body.data.success).toBe(false);
  });

  test("Successful friend addition returns 200", async () => {
    mockDb.none.mockResolvedValue(undefined);
    mockDb.many.mockResolvedValue([]);
    mockDb.one.mockResolvedValueOnce(123);
    mockDb.one.mockResolvedValueOnce(456);
    const res = await request(app)
      .post("/addFriend")
      .send({ data: { username: "user1", friendUsername: "user2" } });
    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.message).toBe("Friend added.");
  });

  test("Internal server error returns 500", async () => {
    mockDb.none.mockRejectedValue(new Error("DB error"));
    mockDb.many.mockResolvedValue([]);
    mockDb.one.mockResolvedValueOnce(123);
    mockDb.one.mockResolvedValueOnce(456);
    const res = await request(app)
      .post("/addFriend")
      .send({ data: { username: "user1", friendUsername: "user2" } });
    expect(res.statusCode).toBe(500);
    expect(res.body.data.success).toBe(false);
  });
});
