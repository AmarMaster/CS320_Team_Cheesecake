// tests/DeleteEvent.test.js
jest.mock("pg-promise");

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /deleteEvent (mocked DB)", () => {
  
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Successfully delete event returns 200", async () => {
    mockDb.one.mockResolvedValue({ owner_id: "1" });
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/deleteEvent")
      .send({
        data: {
          userID: "1",
          eventID: "100"
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.message).toBe("Event deleted successfully.");
  });

  test("Missing eventID returns 400", async () => {
    const res = await request(app)
      .post("/deleteEvent")
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
      .post("/deleteEvent")
      .send({
        data: {
          eventID: "100"
        }
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toContain("Missing");
  });

  test("Non-owner cannot delete event returns 403", async () => {
    mockDb.one.mockResolvedValue({ owner_id: "2" });

    const res = await request(app)
      .post("/deleteEvent")
      .send({
        data: {
          userID: "1",
          eventID: "100"
        }
      });

    expect(res.statusCode).toBe(403);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toContain("not authorized");
  });

  test("Event not found returns 404", async () => {
    mockDb.one.mockRejectedValue(new Error("Not found"));

    const res = await request(app)
      .post("/deleteEvent")
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

  test("Database error on delete returns 500", async () => {
    mockDb.one.mockResolvedValue({ owner_id: "1" });
    mockDb.none.mockRejectedValue(new Error("Database error"));

    const res = await request(app)
      .post("/deleteEvent")
      .send({
        data: {
          userID: "1",
          eventID: "100"
        }
      });

    expect(res.statusCode).toBe(500);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toContain("Failed to delete");
  });

  test("Delete with numeric userID returns 200", async () => {
    mockDb.one.mockResolvedValue({ owner_id: 1 });
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/deleteEvent")
      .send({
        data: {
          userID: 1,
          eventID: "100"
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
  });
});
