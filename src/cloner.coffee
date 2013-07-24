fs = require 'fs-extra'
mkdirp = require 'mkdirp'
hogan = require 'hogan.js'
mysql = require 'mysql2'
exec = (require 'child_process').exec

class Cloner
  constructor: (@vars, @config, @lp, @domain) ->

    @baseSQL = "db.sql"
    @dbCompiled = null

  clone: (@callback) ->

    @dest = "#{@config.destDir}/#{@domain}/htdocs"

    mkdirp @dest, (err) =>
      throw err if err

      fs.copy @config.srcDir, @dest, (err) =>
        throw err if err

        @_compileDb =>
          @_createDb =>
            @_compileConfig =>
              @callback()

  _connect: (options = {}) ->

    config =
      user: @config.db.user
      password: @config.db.password
      multipleStatements: true

    @conn = mysql.createConnection config

  _createDb: (callback) ->

    dbName = "lp_#{@domain}"

    @_connect()
    @conn.query "CREATE DATABASE #{dbName} CHARACTER SET utf8 COLLATE utf8_general_ci", (err, result) =>
      throw err if err

      @_mysqlCmd dbName, "#{@dest}/#{@baseSQL}", (err, stdout, stderr) =>
        throw err if err

        @conn.end (err) ->
          callback()

  _compileDb: (callback) ->
    fs.readFile "#{@dest}/#{@baseSQL}", encoding: 'utf8', (err, data) =>
      template = hogan.compile data
      @dbCompiled = template.render @vars

      fs.writeFile "#{@dest}/#{@baseSQL}", @dbCompiled, (err) =>
        throw err if err
        callback()

  _compileConfig: (callback) ->
    config = "#{@dest}/#{@config.all.configFile}"

    fs.readFile "#{@config.srcDir}/#{@config.all.configFile}", encoding: 'utf8', (err, data) =>
      throw err if err
      template = hogan.compile data

      # TODO: configurar las variables del archivo de conf en config.coffee

      vars =
        dbUser: @config.db.user
        dbName: "lp_#{@domain}"
        dbPassword: @config.db.password

      fs.writeFile config, (template.render vars), (err) =>
        throw err if err
        callback()

  _mysqlCmd: (db, file, callback) ->
    exec "mysql -u#{@config.db.user} -p#{@config.db.password} #{db} < #{file}", callback

module.exports = Cloner



