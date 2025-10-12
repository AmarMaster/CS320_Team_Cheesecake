var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

// jwt authentication
const jwt = require("jsonwebtoken");

// PostgreSQL integration
const pgp = require('pg-promise')(/* options */)
const db = pgp('postgres://username:password@host:port/database')

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
      'SELECT * FROM users WHERE userID = {id}', {id: userID}, user => user.passENC
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


// Frontend requests map data
app.get('/getMap', (req, res) => {
  res.send("UMapper Web API.");
});

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

