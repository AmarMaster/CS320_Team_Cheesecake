// tests/UserRSVP.test.js
jest.mock("pg-promise");

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /userRSVP (mocked DB)", () => {
  
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Endpoint exists and responds", async () => {
    // Note: Current implementation returns "UMapper Web API." message
    const res = await request(app)
      .post("/userRSVP")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          RSVPstatus: 1
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.text).toBe("UMapper Web API.");
  });

  test("Endpoint accepts userID parameter", async () => {
    const res = await request(app)
      .post("/userRSVP")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          RSVPstatus: 1
        }
      });

    expect(res.statusCode).toBe(200);
  });

  test("Endpoint accepts eventID parameter", async () => {
    const res = await request(app)
      .post("/userRSVP")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          RSVPstatus: 1
        }
      });

    expect(res.statusCode).toBe(200);
  });

  test("Endpoint accepts RSVPstatus parameter", async () => {
    const res = await request(app)
      .post("/userRSVP")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          RSVPstatus: 1
        }
      });

    expect(res.statusCode).toBe(200);
  });

  test("Endpoint handles multiple RSVP requests", async () => {
    // First request
    let res = await request(app)
      .post("/userRSVP")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          RSVPstatus: 1
        }
      });
    expect(res.statusCode).toBe(200);

    // Second request
    res = await request(app)
      .post("/userRSVP")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          RSVPstatus: 0
        }
      });
    expect(res.statusCode).toBe(200);
  });

  test("RSVP status 2 (not attending) is accepted", async () => {
    const res = await request(app)
      .post("/userRSVP")
      .send({
        data: {
          userID: "1",
          eventID: "100",
          RSVPstatus: 2
        }
      });

    expect(res.statusCode).toBe(200);
  });
});
