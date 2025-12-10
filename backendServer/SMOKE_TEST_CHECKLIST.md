# Backend Smoke-Test Checklist

## 1. Auth Endpoints
### Login
- Happy path: Valid credentials → 200, returns token/user info
- Invalid payload: Missing password → 400, error message
- Wrong data type: Password as number → 400, error message
- Invalid credentials → 401, error message
- Large input: Long username/password → 400/401, no crash

### Register
- Happy path: Valid registration → 201, returns user info
- Missing required field (email) → 400, error message
- Invalid email format → 400, error message
- Existing username/email → 409, error message
- Large input: Long username/email → 400/409, no crash

---

## 2. Event Endpoints
### Create Event
- Happy path: Valid event data → 201, returns event info
- Missing required field (title/date) → 400, error message
- Wrong data type (date as string) → 400, error message
- Large input: Long title/description → 400/201, no crash

### List Events
- Happy path: Valid request → 200, returns event list
- Invalid filter param → 400, error message
- Large input: Unusual filter values → 400/200, no crash

### Get Event Detail
- Happy path: Valid event ID → 200, returns event info
- Non-existent event ID → 404, error message
- Invalid event ID format → 400, error message

### Update Event
- Happy path: Valid update → 200, returns updated event
- Missing required field → 400, error message
- Non-existent event ID → 404, error message
- Invalid event ID format → 400, error message

### Delete Event
- Happy path: Valid event ID → 200/204, event deleted
- Non-existent event ID → 404, error message
- Invalid event ID format → 400, error message

---

## 3. Slider Operations (Fav/RSVP/Hosted)
- Happy path: Valid operation → 200, returns updated info
- Invalid payload: Missing required field → 400, error message
- Non-existent event/user ID → 404, error message
- Invalid auth token → 401/403, error message

---

## 4. Filters Endpoint
- Happy path: Valid filter → 200, returns filtered events
- Invalid filter value → 400, error message
- Large/unexpected filter input → 400/200, no crash

---

## General
- All endpoints: Invalid/expired auth token → 401/403, error message
- All endpoints: Large/unexpected input → 400/200, no crash
- All endpoints: No 5xx errors/crashes for bad input

---

## Notes
- For each test, record status code and key response fields (error message, data, etc.).
- If any test fails (unexpected 5xx, crash, or unclear error), log the bug and link to ticket.
- Checklist should be re-run before demo.
