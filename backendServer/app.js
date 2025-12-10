var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

// jwt authentication
const jwt = require("jsonwebtoken");

// PostgreSQL integration
const db = require('./db.js');
 
const getIDfromUsername = (username) => {
  return db.one(
    'SELECT * FROM users WHERE username = {username}', {username: username}, user => user.id   
  )
}
const getUsernamefromID = (id) => {
  return db.one(
    'SELECT * FROM users WHERE id = {id}', {id: id}, user => user.username   
  )
}

// Import routes
var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');
var eventsRouter = require('./routes/events');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
// Compatibility shim: some handlers expect req['data'] instead of req.body
app.use((req, res, next) => {
  if (!req.data) req.data = req.body && Object.keys(req.body).length ? req.body.data || req.body : undefined;
  next();
});
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));


// Random title page, not an API endpoint.
app.get('/', (req, res) => {
  res.send("UMapper Web API.");
});


// Recieve login form data in json format
// Process this data, send success if successful
app.post('/login', async (req, res) => {
  // Defensive: check for req.body and req.body.data
  if (!req.body || !req.body.data) {
    return res.status(401).send({ data: { success: false, message: "Missing login data.", jwt: '' } });
  }
  const { username, password } = req.body.data;
  if (!username || !password) {
    return res.status(401).send({ data: { success: false, message: "Missing username or password.", jwt: '' } });
  }
  try {
    // Get the user ID from username
    const userId = await db.one('SELECT id FROM users WHERE username = {username}', { username: username });
    // Get the stored password to compare
    const storedPassword = await db.one('SELECT password FROM users WHERE username = {username}', { username: username });
    // Validate password
    if (!storedPassword || storedPassword !== password) {
      return res.status(401).send({ data: { success: false, message: "Incorrect Username or Password.", jwt: '' } });
    }
    // Generate jwt auth token
    const token = jwt.sign({ userId: userId }, "secretKey", { expiresIn: "2h" });
    return res.status(200).send({ data: { success: true, message: "Logged In.", jwt: token } });
  } catch (err) {
    // user not found or db error
    return res.status(401).send({ data: { success: false, message: "Incorrect Username or Password.", jwt: '' } });
  }
});

// create an account, adds data to db and generates userID and jwt token if successful
app.post('/createAccount', async (req, res) => {
  // Defensive: check for req.body and req.body.data
  if (!req.body || !req.body.data) {
    return res.status(400).send({ data: { success: false, message: "Missing registration data.", jwt: '' } });
  }
  const { name, password, email } = req.body.data;
  if (!name || !password || !email) {
    return res.status(400).send({ data: { success: false, message: "Missing name, password, or email.", jwt: '' } });
  }
  // Simple email format validation
  const emailRegex = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).send({ data: { success: false, message: "Invalid email format.", jwt: '' } });
  }
  // Large input check (arbitrary: >100 chars for name/email)
  if (name.length > 100 || email.length > 100) {
    return res.status(400).send({ data: { success: false, message: "Name or email too long.", jwt: '' } });
  }
  // Password validation: at least 8 characters and at least one digit
  if (password.length < 8) {
    return res.status(400).send({ data: { success: false, message: "Password must be at least 8 characters long.", jwt: '' } });
  }
  const digitRegex = /\d/;
  if (!digitRegex.test(password)) {
    return res.status(400).send({ data: { success: false, message: "Password must contain at least one digit.", jwt: '' } });
  }
  try {
    // Check if user/email already exists
    const existing = await db.many('SELECT * FROM users WHERE username = {name} OR email = {email}', { name, email });
    if (existing && existing.length > 0) {
      return res.status(403).send({ data: { success: false, message: "Username or email already taken.", jwt: '' } });
    }
    // Add user to db
    await db.none('INSERT INTO Users (name, password, email) VALUES ({name}, {pass}, {email});', { name, pass: password, email });
    // Retrieve the user id for the new account
    const user = await db.one('SELECT * FROM users WHERE username = {name}', { name });
    // Generate jwt auth token
    const token = jwt.sign({ userId: user.id }, "secretKey", { expiresIn: "2h" });
    return res.status(200).send({ data: { success: true, message: "Account Created.", jwt: token } });
  } catch (err) {
    console.error('Register error:', err);
    // DB error or other error
    return res.status(500).send({ data: { success: false, message: "Failed to create account.", jwt: '' } });
  }
});

// Frontend requests data for a single event
// /getEventData?eventId={String}
app.get('/getEventData', (req, res) => {
  /*
  headers = {
    auth: String
  }

  res = {
    data: {
      success: Boolean,
      event: Event,
    }
  }

  Event = {
        name: String,
        location: {
            latitude: Float,
            longitude: Float
          },
        time: "YYYY-MM-DDTHH:MM:SS",
        duration: Integer,
        details: String,
        description: String
      }
  */
  const eid = req.query.eventID
  if (!eid){
    res.status(400).send({data:{success: false, event: undefined}}); // do nothing if no eventID provided
    return;
  }
  db.one( // get the event
    'SELECT * FROM events WHERE id = {id}', {id: eid}
  ).then( event => {
      res.status(200).send(
        {data:
          {success: true, event: 
            { 
              'name': event.name, 
              'location': {
                'latitude': event.location["geometry"]["coordinates"][1],
                'longitude': event.location["geometry"]["coordinates"][0]
              },
              'time': new Date(event.time).toISOString(),
              'duration': event.duration,
              'details': event.details,
              'description': event.description
            }
          }
        }
      );
      return;
    }
  ).catch( _ => {
      res.locals.message = `No event found with id: ${eid}.`;
      res.status(403).send({data:{success: false, event: undefined}});
      return;
    }
  );
});

// Frontend requests data for many events cooresponding to certain filters
// filters: userID (for account page events that user has RSVP'd to), location, date, time, 21+, cost 
// if SS in datetime is 11, sort only by date, otherwise sort by date and time
// location=<longitude>,<latitude>    radius also has to be set in miles
// if userID is set, it overrides any other filters and get the users RSVP
// /getEventList?userID=userID&location=FLOAT,FLOAT&radius=FLOAT&datetime=YYYY-MM-DDTHH:MM:SS&twentyoneplus=BOOLEAN&cost=FLOAT
app.get('/getEventList', (req, res) => {
  /*
  headers = {
    auth: String
  }

  res = {
    data: {
      success: Boolean,
      events: [Event]
    }
  }
  
  Event = {
        name: String,
        location: {
            latitude: Float,
            longitude: Float
          },
        time: "YYYY-MM-DDTHH:MM:SS",
        duration: Integer,
        details: String,
        description: String
      }
  */
  const uid = req.query.userID;

  let latitude = null;
  let longitude = null;
  let radius = null;
  let datetime = null;
  let dateOnly = null;
  let twentyoneplus = null;
  let cost = null;

  if (req.query.location && req.query.radius) {
    const locParts = req.query.location.split(',');   // [longitude, latitude]
    longitude = parseFloat(locParts[0]);
    latitude = parseFloat(locParts[1]);
    radius = parseFloat(req.query.radius) * 1609.34;  // convert miles → meters
  }

  if (req.query.datetime && Date.parse(req.query.datetime)) {
    datetime = new Date(req.query.datetime);
    const seconds = datetime.getSeconds();
    dateOnly = (seconds === 11);        // your “date-only” flag hack
    datetime = datetime.toISOString();
  }

  if (req.query.twentyoneplus) {
    twentyoneplus = (req.query.twentyoneplus.toLowerCase() === 'true');
  }

  if (req.query.cost) {
    cost = parseFloat(req.query.cost);
  }

  // ------------------------------------------------------------
  // No filters provided → reject.
  // ------------------------------------------------------------
  if (!uid && !latitude && !datetime && twentyoneplus === null) {
    res.locals.message = `No valid filters provided.`;
    res.status(400).send({ data: { success: false, events: undefined } });
    return;
  }

  // =====================================================================
  // USER RSVP MODE (takes priority)
  // =====================================================================
  if (uid) {

    try {
      db.manyOrNone(
        'SELECT event_id FROM rsvps WHERE user_id = $1',
        [uid]
      ).then(ids => {
        console.log("RSVP event IDs:", ids);
        if (ids.length === 0) {
          res.status(200).send({ data: { success: true, events: [] } });
          return;
        }
        db.many(
          `SELECT * FROM events WHERE id = ANY($1::int[])`,
          [ids]
        ).then(events => {
          const res_events = events.map(event => ({
            name: event.name,
            location: {
              latitude: event.location.geometry.coordinates[1],
              longitude: event.location.geometry.coordinates[0]
            },
            time: new Date(event.time).toISOString(),
            duration: event.duration,
            details: event.details,
            description: event.description
          }));
          res.status(200).send({ data: { success: true, events: res_events } });
          return;
        });
      });
    } catch (e) {
      res.locals.message = `Error getting RSVP events for user_id: ${uid}.`;
      res.status(403).send({ data: { success: false, events: undefined } });
      return;
    }
  } else {

  // =====================================================================
  // FILTER MODE
  // =====================================================================

    let sql = `
      SELECT 
        name,
        ST_Y(location) AS latitude,
        ST_X(location) AS longitude,
        time,
        duration,
        details,
        description
      FROM events
      WHERE 1=1
    `;
    const params = [];
    let p = 1;

    if (latitude !== null) {
      sql += ` AND ST_DWithin(location, ST_MakePoint($${p++}, $${p++})::geography, $${p++})`;
      params.push(longitude, latitude, radius);
    }

    if (dateOnly) {
      sql += ` AND date_trunc('day', time) = $${p++}`;
      params.push(datetime.slice(0, 10));
    } else if (datetime) {
      sql += ` AND time <= $${p++} AND (time + duration * interval '1 second') >= $${p++}`;
      params.push(datetime, datetime);
    }

    if (twentyoneplus !== null) {
      sql += ` AND twentyoneplus = $${p++}`;
      params.push(twentyoneplus);
    }

    if (cost !== null) {
      sql += ` AND cost <= $${p++}`;
      params.push(cost);
    }

    try {
      db.manyOrNone(sql, params).then(events => {
        return events.map(event => ({
          name: event.name,
          location: {
            latitude: event.latitude,
            longitude: event.longitude
          },
          time: new Date(event.time).toISOString(),
          duration: event.duration,
          details: event.details,
          description: event.description
        }));
      }).then(res_events => {
        res.status(200).send({ data: { success: true, events: res_events } });
        return;
      });
    } catch (e) {
      res.locals.message = `Error getting events with provided filters.`;
      console.log(e);
      res.status(403).send({ data: { success: false, events: undefined } });
      return;
    }

  }
});


// User creates event, returns the created event
app.post('/createEvent', (req, res) => {
  /*
  req = {
    data: {
      userID: String
      event: Event
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      event: Event
    }
  }
  
  Event = {
        name: String,
        location: {
            latitude: Float,
            longitude: Float
          },
        time: "YYYY-MM-DDTHH:MM:SS",
        duration: Integer,
        details: String,
        description: String
      }
  */

  db.one(
    'INSERT INTO events (name, location, time, duration, details, description, owner_id) VALUES ({name}, ST_SetSRID(ST_MakePoint({longitude}, {latitude}), 4326), {time}, {duration}, {details}, {description}, {owner_id}); ',
    {
      name: req['data']['event']['name'],
      longitude: req['data']['event']['location']['longitude'],
      latitude: req['data']['event']['location']['latitude'],
      time: req['data']['event']['time'],
      duration: req['data']['event']['duration'],
      details: req['data']['event']['details'],
      description: req['data']['event']['description'],
      owner_id: req['data']['userID']
    }
  ).then( _ => {
      res.status(200).send({data:{success: true, event: req['data']['event']}});
      return;
    }
  ).catch( _ => {
      res.locals.message = `Error creating event.`;
      res.status(403).send({data:{success: false, event: undefined}});
      return;
    }
  );
});

// User edits or delete event, returns the updated event
app.post('/changeEvent', (req, res) => {
  /*
  req = {
    data: {
      userID: String
      eventID: String
      event: Event
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      event: Event
    }
  }
  
  Event = {
        name: String,
        location: {
            latitude: Float,
            longitude: Float
          },
        time: "YYYY-MM-DDTHH:MM:SS",
        duration: Integer,
        details: String,
        description: String
      }
  */

  db.none("UPDATE events SET name = {name}, location = ST_SetSRID(ST_MakePoint({longitude}, {latitude}), 4326), time = {time}, duration = {duration}, details = {details}, description = {description} WHERE id = {event_id} AND owner_id = {owner_id}; ",
    {
      name: req['data']['event']['name'],
      longitude: req['data']['event']['location']['longitude'],
      latitude: req['data']['event']['location']['latitude'],
      time: req['data']['event']['time'],
      duration: req['data']['event']['duration'],
      details: req['data']['event']['details'],
      description: req['data']['event']['description'],
      event_id: req['data']['eventID'],
      owner_id: req['data']['userID']
    }
  ).then( _ => {
      res.status(200).send({data:{success: true, event: req['data']['event']}});
      return;
    }
  ).catch( _ => {
      res.locals.message = `Error updating event.`;
      res.status(403).send({data:{success: false, event: undefined}});
      return;
    }
  );
});

// User RSVPs/changes RSVP to event
app.post('/userRSVP', (req, res) => {
  /*
  req = {
    data: {
      userID = String
      eventID = String
      RSVPstatus = Int
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      RSVPstatus: Int
    }
  }
  
  RSVPstatus:
    0 = no RSVP
    1 = attending
    2 = not attending
    ...
  */
  res.send("UMapper Web API.");
});

// User deletes/removes an event
// /deleteEvent?eventID={String}
app.post('/deleteEvent', (req, res) => {
  /*
  req = {
    data: {
      userID: String
      eventID: String
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      message: String
    }
  }
  */
  const eventID = req['data']['eventID'];
  const userID = req['data']['userID'];

  if (!eventID || !userID) {
    return res.status(400).send({ data: { success: false, message: "Missing eventID or userID." } });
  }

  // First check if event exists and user is the owner
  db.one(
    'SELECT owner_id FROM events WHERE id = {id}',
    { id: eventID }
  ).then(event => {
    if (event.owner_id !== userID) {
      return res.status(403).send({ data: { success: false, message: "You are not authorized to delete this event." } });
    }

    // Delete the event
    db.none(
      'DELETE FROM events WHERE id = {id}',
      { id: eventID }
    ).then(() => {
      res.status(200).send({ data: { success: true, message: "Event deleted successfully." } });
    }).catch(err => {
      res.status(500).send({ data: { success: false, message: "Failed to delete event." } });
    });
  }).catch(err => {
    res.status(404).send({ data: { success: false, message: "Event not found." } });
  });
});

// User toggles event as favorite
// /toggleFavorite?eventID={String}
app.post('/toggleFavorite', (req, res) => {
  /*
  req = {
    data: {
      userID: String
      eventID: String
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      message: String,
      data: {
        eventId: String,
        userId: String
      }
    }
  }
  */
  const eventID = req['data']['eventID'];
  const userID = req['data']['userID'];

  if (!eventID || !userID) {
    return res.status(400).send({ data: { success: false, message: "Missing eventID or userID." } });
  }

  // Check if event exists
  db.oneOrNone(
    'SELECT id FROM events WHERE id = {id}',
    { id: eventID }
  ).then(event => {
    if (!event) {
      return res.status(404).send({ data: { success: false, message: "Event not found." } });
    }
    // Toggle logic - just return success for now (real implementation would check favorites table)
    res.status(200).send({ 
      data: { 
        success: true, 
        message: "Favorite toggled.",
        data: { eventId: eventID, userId: userID }
      } 
    });
  }).catch(err => {
    res.status(500).send({ data: { success: false, message: "Server error." } });
  });
});

// User toggles RSVP status
// /toggleRSVP?eventID={String}
app.post('/toggleRSVP', (req, res) => {
  /*
  req = {
    data: {
      userID: String
      eventID: String
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      message: String,
      data: {
        eventId: String,
        userId: String
      }
    }
  }
  */
  const eventID = req['data']['eventID'];
  const userID = req['data']['userID'];

  if (!eventID || !userID) {
    return res.status(400).send({ data: { success: false, message: "Missing eventID or userID." } });
  }

  // Check if event exists
  db.oneOrNone(
    'SELECT id FROM events WHERE id = {id}',
    { id: eventID }
  ).then(event => {
    if (!event) {
      return res.status(404).send({ data: { success: false, message: "Event not found." } });
    }
    // Toggle logic - just return success for now (real implementation would check/update rsvps table)
    res.status(200).send({ 
      data: { 
        success: true, 
        message: "RSVP toggled.",
        data: { eventId: eventID, userId: userID }
      } 
    });
  }).catch(err => {
    res.status(500).send({ data: { success: false, message: "Server error." } });
  });
});

// User toggles hosted status
// /toggleHosted?eventID={String}
app.post('/toggleHosted', (req, res) => {
  /*
  req = {
    data: {
      userID: String
      eventID: String
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      message: String,
      data: {
        eventId: String,
        userId: String
      }
    }
  }
  */
  const eventID = req['data']['eventID'];
  const userID = req['data']['userID'];

  if (!eventID || !userID) {
    return res.status(400).send({ data: { success: false, message: "Missing eventID or userID." } });
  }

  // Check if event exists
  db.oneOrNone(
    'SELECT id FROM events WHERE id = {id}',
    { id: eventID }
  ).then(event => {
    if (!event) {
      return res.status(404).send({ data: { success: false, message: "Event not found." } });
    }
    // Toggle logic - just return success for now (real implementation would check/update hosted table)
    res.status(200).send({ 
      data: { 
        success: true, 
        message: "Hosted toggled.",
        data: { eventId: eventID, userId: userID }
      } 
    });
  }).catch(err => {
    res.status(500).send({ data: { success: false, message: "Server error." } });
  });
});


// User changes password
app.post('/changePassword', (req, res) => {
  /*
  req = {
    data: {
      username = String
      password = String
      newPassword = String
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      message: String
    }
  }
  */

  const userName = req['data']['username'];
  const userPass = req['data']['password'];
  const newPass = req['data']['newPassword'];
  db.one(
    'SELECT * FROM users WHERE username = {username}', {username: userName}, user => user.password   
  ).then( gotPass => {
    if (gotPass === userPass){
      db.none('UPDATE users SET password = {newPassword} WHERE username = {username}', {newPassword: newPass, username: userName})
      .then( _ => res.status(200).send({data:{success: true, message: "Password updated."}}));
    } else {
      res.status(403).send({data:{success: false, message: "Incorrect password."}});
    }
  }).catch(_ => res.status(500).send({data:{success: false, message: "Internal server error."}}));
});

// User deletes account
app.post('/deleteAccount', (req, res) => {
  /*
  req = {
    data: {
      username = String
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      message: String
    }
  }
  */

  userName = req['data']['username'];
  const gotPass = db.none(
    'Delete * FROM users WHERE username = {username}', {username: userName}
  ).catch(_ => {res.status(500).send({data:{success: false, message: "Internal server error."}}); return;})

  res.status(200).send({data:{success: true, message: "Account deleted."}}); 
  return;
});


// User adds a friend
app.post('/addFriend', (req, res) => {
  /*
  req = {
    data: {
      username = String
      friendUsername = String
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      message: String
    }
  }
  */

  const userName = req.data && req.data.username;
  const friendUsername = req.data && req.data.friendUsername;

  if (!userName || !friendUsername) {
    res.status(400).send({ data: { success: false, message: "Missing parameters." } });
    return;
  }

  Promise.all([getIDfromUsername(userName), getIDfromUsername(friendUsername)])
    .then(([userId, friendId]) => {
      return db.none(
        'INSERT INTO friendships (user_id_1, user_id_2, status, created_at) VALUES ({user_id_1}, {user_id_2}, {status}, {created_at}); ',
        { user_id_1: userId, user_id_2: friendId, status: 'accepted', created_at: new Date() }
      );
    })
    .then(() => {
      res.status(200).send({ data: { success: true, message: "Friend added." } });
    })
    .catch(_ => {
      res.status(500).send({ data: { success: false, message: "Internal server error." } });
    });
});

// User removes a friend
app.post('/removeFriend', (req, res) => {
  /*
  req = {
    data: {
      username = String,
      friendUsername = String
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      message: String
    }
  }
  */

  const userName = req.data && req.data.username;
  const friendUsername = req.data && req.data.friendUsername;
  db.none(
    'DELETE FROM friendships WHERE (user_id_1 = {user_id_1} AND user_id_2 = {user_id_2}) OR (user_id_1 = {user_id_2} AND user_id_2 = {user_id_1}); ',
    { user_id_1: userName, user_id_2: friendUsername }
  )
    .then(() => {
      res.status(200).send({ data: { success: true, message: "Friend removed." } });
    })
    .catch(_ => {
      res.status(500).send({ data: { success: false, message: "Internal server error." } });
    });
});

// User gets the list of their friends
app.post('/getAllFriends', (req, res) => {
  /*
  req = {
    data: {
      username = String
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      message: String,
      friends: [String]
    }
  }
  */

  const userName = req['data']['username'];
  getIDfromUsername(userName)
  .then(userID => {
    db.manyOrNone('SELECT * FROM friendships WHERE user_id_1 = {user_id_1} OR user_id_2 = {user_id_1}; ', {user_id_1: userID})
    .then( gotPass => {
      const friendList = gotPass.map( f => {
        if (f.user_id_1 === userID){
          return f.user_id_2;
        } else {
          return f.user_id_1;
        }
      });
      Promise.all(friendList.map(id => getUsernamefromID(id)))
      .then( friendUsernames => 
        res.status(200).send({data:{success: true, message: "Friends retrieved.", friends: friendUsernames}})
      );
    });
  })
  .catch(_ => res.status(500).send({data:{success: false, message: "Internal server error."}}))
});

// User gets all events a friend has RSVP'd to
app.post('/getFriendEvents', (req, res) => {
  /*
  req = {
    data: {
      username = String
      friendUsername = String
    }
    auth: {
      jwt: String
    }
  }

  res = {
    data: {
      success: Boolean,
      events: [Event]
    }
  }
  
  Event = {
        name: String,
        location: {
            latitude: Float,
            longitude: Float
          },
        time: "YYYY-MM-DDTHH:MM:SS",
        duration: Integer,
        details: String,
        description: String
      }
  */

  const userName = req['data']['username'];
  const friendUsername = req['data']['friendUsername'];
  getIDfromUsername(userName)
  .then( userID => {
    getIDfromUsername(friendUsername).then( friendID => {
      db.one(
        'SELECT FROM friendships WHERE (user_id_1 = {user_id_1} AND user_id_2 = {user_id_2}) OR (user_id_1 = {user_id_2} AND user_id_2 = {user_id_1}); ', {user_id_1: userName, user_id_2: friendUsername}
      ).then( _ => {
        db.manyOrNone(
          'SELECT event_id FROM rsvps WHERE user_id = $1',
          [friendID]
        ).then( rsvps => {
          const ids = rsvps.map(r => r.event_id);
          if (ids.length === 0) {
            res.status(200).send({ data: { success: true, events: [] } });
            return;
          }
          db.many(
            `SELECT * FROM events WHERE id = ANY($1::int[])`,
            [ids]
          ).then(events => {
            const res_events = events.map(event => ({
              name: event.name,
              location: {
                latitude: event.location.geometry.coordinates[1],
                longitude: event.location.geometry.coordinates[0]
              },
              time: new Date(event.time).toISOString(),
              duration: event.duration,
              details: event.details,
              description: event.description
            }));
            res.status(200).send({ data: { success: true, events: res_events } });
            return;
          });
        });
      }).catch( _ => res.status(403).send({data:{success: false, message: "Not friends with user."}}) );
    });
  })
  .catch(_ => res.status(500).send({data:{success: false, message: "Internal server error."}}));
});


// API Routes
app.use('/api/events', eventsRouter);
app.use('/', indexRouter);
app.use('/users', usersRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
