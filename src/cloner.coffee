fs = require 'fs-extra'
mkdirp = require 'mkdirp'
hogan = require 'hogan.js'
mysql = require 'mysql2'
exec = (require 'child_process').exec

class Cloner
  constructor: (@vars, @srcDir, @destDir, @lp, @domain) ->

    @baseSQL = "db.sql"
    @dbCompiled = null

  clone: (@callback) ->

    @dest = "#{@destDir}/#{@domain}"

    mkdirp @dest, (err) =>
      throw err if err

      fs.copy @srcDir, @dest, (err) =>
        throw err if err

        @_compileDb =>
          @_createDb =>
            @callback()

  _connect: (options = {}) ->

    config =
      user: 'root'
      password: 'echesortufc'
      multipleStatements: true

    @conn = mysql.createConnection config

  _createDb: (callback) ->

    dbName = "lp_#{@domain}"

    @_connect()
    @conn.query "CREATE DATABASE #{dbName} CHARACTER SET utf8 COLLATE utf8_general_ci", (err, result) =>
      throw err if err

      @_mysqlCmd dbName, "#{@dest}/#{@baseSQL}", (err, stdout, stderr) =>
        throw err if err
        console.log stdout
        console.log stderr

        @conn.end (err) ->
          callback()

  _compileDb: (callback) ->
    fs.readFile "#{@srcDir}/#{@baseSQL}", encoding: 'utf8', (err, data) =>
      template = hogan.compile data
      @dbCompiled = template.render @vars

      fs.writeFile "#{@dest}/#{@baseSQL}", @dbCompiled, (err) =>
        throw err if err
        callback()

  _mysqlCmd: (db, file, callback) ->
    exec "mysql -uroot -pechesortufc #{db} < #{file}", callback

module.exports = Cloner



