// tests/ChangeEvent.test.js
jest.mock("pg-promise");

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /changeEvent (mocked DB)", () => {
  
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Successfully update event returns 200", async () => {
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/changeEvent")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          event: {
            name: "Updated Party",
            location: {
              latitude: 37.77,
              longitude: -122.42
            },
            time: "2025-02-01T18:00:00Z",
            duration: 7200,
            details: "Updated details",
            description: "Updated description"
          }
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.event.name).toBe("Updated Party");
  });

  test("Missing userID doesn't prevent request (returns 200)", async () => {
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/changeEvent")
      .send({
        data: {
          eventID: "100",
          event: {
            name: "Party",
            location: { latitude: 37.77, longitude: -122.42 },
            time: "2025-02-01T18:00:00Z",
            duration: 3600,
            details: "Details",
            description: "Description"
          }
        }
      });

    // Endpoint doesn't validate, just returns success
    expect(res.statusCode).toBe(200);
  });

  test("Missing eventID doesn't prevent request (returns 200)", async () => {
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/changeEvent")
      .send({
        data: {
          userID: "1",
          event: {
            name: "Party",
            location: { latitude: 37.77, longitude: -122.42 },
            time: "2025-02-01T18:00:00Z",
            duration: 3600,
            details: "Details",
            description: "Description"
          }
        }
      });

    // Endpoint doesn't validate, just returns success
    expect(res.statusCode).toBe(200);
  });

  test("Missing event object returns 500 (accessing undefined)", async () => {
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/changeEvent")
      .send({
        data: {
          userID: "1",
          eventID: "100"
        }
      });

    // Accessing undefined.name throws error
    expect(res.statusCode).toBe(500);
  });

  test("Database error returns 403", async () => {
    mockDb.none.mockRejectedValue(new Error("Database error"));

    const res = await request(app)
      .post("/changeEvent")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          event: {
            name: "Party",
            location: { latitude: 37.77, longitude: -122.42 },
            time: "2025-02-01T18:00:00Z",
            duration: 3600,
            details: "Details",
            description: "Description"
          }
        }
      });

    expect(res.statusCode).toBe(403);
    expect(res.body.data.success).toBe(false);
  });

  test("Partial event update (only name) returns 200", async () => {
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/changeEvent")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          event: {
            name: "New Name",
            location: { latitude: 37.77, longitude: -122.42 },
            time: "2025-02-01T18:00:00Z",
            duration: 3600,
            details: "Details",
            description: "Description"
          }
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.event.name).toBe("New Name");
  });

  test("Update event location returns 200", async () => {
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/changeEvent")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          event: {
            name: "Party",
            location: {
              latitude: 40.71,
              longitude: -74.01
            },
            time: "2025-02-01T18:00:00Z",
            duration: 3600,
            details: "Details",
            description: "Description"
          }
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.event.location.latitude).toBe(40.71);
    expect(res.body.data.event.location.longitude).toBe(-74.01);
  });
});
