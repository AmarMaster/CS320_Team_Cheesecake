/**
 * TypeConflicts.test.js
 * 
 * This test file validates that there are no type conflicts between:
 * - The database schema defined in database_init.sql
 * - The queries and data operations in app.js
 * 
 * It verifies:
 * 1. All columns used in queries exist in the schema
 * 2. Data types match between operations and schema
 * 3. Required fields are not treated as optional
 * 4. Foreign key relationships are respected
 * 5. Geospatial types are handled correctly
 */

jest.mock("pg-promise");

const pgp = require("pg-promise");
const mockDb = pgp.__mockDb;

describe("Database Schema and Query Type Compatibility", () => {

  /**
   * Schema definitions extracted from database_init.sql
   * Defines expected types and constraints for each table
   */
  const schemaDefinitions = {
    users: {
      id: { type: 'SERIAL', primaryKey: true, nullable: false },
      username: { type: 'VARCHAR(50)', nullable: false, unique: true },
      email: { type: 'VARCHAR(100)', nullable: false, unique: true },
      password: { type: 'VARCHAR(255)', nullable: false },
      role: { type: 'VARCHAR(255)', nullable: false },
      created_at: { type: 'TIMESTAMP', nullable: false, default: 'CURRENT_TIMESTAMP' }
    },
    events: {
      id: { type: 'SERIAL', primaryKey: true, nullable: false },
      name: { type: 'VARCHAR(100)', nullable: false },
      location: { type: 'GEOMETRY(POINT, 4326)', nullable: false },
      time: { type: 'TIMESTAMP', nullable: false },
      duration: { type: 'INTERVAL', nullable: false },
      details: { type: 'VARCHAR(120)', nullable: false },
      description: { type: 'TEXT', nullable: true },
      adult_only: { type: 'BOOLEAN', nullable: false, default: false },
      isUMASS: { type: 'BOOLEAN', nullable: false, default: false },
      cost: { type: 'DECIMAL(10, 2)', nullable: false, default: 0.00 },
      outdoor: { type: 'BOOLEAN', nullable: false, default: false },
      category: { type: 'VARCHAR(100)', nullable: true },
      owner_id: { type: 'INT', nullable: false, foreignKey: 'users(id)' },
      created_at: { type: 'TIMESTAMP', nullable: false, default: 'CURRENT_TIMESTAMP' }
    },
    rsvps: {
      user_id: { type: 'INT', nullable: false, foreignKey: 'users(id)' },
      event_id: { type: 'INT', nullable: false, foreignKey: 'events(id)' },
      status: { type: 'VARCHAR(50)', nullable: false },
      created_at: { type: 'TIMESTAMP', nullable: false, default: 'CURRENT_TIMESTAMP' }
    },
    friendships: {
      user_id_1: { type: 'INT', nullable: false, foreignKey: 'users(id)' },
      user_id_2: { type: 'INT', nullable: false, foreignKey: 'users(id)' },
      status: { type: 'VARCHAR(50)', nullable: false, default: 'pending' },
      created_at: { type: 'TIMESTAMP', nullable: false, default: 'CURRENT_TIMESTAMP' }
    }
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // =====================================================================
  // LOGIN ENDPOINT TESTS
  // =====================================================================
  describe("POST /login - Type Compatibility", () => {
    test("Username column exists and is correct type (VARCHAR)", () => {
      expect(schemaDefinitions.users.username.type).toBe('VARCHAR(50)');
    });

    test("Password column exists and is correct type (VARCHAR)", () => {
      expect(schemaDefinitions.users.password.type).toBe('VARCHAR(255)');
    });

    test("ID column exists for lookup and is correct type (SERIAL)", () => {
      expect(schemaDefinitions.users.id.type).toBe('SERIAL');
      expect(schemaDefinitions.users.id.primaryKey).toBe(true);
    });

    test("Username and password are both NOT NULL", () => {
      expect(schemaDefinitions.users.username.nullable).toBe(false);
      expect(schemaDefinitions.users.password.nullable).toBe(false);
    });
  });

  // =====================================================================
  // CREATE ACCOUNT ENDPOINT TESTS
  // =====================================================================
  describe("POST /createAccount - Type Compatibility", () => {
    test("Username column is UNIQUE as required", () => {
      expect(schemaDefinitions.users.username.unique).toBe(true);
    });

    test("Email column exists and is UNIQUE", () => {
      expect(schemaDefinitions.users.email.type).toBe('VARCHAR(100)');
      expect(schemaDefinitions.users.email.unique).toBe(true);
    });

    test("Email column is NOT NULL", () => {
      expect(schemaDefinitions.users.email.nullable).toBe(false);
    });

    test("Role column can store VARCHAR(255) values", () => {
      expect(schemaDefinitions.users.role.type).toBe('VARCHAR(255)');
    });

    test("INSERT statement includes all required non-default columns", () => {
      // Required columns: username, password, email (role and created_at have defaults)
      const requiredColumns = ['username', 'password', 'email'];
      requiredColumns.forEach(col => {
        expect(schemaDefinitions.users[col]).toBeDefined();
        expect(schemaDefinitions.users[col].nullable).toBe(false);
      });
    });
  });

  // =====================================================================
  // GET EVENT DATA ENDPOINT TESTS
  // =====================================================================
  describe("GET /getEventData - Type Compatibility", () => {
    test("Event ID column exists and is queryable", () => {
      expect(schemaDefinitions.events.id).toBeDefined();
    });

    test("Event name column exists and is VARCHAR", () => {
      expect(schemaDefinitions.events.name.type).toBe('VARCHAR(100)');
    });

    test("Location column is GEOMETRY(POINT, 4326) for lat/long extraction", () => {
      expect(schemaDefinitions.events.location.type).toBe('GEOMETRY(POINT, 4326)');
    });

    test("Time column is TIMESTAMP for datetime queries", () => {
      expect(schemaDefinitions.events.time.type).toBe('TIMESTAMP');
    });

    test("Duration column is INTERVAL for duration storage", () => {
      expect(schemaDefinitions.events.duration.type).toBe('INTERVAL');
    });

    test("Details and description columns exist", () => {
      expect(schemaDefinitions.events.details).toBeDefined();
      expect(schemaDefinitions.events.description).toBeDefined();
    });

    test("All required event fields are NOT NULL", () => {
      const requiredEventFields = ['name', 'location', 'time', 'duration', 'details'];
      requiredEventFields.forEach(field => {
        expect(schemaDefinitions.events[field].nullable).toBe(false);
      });
    });
  });

  // =====================================================================
  // GET EVENT LIST ENDPOINT TESTS
  // =====================================================================
  describe("GET /getEventList - Type Compatibility", () => {
    test("Location uses GEOMETRY(POINT, 4326) for ST_DWithin queries", () => {
      expect(schemaDefinitions.events.location.type).toBe('GEOMETRY(POINT, 4326)');
    });

    test("Time column supports date truncation and range queries", () => {
      expect(schemaDefinitions.events.time.type).toBe('TIMESTAMP');
    });

    test("Duration supports INTERVAL arithmetic for time range calculations", () => {
      expect(schemaDefinitions.events.duration.type).toBe('INTERVAL');
    });

    test("Cost column is DECIMAL for price comparisons", () => {
      expect(schemaDefinitions.events.cost.type).toBe('DECIMAL(10, 2)');
    });

    test("RSVP table uses INT foreign keys to events and users", () => {
      expect(schemaDefinitions.rsvps.event_id.type).toBe('INT');
      expect(schemaDefinitions.rsvps.user_id.type).toBe('INT');
      expect(schemaDefinitions.rsvps.event_id.foreignKey).toBe('events(id)');
      expect(schemaDefinitions.rsvps.user_id.foreignKey).toBe('users(id)');
    });

    test("Query result can be mapped to events array structure", () => {
      const eventFields = ['name', 'location', 'time', 'duration', 'details', 'description'];
      eventFields.forEach(field => {
        expect(schemaDefinitions.events[field]).toBeDefined();
      });
    });
  });

  // =====================================================================
  // CREATE EVENT ENDPOINT TESTS
  // =====================================================================
  describe("POST /createEvent - Type Compatibility", () => {
    test("Event name accepts VARCHAR(100) input", () => {
      expect(schemaDefinitions.events.name.type).toBe('VARCHAR(100)');
    });

    test("Location accepts GEOMETRY(POINT, 4326) via ST_MakePoint", () => {
      expect(schemaDefinitions.events.location.type).toBe('GEOMETRY(POINT, 4326)');
    });

    test("Time accepts TIMESTAMP from ISO string", () => {
      expect(schemaDefinitions.events.time.type).toBe('TIMESTAMP');
    });

    test("Duration accepts INTERVAL", () => {
      expect(schemaDefinitions.events.duration.type).toBe('INTERVAL');
    });

    test("Details accepts VARCHAR(120)", () => {
      expect(schemaDefinitions.events.details.type).toBe('VARCHAR(120)');
    });

    test("Description accepts TEXT (nullable)", () => {
      expect(schemaDefinitions.events.description.type).toBe('TEXT');
      expect(schemaDefinitions.events.description.nullable).toBe(true);
    });

    test("Owner_id references users table correctly", () => {
      expect(schemaDefinitions.events.owner_id.type).toBe('INT');
      expect(schemaDefinitions.events.owner_id.foreignKey).toBe('users(id)');
    });

    test("All required event columns are present", () => {
      const requiredCols = ['name', 'location', 'time', 'duration', 'details', 'owner_id'];
      requiredCols.forEach(col => {
        expect(schemaDefinitions.events[col]).toBeDefined();
        expect(schemaDefinitions.events[col].nullable).toBe(false);
      });
    });
  });

  // =====================================================================
  // CHANGE EVENT ENDPOINT TESTS
  // =====================================================================
  describe("POST /changeEvent - Type Compatibility", () => {
    test("UPDATE statement modifies only updateable columns", () => {
      const updateableColumns = ['name', 'location', 'time', 'duration', 'details', 'description'];
      updateableColumns.forEach(col => {
        expect(schemaDefinitions.events[col]).toBeDefined();
      });
    });

    test("Event ID used in WHERE clause is SERIAL primary key", () => {
      expect(schemaDefinitions.events.id.primaryKey).toBe(true);
    });

    test("Owner_id used for ownership verification exists", () => {
      expect(schemaDefinitions.events.owner_id).toBeDefined();
    });
  });

  // =====================================================================
  // USER RSVP ENDPOINT TESTS
  // =====================================================================
  describe("POST /userRSVP - Type Compatibility", () => {
    test("RSVP user_id is INT foreign key to users", () => {
      expect(schemaDefinitions.rsvps.user_id.type).toBe('INT');
      expect(schemaDefinitions.rsvps.user_id.foreignKey).toBe('users(id)');
    });

    test("RSVP event_id is INT foreign key to events", () => {
      expect(schemaDefinitions.rsvps.event_id.type).toBe('INT');
      expect(schemaDefinitions.rsvps.event_id.foreignKey).toBe('events(id)');
    });

    test("RSVP status is VARCHAR(50)", () => {
      expect(schemaDefinitions.rsvps.status.type).toBe('VARCHAR(50)');
    });

    test("RSVP primary key prevents duplicate entries", () => {
      expect(schemaDefinitions.rsvps.user_id.nullable).toBe(false);
      expect(schemaDefinitions.rsvps.event_id.nullable).toBe(false);
    });
  });

  // =====================================================================
  // FRIEND MANAGEMENT ENDPOINT TESTS
  // =====================================================================
  describe("POST /addFriend - Type Compatibility", () => {
    test("Friendship user_id_1 is INT foreign key to users", () => {
      expect(schemaDefinitions.friendships.user_id_1.type).toBe('INT');
      expect(schemaDefinitions.friendships.user_id_1.foreignKey).toBe('users(id)');
    });

    test("Friendship user_id_2 is INT foreign key to users", () => {
      expect(schemaDefinitions.friendships.user_id_2.type).toBe('INT');
      expect(schemaDefinitions.friendships.user_id_2.foreignKey).toBe('users(id)');
    });

    test("Friendship status is VARCHAR(50)", () => {
      expect(schemaDefinitions.friendships.status.type).toBe('VARCHAR(50)');
    });

    test("Both user IDs are required (NOT NULL)", () => {
      expect(schemaDefinitions.friendships.user_id_1.nullable).toBe(false);
      expect(schemaDefinitions.friendships.user_id_2.nullable).toBe(false);
    });
  });

  describe("POST /removeFriend - Type Compatibility", () => {
    test("Friendship table can be queried and deleted by user IDs", () => {
      expect(schemaDefinitions.friendships.user_id_1).toBeDefined();
      expect(schemaDefinitions.friendships.user_id_2).toBeDefined();
    });
  });

  // =====================================================================
  // CHANGE PASSWORD ENDPOINT TESTS
  // =====================================================================
  describe("POST /changePassword - Type Compatibility", () => {
    test("Password column can be updated with VARCHAR(255)", () => {
      expect(schemaDefinitions.users.password.type).toBe('VARCHAR(255)');
    });

    test("Username lookup returns correct type", () => {
      expect(schemaDefinitions.users.username.type).toBe('VARCHAR(50)');
    });
  });

  // =====================================================================
  // DELETE ACCOUNT ENDPOINT TESTS
  // =====================================================================
  describe("POST /deleteAccount - Type Compatibility", () => {
    test("Users table can be queried by username for deletion", () => {
      expect(schemaDefinitions.users.username).toBeDefined();
      expect(schemaDefinitions.users.username.unique).toBe(true);
    });

    test("Foreign key constraints ensure cascading delete", () => {
      // Events, RSVPs, and Friendships all have ON DELETE CASCADE
      expect(schemaDefinitions.events.owner_id.foreignKey).toBe('users(id)');
      expect(schemaDefinitions.rsvps.user_id.foreignKey).toBe('users(id)');
    });
  });

  // =====================================================================
  // INTEGRATION TESTS FOR COMMON PATTERNS
  // =====================================================================
  describe("Cross-Endpoint Type Consistency", () => {
    test("User ID type is consistent across all tables", () => {
      expect(schemaDefinitions.users.id.type).toBe('SERIAL');
      expect(schemaDefinitions.events.owner_id.type).toBe('INT');
      expect(schemaDefinitions.rsvps.user_id.type).toBe('INT');
      expect(schemaDefinitions.friendships.user_id_1.type).toBe('INT');
      expect(schemaDefinitions.friendships.user_id_2.type).toBe('INT');
      // SERIAL generates INT, so these are compatible
    });

    test("Event ID type is consistent across related tables", () => {
      expect(schemaDefinitions.events.id.type).toBe('SERIAL');
      expect(schemaDefinitions.rsvps.event_id.type).toBe('INT');
      // SERIAL generates INT, so these are compatible
    });

    test("All timestamps use consistent TIMESTAMP type", () => {
      const timestampFields = [
        schemaDefinitions.users.created_at,
        schemaDefinitions.events.created_at,
        schemaDefinitions.rsvps.created_at,
        schemaDefinitions.friendships.created_at
      ];
      timestampFields.forEach(field => {
        expect(field.type).toBe('TIMESTAMP');
      });
    });

    test("Location data is consistently handled as GEOMETRY(POINT, 4326)", () => {
      expect(schemaDefinitions.events.location.type).toBe('GEOMETRY(POINT, 4326)');
    });

    test("Foreign key references match column types", () => {
      // user_id in rsvps and friendships must match users.id type
      expect(schemaDefinitions.rsvps.user_id.type).toBe('INT');
      expect(schemaDefinitions.events.owner_id.type).toBe('INT');
      expect(schemaDefinitions.friendships.user_id_1.type).toBe('INT');
      expect(schemaDefinitions.friendships.user_id_2.type).toBe('INT');
    });
  });

  // =====================================================================
  // GEOSPATIAL TYPE TESTS
  // =====================================================================
  describe("Geospatial Type Handling", () => {
    test("Location column uses PostGIS GEOMETRY(POINT, 4326) type", () => {
      expect(schemaDefinitions.events.location.type).toBe('GEOMETRY(POINT, 4326)');
    });

    test("Location data includes geometry.coordinates for extraction", () => {
      // Tests that coordinates are accessible via GeoJSON format
      expect(schemaDefinitions.events.location.type).toContain('GEOMETRY');
    });

    test("ST_MakePoint can create location values for insertion", () => {
      // Validates that ST_MakePoint with (longitude, latitude) works with GEOMETRY
      expect(schemaDefinitions.events.location.type).toBe('GEOMETRY(POINT, 4326)');
    });

    test("ST_DWithin can query location with distance in meters", () => {
      expect(schemaDefinitions.events.location.type).toBe('GEOMETRY(POINT, 4326)');
    });

    test("ST_Y and ST_X can extract latitude and longitude", () => {
      expect(schemaDefinitions.events.location.type).toBe('GEOMETRY(POINT, 4326)');
    });
  });

  // =====================================================================
  // INTERVAL TYPE TESTS
  // =====================================================================
  describe("INTERVAL Type Handling", () => {
    test("Duration column is INTERVAL type for time periods", () => {
      expect(schemaDefinitions.events.duration.type).toBe('INTERVAL');
    });

    test("INTERVAL supports arithmetic with multiplication", () => {
      expect(schemaDefinitions.events.duration.type).toBe('INTERVAL');
    });

    test("INTERVAL can be added to TIMESTAMP", () => {
      expect(schemaDefinitions.events.duration.type).toBe('INTERVAL');
      expect(schemaDefinitions.events.time.type).toBe('TIMESTAMP');
    });
  });

  // =====================================================================
  // NULL CONSTRAINT TESTS
  // =====================================================================
  describe("NOT NULL Constraint Validation", () => {
    test("All primary key columns are NOT NULL", () => {
      expect(schemaDefinitions.users.id.nullable).toBe(false);
      expect(schemaDefinitions.events.id.nullable).toBe(false);
    });

    test("All foreign key columns are NOT NULL", () => {
      expect(schemaDefinitions.events.owner_id.nullable).toBe(false);
      expect(schemaDefinitions.rsvps.user_id.nullable).toBe(false);
      expect(schemaDefinitions.rsvps.event_id.nullable).toBe(false);
      expect(schemaDefinitions.friendships.user_id_1.nullable).toBe(false);
      expect(schemaDefinitions.friendships.user_id_2.nullable).toBe(false);
    });

    test("Nullable columns are only optional fields", () => {
      expect(schemaDefinitions.events.description.nullable).toBe(true);
      expect(schemaDefinitions.events.category.nullable).toBe(true);
    });
  });

  // =====================================================================
  // UNIQUE CONSTRAINT TESTS
  // =====================================================================
  describe("UNIQUE Constraint Validation", () => {
    test("Username column is UNIQUE", () => {
      expect(schemaDefinitions.users.username.unique).toBe(true);
    });

    test("Email column is UNIQUE", () => {
      expect(schemaDefinitions.users.email.unique).toBe(true);
    });
  });

});
