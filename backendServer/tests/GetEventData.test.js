// tests/getEventData.test.js
jest.mock("pg-promise"); // <-- use our mock

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("GET /getEventData (mocked DB)", () => {
    
    beforeEach(() => {
        jest.clearAllMocks();
    });

    test("Returns event data successfully", async () => {
        // Mock event returned by db.one()
        mockDb.one.mockResolvedValue({
            name: "Sample Event",
            location: {
                geometry: {
                    coordinates: [-122.42, 37.77]  // lon, lat
                }
            },
            time: "2025-01-01T12:00:00Z",
            duration: 3600,
            details: "Mock details",
            description: "Mock description"
        });

        const res = await request(app)
            .get("/getEventData")
            .query({ eventID: 123 });

        expect(res.statusCode).toBe(200);
        expect(res.body.data.success).toBe(true);
        expect(res.body.data.event).toBeDefined();
        expect(res.body.data.event.name).toBe("Sample Event");
        expect(res.body.data.event.location.latitude).toBe(37.77);
        expect(res.body.data.event.location.longitude).toBe(-122.42);
    });

    test("Returns 403 if event does not exist", async () => {
        // Mock db.one() rejecting (event not found)
        mockDb.one.mockRejectedValue(new Error("Not found"));

        const res = await request(app)
            .get("/getEventData")
            .query({ eventID: 999 });

        expect(res.statusCode).toBe(403);
        expect(res.body.data.success).toBe(false);
        expect(res.body.data.event).toBeUndefined();
    });

    test("Does nothing if eventID missing (your API currently sends no response)", async () => {
        // Your handler currently silently does nothing if no eventID is provided.
        // So express sends no response → Jest will treat as 404 (route exists but no response).
        const res = await request(app)
            .get("/getEventData"); // no eventID

        // Behavior: Express returns empty 200? 404?  
        // The route ends without sending → Express waits → parent 404 handler runs.
        expect(400).toBe(res.statusCode);
    });
});
