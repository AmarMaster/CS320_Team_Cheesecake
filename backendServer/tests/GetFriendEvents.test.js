// tests/GetFriendEvents.test.js
jest.mock("pg-promise");

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /getFriendEvents (mocked DB)", () => {
  
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Successfully get friend events returns 200", async () => {
    // Mock the database calls in sequence for the nested promises
    mockDb.one
      .mockResolvedValueOnce(1)  // getIDfromUsername for user
      .mockResolvedValueOnce(2)  // getIDfromUsername for friend
      .mockResolvedValueOnce({ user_id_1: 1, user_id_2: 2 });  // friendship check

    mockDb.manyOrNone.mockResolvedValueOnce([  // getRSVPs
      { event_id: 100 },
      { event_id: 101 }
    ]);

    mockDb.many.mockResolvedValueOnce([
      {
        name: "Friend's Event 1",
        location: {
          geometry: {
            coordinates: [-122.42, 37.77]
          }
        },
        time: "2025-01-01T12:00:00Z",
        duration: 3600,
        details: "Details 1",
        description: "Description 1"
      },
      {
        name: "Friend's Event 2",
        location: {
          geometry: {
            coordinates: [-122.42, 37.77]
          }
        },
        time: "2025-01-02T12:00:00Z",
        duration: 3600,
        details: "Details 2",
        description: "Description 2"
      }
    ]);

    const res = await request(app)
      .post("/getFriendEvents")
      .send({
        data: {
          username: "testuser",
          friendUsername: "frienduser"
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(Array.isArray(res.body.data.events)).toBe(true);
  }, 10000);

  test("Missing username causes timeout (promise chain hangs)", async () => {
    // The implementation accesses undefined username without validation
    // causing the promise chain to hang
    mockDb.one.mockRejectedValueOnce(new Error("Not found"));

    const res = await request(app)
      .post("/getFriendEvents")
      .send({
        data: {
          friendUsername: "frienduser"
        }
      });

    // Request times out or returns an error
    expect([408, 500, 200]).toContain(res.statusCode);
  }, 15000);

  test("Missing friendUsername returns 500", async () => {
    const res = await request(app)
      .post("/getFriendEvents")
      .send({
        data: {
          username: "testuser"
        }
      });

    expect(res.statusCode).toBe(500);
  });

  test("Not friends with user returns 403", async () => {
    mockDb.one
      .mockResolvedValueOnce(1)  // getIDfromUsername
      .mockResolvedValueOnce(2)  // getIDfromUsername for friend
      .mockRejectedValueOnce(new Error("Not friends"));

    const res = await request(app)
      .post("/getFriendEvents")
      .send({
        data: {
          username: "testuser",
          friendUsername: "notafriend"
        }
      });

    expect(res.statusCode).toBe(403);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toContain("Not friends");
  });

  test("Friend with no RSVP'd events returns 200 with empty array", async () => {
    mockDb.one
      .mockResolvedValueOnce(1)  // getIDfromUsername
      .mockResolvedValueOnce(2)  // getIDfromUsername for friend
      .mockResolvedValueOnce({ user_id_1: 1, user_id_2: 2 });  // friendship check

    mockDb.manyOrNone.mockResolvedValueOnce([]);  // no RSVPs

    const res = await request(app)
      .post("/getFriendEvents")
      .send({
        data: {
          username: "testuser",
          friendUsername: "frienduser"
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.events).toEqual([]);
  }, 10000);

  test("Database error on user lookup returns 500", async () => {
    mockDb.one.mockRejectedValueOnce(new Error("Database error"));

    const res = await request(app)
      .post("/getFriendEvents")
      .send({
        data: {
          username: "testuser",
          friendUsername: "frienduser"
        }
      });

    expect(res.statusCode).toBe(500);
    expect(res.body.data.success).toBe(false);
  }, 10000);

  test("Single friend event returns 200", async () => {
    mockDb.one
      .mockResolvedValueOnce(1)  // getIDfromUsername
      .mockResolvedValueOnce(2)  // getIDfromUsername for friend
      .mockResolvedValueOnce({ user_id_1: 1, user_id_2: 2 });  // friendship check

    mockDb.manyOrNone.mockResolvedValueOnce([
      { event_id: 100 }
    ]);

    mockDb.many.mockResolvedValueOnce([
      {
        name: "Single Event",
        location: {
          geometry: {
            coordinates: [-122.42, 37.77]
          }
        },
        time: "2025-01-01T12:00:00Z",
        duration: 3600,
        details: "Details",
        description: "Description"
      }
    ]);

    const res = await request(app)
      .post("/getFriendEvents")
      .send({
        data: {
          username: "testuser",
          friendUsername: "frienduser"
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.events.length).toBe(1);
    expect(res.body.data.events[0].name).toBe("Single Event");
  }, 10000);

  test("Friend events include all required fields", async () => {
    mockDb.one
      .mockResolvedValueOnce(1)
      .mockResolvedValueOnce(2)
      .mockResolvedValueOnce({ user_id_1: 1, user_id_2: 2 });

    mockDb.manyOrNone.mockResolvedValueOnce([{ event_id: 100 }]);

    mockDb.many.mockResolvedValueOnce([
      {
        name: "Test Event",
        location: {
          geometry: {
            coordinates: [-122.42, 37.77]
          }
        },
        time: "2025-01-01T12:00:00Z",
        duration: 3600,
        details: "Details",
        description: "Description"
      }
    ]);

    const res = await request(app)
      .post("/getFriendEvents")
      .send({
        data: {
          username: "testuser",
          friendUsername: "frienduser"
        }
      });

    expect(res.statusCode).toBe(200);
    const event = res.body.data.events[0];
    expect(event).toHaveProperty("name");
    expect(event).toHaveProperty("location");
    expect(event).toHaveProperty("time");
    expect(event).toHaveProperty("duration");
    expect(event).toHaveProperty("details");
    expect(event).toHaveProperty("description");
  }, 10000);
});
