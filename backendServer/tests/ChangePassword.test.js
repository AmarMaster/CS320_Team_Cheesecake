// tests/ChangePassword.test.js
jest.mock("pg-promise");

const request = require("supertest");
const app = require("../app");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("POST /changePassword (mocked DB)", () => {
  
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("Successfully change password returns 200", async () => {
    mockDb.one.mockResolvedValue("oldpassword");
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/changePassword")
      .send({
        data: {
          username: "testuser",
          password: "oldpassword",
          newPassword: "newpassword123"
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
    expect(res.body.data.message).toBe("Password updated.");
  });

  test("Missing username causes DB error returns 500", async () => {
    mockDb.one.mockRejectedValue(new Error("User not found"));

    const res = await request(app)
      .post("/changePassword")
      .send({
        data: {
          password: "oldpassword",
          newPassword: "newpassword123"
        }
      });

    // DB error in lookup
    expect(res.statusCode).toBe(500);
  });

  test("Missing current password returns 403 (undefined != password)", async () => {
    mockDb.one.mockResolvedValue("correctpassword");

    const res = await request(app)
      .post("/changePassword")
      .send({
        data: {
          username: "testuser",
          newPassword: "newpassword123"
        }
      });

    expect(res.statusCode).toBe(403);
    expect(res.body.data.success).toBe(false);
  });

  test("Missing new password returns 200 (no validation)", async () => {
    mockDb.one.mockResolvedValue("oldpassword");
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/changePassword")
      .send({
        data: {
          username: "testuser",
          password: "oldpassword"
        }
      });

    expect(res.statusCode).toBe(200);
  });

  test("Incorrect current password returns 403", async () => {
    mockDb.one.mockResolvedValue("correctpassword");

    const res = await request(app)
      .post("/changePassword")
      .send({
        data: {
          username: "testuser",
          password: "wrongpassword",
          newPassword: "newpassword123"
        }
      });

    expect(res.statusCode).toBe(403);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toBe("Incorrect password.");
  });

  test("Database error returns 500", async () => {
    mockDb.one.mockRejectedValue(new Error("Database error"));

    const res = await request(app)
      .post("/changePassword")
      .send({
        data: {
          username: "testuser",
          password: "oldpassword",
          newPassword: "newpassword123"
        }
      });

    expect(res.statusCode).toBe(500);
    expect(res.body.data.success).toBe(false);
    expect(res.body.data.message).toBe("Internal server error.");
  });

  test("Update password query is called with correct parameters", async () => {
    mockDb.one.mockResolvedValue("correctpassword");
    mockDb.none.mockResolvedValue(undefined);

    await request(app)
      .post("/changePassword")
      .send({
        data: {
          username: "testuser",
          password: "correctpassword",
          newPassword: "newpassword123"
        }
      });

    expect(mockDb.none).toHaveBeenCalledWith(
      expect.stringContaining("UPDATE users SET password"),
      expect.objectContaining({
        newPassword: "newpassword123",
        username: "testuser"
      })
    );
  });

  test("User can change password with valid inputs", async () => {
    mockDb.one.mockResolvedValue("oldpass123");
    mockDb.none.mockResolvedValue(undefined);

    const res = await request(app)
      .post("/changePassword")
      .send({
        data: {
          username: "john_doe",
          password: "oldpass123",
          newPassword: "newpass456"
        }
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.success).toBe(true);
  });
});
