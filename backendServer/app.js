var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

// jwt authentication
const jwt = require("jsonwebtoken");

// PostgreSQL integration
const pgp = require('pg-promise')(/* options */)
const db = require('./db.js');

// Import routes
var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');
var eventsRouter = require('./routes/events');

const port = 3000;
var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));


// Random title page, not an API endpoint.
app.get('/', (req, res) => {
  res.send("UMapper Web API.");
});


// Recieve login form data in json format
// Process this data, send success if successful
app.post('/login', (req, res) => {
  // req = {
  //         data: {
  //           userID: String,
  //           password: String,
  //         }
  //       }

  // res = {
  //   data: {
  //     success: Boolean,
  //     message: String,
  //     jwt: String,
  //   }
  // }

  success = true;
  userID = req['data']['userID'];
  userPass = req['data']['password'];
  db.one( // get the encrypted password to compare to validate user
      'SELECT * FROM users WHERE userID = {id}', {id: userID}, user => user.password
    ) 
    .then(
      pass => { // user is found
        if (userPass !== pass){ // password is incorrect
          res.locals.message = `Incorrect Password for user with ID: ${userID}`
          success = false;
        }
        success = true ? userPass == pass : false;
      }, 
      _ => { // no user is found
        res.locals.message = `No user found with ID: ${userID}`; 
        success = false
      }
    );
  
  if (!success){
    res.status(401).send({data:{success: false, message: "Incorrect Username or Password.", jwt: ''}});
    return;
  }

  // Generate jwt auth token
  const token = jwt.sign({ userId: req['data']['userID'] }, "secretKey", { expiresIn: "2h" });
  
  res.status(200).send({data:{success: true, message: "Logged In.", jwt: token}});
});

// create an account, adds data to db and generates userID and jwt token if successful
app.post('/createAccount', (req, res) => {
  // req = {
  //         data: {
  //           name: String,
  //           password: String,
  //           email: String,
  //         }
  //       }

  // res = {
  //   data: {
  //     success: Boolean,
  //     message: String,
  //     jwt: String,
  //   }
  // }

  userName = req['data']['name'];
  userPass = req['data']['password'];
  userEmail = req['data']['email'];
  db.many( // make sure no account already exists with that email
      'SELECT * FROM users WHERE username = {name}', {name: userName}
    )
    .then(
      pass => { // user is found (bad)
        res.locals.message = `Username already taken.`;
        res.status(403).send({data:{success: false, message: "Username already taken.", userID: '', jwt: ''}});
        return;
      },
      _ => { // no user is found (good)
        // generate new random id
        // add user to db
        db.none('INSERT INTO Users (name, password, email) VALUES ({name}, {pass}, {email}); ', {name: userName, pass: userPass, email: userEmail})
        // Generate jwt auth token
        const token = jwt.sign({ userId: req['data']['userID'] }, "secretKey", { expiresIn: "2h" });
        res.status(200).send({data:{success: true, message: "Account Created.", jwt: token}});
      }
    );
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
  eid = req.query.eventID
  if (eid){
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
    )
  }
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
  if (res.query.location && res.query.radius){
    const location = req.query.location.split(','); // [longitude, latitude]
    const latitude = parseFloat(location[0]);
    const longitude = parseFloat(location[1]);
    const radius = parseInt(req.query.radius);
  } else {
    const location = null;
    const latitude = null;
    const longitude = null;
    const radius = null;
  }
  if (req.query.datetime && Date.parse(req.query.datetime)){
    const datetime = new Date(req.query.datetime).toISOString();
    const dateOnly = datetime.slice(17,19) === '11'; // if seconds are 11, only filter by date
  } else {
    const datetime = null;
    const dateOnly = null;
  }
  if (req.query.twentyoneplus){
    const twentyoneplus = req.query.twentyoneplus.toLowerCase() === 'true';
  } else {
    const twentyoneplus = null;
  }
  if (req.query.cost){
    const cost = parseFloat(req.query.cost);
  } else {
    const cost = null;
  }

  if(!uid && !location && !datetime && !twentyoneplus){
    res.locals.message = `No valid filters provided.`;
        res.status(400).send({data:{success: false, events: undefined}});
        return;
  } else if (uid){ // this is all the user's rsvp'd events, it's separate from the other filters (takes priority)
    db.manyOrNone( // get the event
      'SELECT * FROM rsvps WHERE user_id = {id}', {id: eid}, rsvp => rsvp.event_id
    ).then( event_ids => {
        db.many(`SELECT * FROM events WHERE id IN ({id_list})`, {id_list: event_ids.join(', ')}).then(
          events => {
            res_events = [];
            events.forEach(event => res_events.push({ 
                'name': event.name, 
                'location': {
                  'latitude': event.location["geometry"]["coordinates"][1],
                  'longitude': event.location["geometry"]["coordinates"][0]
                },
                'time': new Date(event.time).toISOString(), 
                'duration': event.duration, 
                'details': event.details, 
                'description': event.description
              }));
            res.status(200).send({data:{success: true, events: res_events}});
            return;
          }
        )
      }
    ).catch( _ => {
        res.locals.message = `Error getting all events with an rsvp from user_id: ${uid}.`;
        res.status(403).send({data:{success: false, events: undefined}});
        return;
      }
    )
  } else {
    /* TODO: need to figure out what valid filter values are.
        eg. 1mile, 5miles, 10miles, ... for location.
            Values for date and time that give the user good filtering options.
        We should decide whether these should be continuous or discreet values.
    */
    var query = `SELECT * FROM events WHERE 1=1`; // 1=1 is a dummy condition to make appending easier
    if (location) {query = query.concat('AND ST_DWithin(location, ST_MakePoint($1, $2), $3)', longitude, latitude, radius);} // event is within radius miles of location
    if (dateOnly) {query = query.concat("AND date_trunc('day', time) = '$1'", datetime.slice(0, 10));}  // event is on that date
    else if (datetime) {query = query.concat("AND time <= '$1' AND time + duration >= '$2'", datetime, datetime);} // event is happening at that time
    if (twentyoneplus !== null) {
      if (twentyoneplus) {query = query.concat("AND twentyoneplus = true");} // event is 21+
      else {query = query.concat("AND twentyoneplus = false");} // event is not 21+
    } 
    if (cost !== null) {query = query.concat("AND cost <= $1", cost);} // event is under the cost
    db.manyOrNone( // get the event
      query
    ).then( events => {
        res_events = [];
        events.forEach(event => res_events.push({ 
            'name': event.name, 
            'location': {
              'latitude': event.location["geometry"]["coordinates"][1],
              'longitude': event.location["geometry"]["coordinates"][0]
            },
            'time': new Date(event.time).toISOString(), 
            'duration': event.duration, 
            'details': event.details, 
            'description': event.description
          }));
        res.status(200).send({data:{success: true, events: res_events}});
        return;
      }
    ).catch( _ => {
        res.locals.message = `Error getting events with provided filters.`;
        res.status(403).send({data:{success: false, events: undefined}});
        return;
      }
    )
  }
});

// User creates event, returns the created event
app.post('/createEvent', (req, res) => {
  /*
  req = {
    data: {
      userID = String
      event = Event
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
      userID = String
      eventID = String
      event = Event
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

app.listen(port, () => {
  console.log(`EventMapper backend listening on port ${port}`)
})

module.exports = app;
