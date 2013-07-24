fs = require 'fs-extra'
mkdirp = require 'mkdirp'
hogan = require 'hogan.js'
mysql = require 'mysql2'
exec = (require 'child_process').exec
EventEmitter = (require 'events').EventEmitter

class Cloner extends EventEmitter
  constructor: (@vars, @config, @lp, @subdomain) ->

    EventEmitter.call @

    @baseSQL = "db.sql"
    @dbCompiled = null

  clone: (@callback = null) ->

    @dest = "#{@config.destDir}/#{@subdomain}/htdocs"

    mkdirp @dest, (err) =>
      if err
        @_handleError err, 'mkdir', @dest
        return callback err

      fs.copy @config.srcDir, @dest, (err) =>
        if err
          @_handleError err, 'copy', @config.srcDir, @dest
          return callback err

        @_compileDb =>
          @_createDb =>
            @_compileConfig =>
              @emit 'success', @subdomain

  _connect: (options = {}) ->

    config =
      user: @config.db.user
      password: @config.db.password
      multipleStatements: true

    @conn = mysql.createConnection config

  _createDb: (callback) ->

    dbName = "lp_#{@subdomain}"

    @_connect()
    @conn.query "CREATE DATABASE #{dbName} CHARACTER SET utf8 COLLATE utf8_general_ci", (err, result) =>
      if err
        @_handleError err, 'createdb', dbName
        return callback err

      @_mysqlCmd dbName, "#{@dest}/#{@baseSQL}", (err, stdout, stderr) =>
        if err
          @_handleError err, 'sourcedb', stderr
          return callback err

        @conn.end (err) ->
          callback()

  _compileDb: (callback) ->
    fs.readFile "#{@dest}/#{@baseSQL}", encoding: 'utf8', (err, data) =>

      if err
        @_handleError err, 'compiledb_read'
        return callback err

      template = hogan.compile data
      @dbCompiled = template.render @vars

      fs.writeFile "#{@dest}/#{@baseSQL}", @dbCompiled, (err) =>
        if err
          @_handleError err, 'compiledb_write'
          return callback err
        callback()

  _compileConfig: (callback) ->
    config = "#{@dest}/#{@config.all.configFile}"

    fs.readFile "#{@config.srcDir}/#{@config.all.configFile}", encoding: 'utf8', (err, data) =>

      if err
        @_handleError err, 'compileconfig_read'
        return callback err

      template = hogan.compile data

      # TODO: configurar las variables del archivo de conf en config.coffee

      vars =
        dbUser: @config.db.user
        dbName: "lp_#{@subdomain}"
        dbPassword: @config.db.password

      fs.writeFile config, (template.render vars), (err) =>
        if err
          @_handleError err, 'compileconfig_write'
          return callback err
        callback()

  _mysqlCmd: (db, file, callback) ->
    exec "mysql -u#{@config.db.user} -p#{@config.db.password} #{db} < #{file}", callback

  _handleError: (err, type, args...) ->
    @emit 'error', err, type, args: args


module.exports = Cloner



