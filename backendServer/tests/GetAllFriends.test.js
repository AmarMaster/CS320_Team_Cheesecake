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

  test("Returns empty list of friends with success", async () => {
    mockDb.one.mockResolvedValueOnce(1);
    mockDb.manyOrNone.mockResolvedValueOnce([]);
    
    const res = await request(app)
      .post("/getAllFriends")
      .send({ data: { username: "user1" } });
    console.log("Response body:", res.body);
    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.friends.length).toBe(0);
  });

  test("Returns list of friends with success", async () => {
    mockDb.one.mockResolvedValueOnce(1);
    mockDb.manyOrNone.mockResolvedValueOnce([
      { user_id_1: 1, user_id_2: 2 },
      { user_id_1: 3, user_id_2: 1 }
    ]);
    mockDb.one.mockResolvedValueOnce(
      "friend2"
    );
    mockDb.one.mockResolvedValueOnce(
      "friend3"
    );
    
    const res = await request(app)
      .post("/getAllFriends")
      .send({ data: { username: "user1" } });
    console.log("Response body:", res.body);
    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(Array.isArray(res.body.data.friends)).toBe(true);
    expect(res.body.data.friends.length).toBe(2);
  });

  test("Internal server error returns 500", async () => {
    mockDb.one.mockRejectedValue(new Error("DB error"));
    const res = await request(app)
      .post("/getAllFriends")
      .send({ data: { username: "user1" } });
    expect(res.statusCode).toBe(500);
    expect(res.body.data.success).toBe(false);
  });

  test("Internal server 2 error returns 500", async () => {
    mockDb.one.mockResolvedValueOnce(1);
    mockDb.manyOrNone.mockRejectedValue(new Error("DB error"));
    const res = await request(app)
      .post("/getAllFriends")
      .send({ data: { username: "user1" } });
    expect(res.statusCode).toBe(500);
    expect(res.body.data.success).toBe(false);
  });
});
