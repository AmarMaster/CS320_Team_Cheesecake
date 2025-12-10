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

  test("Filter mode returns no events for empty search", async () => {
    // Mock DB response for filter mode
    mockDb.manyOrNone.mockResolvedValue([]);

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
    expect(res.body.data.events.length).toBe(0);
  });

  test("Filter mode returns a single event", async () => {
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

  test("Rejects when no filters are provided", async () => {
    const res = await request(app).get("/getEventList");

    expect(res.statusCode).toBe(400);
    expect(res.body.data.success).toBe(false);
  });

  test("RSVP mode returns events for a valid userID", async () => {
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
      .query({ userID: 1 }); // change if needed

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(Array.isArray(res.body.data.events)).toBe(true);
  });

  test("RSVP mode returns an empty list when user has no RSVPs", async () => {
    mockDb.many.mockResolvedValue([]);

    const res = await request(app)
      .get("/getEventList")
      .query({ userID: 999999 }); // should have no RSVPs

    console.log(res.body.data.events[0]);
    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.events.length).toBe(0);
  });

  test("Filters events by location + radius", async () => {
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
      .query({
        location: "-122.5,37.5",
        radius: 35
      });
    const events = res.body.data.events;
    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(Array.isArray(events)).toBe(true);
    expect(events.length).toBeGreaterThan(0);
    // rough location boundary checks
    events.map(e => e.location.latitude).forEach(e => expect(e).toBeGreaterThan(37));
    events.map(e => e.location.latitude).forEach(e => expect(e).toBeLessThan(38));
    events.map(e => e.location.longitude).forEach(e => expect(e).toBeGreaterThan(-123));
    events.map(e => e.location.longitude).forEach(e => expect(e).toBeLessThan(-122));
  });

  test("Returns empty list if no events match location filter", async () => {
    mockDb.manyOrNone.mockResolvedValue([]);
    const res = await request(app)
      .get("/getEventList")
      .query({
        location: "-180, -90", // ocean
        radius: 1
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.events.length).toBe(0);
  });

  // -----------------------------------------------
  // 8. Combination filters
  // -----------------------------------------------
  test("Filters by location + datetime + cost + 21+", async () => {
    const res = await request(app)
      .get("/getEventList")
      .query({
        location: "-122.4194,37.7749",
        radius: 20,
        datetime: "2025-06-02T14:00:00",
        cost: 100,
        twentyoneplus: "false"
      });

    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data.events)).toBe(true);
  });


  // -----------------------------------------------
  // 9. Invalid query parameters
  // -----------------------------------------------
  test("Invalid location format should not crash server", async () => {
    const res = await request(app)
      .get("/getEventList")
      .query({ location: "bad-format" });

    // Since no valid filter = 400
    expect(res.statusCode).toBeGreaterThan(399);
  });


  test("Invalid datetime format should not crash server", async () => {
    const res = await request(app)
      .get("/getEventList")
      .query({ datetime: "not-a-date" });

    expect(res.statusCode).toBeGreaterThan(399);
  });


  // -----------------------------------------------
  // 10. Extremely large radius (should still work)
  // -----------------------------------------------
  test("Extremely large radius does not break filtering", async () => {
    const res = await request(app)
      .get("/getEventList")
      .query({
        location: "-122.4194,37.7749",
        radius: 1000000
      });

    expect(res.statusCode).toBe(200);
  });


  // -----------------------------------------------
  // 11. Ensure server handles DB errors gracefully
  // (cannot trigger reliably without mocking — optional)
  // -----------------------------------------------
  test("Handles DB errors gracefully (simulated bad query)", async () => {
    const res = await request(app)
      .get("/getEventList")
      .query({
        cost: "NOT_A_NUMBER"
      });

    expect([200, 403, 400]).toContain(res.statusCode);
  });

});
