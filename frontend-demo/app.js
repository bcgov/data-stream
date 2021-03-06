var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
//var bodyParser = require('body-parser');

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');
var writeRouter = require('./routes/write_file');
var testRouter = require('./routes/test_connection');
var subscribeRouter = require('./routes/subscribe');
var notifyRouter = require('./routes/notify');
var testNotifyRouter = require('./routes/test_notify');
var onLoadRouter = require('./routes/on_load');
var unsubscribeRouter = require('./routes/unsubscribe');

var app = express();
app.locals.env = process.env;
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', usersRouter);
app.use('/write_file', writeRouter);
app.use('/test_connection', testRouter);
app.use('/subscribe', subscribeRouter);
app.use('/notify', notifyRouter);
app.use('/test_notify', testNotifyRouter);
app.use('/on_load', onLoadRouter);
app.use('/unsubscribe', unsubscribeRouter);

//app.use(bodyParser({limit: '500Mb'}));
var websockets = require('./public/javascripts/web_socket');
var wss = websockets.init();

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
