// tests/RemoveFriend.test.js
jest.mock("pg-promise");

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /removeFriend (mocked DB)", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Successful friend removal returns 200", async () => {
    mockDb.none.mockResolvedValue(undefined);
    const res = await request(app)
      .post("/removeFriend")
      .send({ data: { username: "user1", friendUsername: "user2" } });
    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.message).toBe("Friend removed.");
  });

  test("Internal server error returns 500", async () => {
    mockDb.none.mockRejectedValue(new Error("DB error"));
    const res = await request(app)
      .post("/removeFriend")
      .send({ data: { username: "user1", friendUsername: "user2" } });
    expect(res.statusCode).toBe(500);
    expect(res.body.data.success).toBe(false);
  });
});
