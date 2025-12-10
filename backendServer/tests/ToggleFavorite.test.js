// tests/ToggleFavorite.test.js
jest.mock("pg-promise");

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /toggleFavorite (mocked DB)", () => {
  
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Successfully toggle favorite returns 200", async () => {
    mockDb.oneOrNone.mockResolvedValue({ id: "100" });

    const res = await request(app)
      .post("/toggleFavorite")
      .send({
        data: {
          userID: "1",
          eventID: "100"
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.message).toBe("Favorite toggled.");
    expect(res.body.data.data.eventId).toBe("100");
    expect(res.body.data.data.userId).toBe("1");
  });

  test("Missing eventID returns 400", async () => {
    const res = await request(app)
      .post("/toggleFavorite")
      .send({
        data: {
          userID: "1"
        }
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toContain("Missing");
  });

  test("Missing userID returns 400", async () => {
    const res = await request(app)
      .post("/toggleFavorite")
      .send({
        data: {
          eventID: "100"
        }
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toContain("Missing");
  });

  test("Event not found returns 404", async () => {
    mockDb.oneOrNone.mockResolvedValue(null);

    const res = await request(app)
      .post("/toggleFavorite")
      .send({
        data: {
          userID: "1",
          eventID: "999"
        }
      });

    expect(res.statusCode).toBe(404);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toContain("Event not found");
  });

  test("Database error returns 500", async () => {
    mockDb.oneOrNone.mockRejectedValue(new Error("Database error"));

    const res = await request(app)
      .post("/toggleFavorite")
      .send({
        data: {
          userID: "1",
          eventID: "100"
        }
      });

    expect(res.statusCode).toBe(500);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toContain("Server error");
  });

  test("Toggle favorite returns correct data structure", async () => {
    mockDb.oneOrNone.mockResolvedValue({ id: "100" });

    const res = await request(app)
      .post("/toggleFavorite")
      .send({
        data: {
          userID: "5",
          eventID: "50"
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data).toHaveProperty("success", true);
    expect(res.body.data).toHaveProperty("message");
    expect(res.body.data).toHaveProperty("data");
    expect(res.body.data.data.eventId).toBe("50");
    expect(res.body.data.data.userId).toBe("5");
  });

  test("Multiple toggle attempts return 200 each time", async () => {
    mockDb.oneOrNone.mockResolvedValue({ id: "100" });

    // First toggle
    let res = await request(app)
      .post("/toggleFavorite")
      .send({
        data: { userID: "1", eventID: "100" }
      });
    expect(res.statusCode).toBe(200);

    // Second toggle
    res = await request(app)
      .post("/toggleFavorite")
      .send({
        data: { userID: "1", eventID: "100" }
      });
    expect(res.statusCode).toBe(200);
  });
});
