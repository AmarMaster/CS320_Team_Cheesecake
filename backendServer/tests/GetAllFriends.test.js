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
    // Mock db.one() to return user ID
    mockDb.one.mockResolvedValue({ id: 1 });
    // Mock db.manyOrNone() to return friendships
    mockDb.manyOrNone.mockResolvedValue([
      { user_id_1: 1, user_id_2: 2 },
      { user_id_1: 1, user_id_2: 3 }
    ]);
    // Mock getUsernamefromID calls - needs to return usernames for IDs 2 and 3
    mockDb.one
      .mockResolvedValueOnce({ id: 1 })
      .mockResolvedValueOnce("friend1")
      .mockResolvedValueOnce("friend2");

    const res = await request(app)
      .post("/getAllFriends")
      .send({ data: { username: "user1" } });
    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(Array.isArray(res.body.data.friends)).toBe(true);
  });

  test("Internal server error returns 500", async () => {
    mockDb.one.mockRejectedValue(new Error("DB error"));
    const res = await request(app)
      .post("/getAllFriends")
      .send({ data: { username: "user1" } });
    expect(res.statusCode).toBe(500);
    expect(res.body.data.success).toBe(false);
  });
});
