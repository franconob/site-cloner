###
  Module dependencies
###

express = require 'express'
routes = require './routes/clone'
http = require 'http'
path = require 'path'
swig = require 'swig'

app = express()

# All environments
app.set 'port', process.env.PORT or 3000
app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'html'
app.engine 'html', swig.renderFile
app.use express.favicon()
app.use express.logger 'dev'
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser 'newellls'
app.use express.session()
app.use app.router
app.use express.static path.join __dirname, 'public'

# Development only
app.use express.errorHandler() if app.get 'env' is 'development'

app.post '/clone/:landingPage/:domain', routes.clone
app.get '/catalog', routes.catalog
app.get '/public', routes.public

server = http.createServer app
server.listen (app.get 'port'), ->
  console.log "Express server listening on port #{app.get 'port'}"

server.on 'connection', (socket) ->
 	socket.setKeepAlive true