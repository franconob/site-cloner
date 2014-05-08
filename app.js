// Generated by CoffeeScript 1.7.1

/*
  Module dependencies
 */

(function() {
  var app, express, http, path, routes, server, swig;

  express = require('express');

  routes = require('./routes/clone');

  http = require('http');

  path = require('path');

  swig = require('swig');

  app = express();

  app.set('port', process.env.PORT || 3000);

  app.set('views', "" + __dirname + "/views");

  app.set('view engine', 'html');

  app.engine('html', swig.renderFile);

  app.use(express.favicon());

  app.use(express.logger('dev'));

  app.use(express.bodyParser());

  app.use(express.methodOverride());

  app.use(express.cookieParser('newellls'));

  app.use(express.session());

  app.use(app.router);

  app.use(express["static"](path.join(__dirname, 'public')));

  if (app.get('env' === 'development')) {
    app.use(express.errorHandler());
  }

  app.post('/clone/:landingPage/:domain', routes.clone);

  app.get('/catalog', routes.catalog);

  app.get('/public', routes["public"]);

  server = http.createServer(app);

  server.listen(app.get('port'), function() {
    return console.log("Express server listening on port " + (app.get('port')));
  });

  server.on('connection', function(socket) {
    return socket.setKeepAlive(true);
  });

}).call(this);

//# sourceMappingURL=app.map
