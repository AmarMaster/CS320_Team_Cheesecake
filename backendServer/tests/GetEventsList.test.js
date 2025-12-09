// tests/getEventList.test.js
jest.mock("pg-promise"); // <-- activates our mock

const request = require("supertest");
const app = require("../app");  // adjust if needed

// Access the mock db instance
const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("GET /getEventList (mocked DB)", () => {

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Filter mode returns a mocked events", async () => {
    // Mock DB response for filter mode
    mockDb.manyOrNone.mockResolvedValue([
      {
        name: "Mock Event",
        latitude: 37.77,
        longitude: -122.42,
        time: "2025-01-01T12:00:00Z",
        duration: 3600,
        details: "Mock details",
        description: "Mock description"
      }
    ]);

    const res = await request(app)
      .get("/getEventList")
      .query({
        location: "-122.42,37.77",
        radius: 10,
        datetime: "2025-01-01T12:00:00",
        twentyoneplus: "false"
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.events.length).toBe(1);
    expect(res.body.data.events[0].name).toBe("Mock Event");
  });

  test("RSVP mode returns mock RSVP event list", async () => {
    // Step 1: user’s RSVP event IDs
    mockDb.manyOrNone.mockResolvedValueOnce([
      { event_id: 101 },
      { event_id: 202 }
    ]);

    // Step 2: fetch events based on IDs
    mockDb.many.mockResolvedValue([
      {
        name: "RSVP Event A",
        location: { geometry: { coordinates: [-122.1, 37.1] }},
        time: "2025-01-02T10:00:00Z",
        duration: 5000,
        details: "Details A",
        description: "Desc A"
      },
      {
        name: "RSVP Event B",
        location: { geometry: { coordinates: [-122.2, 37.2] }},
        time: "2025-01-03T11:00:00Z",
        duration: 3000,
        details: "Details B",
        description: "Desc B"
      }
    ]);

    const res = await request(app)
      .get("/getEventList")
      .query({ userID: 1 });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.events.length).toBe(2);
    expect(res.body.data.events[0].name).toBe("RSVP Event A");
  });

  test("Request with no filters returns 400", async () => {
    const res = await request(app).get("/getEventList");

    expect(res.statusCode).toBe(400);
    expect(res.body.data.success).toBe(false);
  });
});
