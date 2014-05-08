hogan = require 'hogan.js'
mysql = require 'mysql2'
exec = (require 'child_process').exec
EventEmitter = (require 'events').EventEmitter
utils = require '../utils'
fs = require 'fs-extra'
_ = require 'underscore'
path = require 'path'

class BaseProduct extends EventEmitter

  @DBFILE: 'db.sql'

  constructor: (@config, @vars, @subdomain, @landingpage, destDir) ->
    @vars = @vars || {}
    @dbname = "#{@subdomain}_cl_finderit_com"

    @baseDir = destDir
    @destDir = @_getPath @baseDir, 'public_html'

    @srcDir = "#{@config.env.srcDir}/#{@landingpage}"
    @configFile = @config.configFile

    @fqdn = "#{@subdomain}#{@config.env.domain}"
    @dbName = "#{@subdomain}_cl_finderit_com"

    @origDbName = "lp_base_#{path.basename(@srcDir)}"

    @configFileVars =
      destDir: @destDir
      baseDir: @baseDir
      domain: @fqdn
      subdomain: @subdomain
      dbUser: @config.env.db.user
      dbName: @dbName
      dbPassword: @config.env.db.password

    @vars = _.extend {}, @vars, @configFileVars

    EventEmitter.call @

  compile: () ->
    @compileDb =>
      @createDb =>
        @compileConfig =>
          if EventEmitter.listenerCount @, 'compile.success'
            @emit 'compile.success'
          else
            @emit 'success', @fqdn

  compileConfig: (callback) ->
    config = @_getPath @destDir, @configFile

    fs.readFile (@_getPath (@_getPath @srcDir, 'htdocs'), "#{@configFile}.tpl"), encoding: 'utf8', (err, data) =>
      if err
        utils.HandleError.call @, err, 'compileconfig_read'
        return callback err

      template = hogan.compile data

      fs.writeFile config, (template.render @configFileVars), (err) =>
        if err
          utils.HandleError.call @, err, 'compileconfig_write'
          return callback err
        callback()

  compileDb: (callback) ->
    dbFile = (@_getPath @srcDir, "htdocs", BaseProduct.DBFILE)
    @_mysqlDump @origDbName, dbFile, (err, stdout, stderr) =>
      if err
        utils.HandleError.call @, err, 'compiledb_dump'
        return callback err
      fs.copy dbFile, (@_getPath @destDir, BaseProduct.DBFILE), (err) =>
        if err
          utils.HandleError.call @, err, 'compiledb_copydb'
          return callback err
        fs.readFile (@_getPath @destDir, BaseProduct.DBFILE), encoding: 'utf8', (err, data) =>
          if err
            utils.HandleError.call @, err, 'compiledb_read'
            return callback err

          template = hogan.compile data
          @dbCompiled = template.render @vars

          fs.writeFile (@_getPath @destDir, BaseProduct.DBFILE), @dbCompiled, (err) =>
          if err
            utils.HandleError.call @, err, 'compiledb_write'
            return callback err

          return callback(err)

  createDb: (callback) ->
    @_mysqlCmd @dbName, (@_getPath @destDir, BaseProduct.DBFILE), (err, stdout, stderr) =>
      conn.end (err) ->
      if err
        utils.HandleError.call @, err, 'sourcedb', stderr
        return callback err
      return callback()
      """
        conn = @_connect()
        conn.query "CREATE DATABASE #{@dbName} CHARACTER SET utf8 COLLATE utf8_general_ci", (err, result) =>
          if err
            utils.HandleError.call @, err, 'createdb', @dbName
            return callback err

        """

  _getPath: (dir, path...) ->
    path.unshift dir
    path.join '/'

  _mysqlCmd: (db, file, callback) ->
    exec "mysql -u#{@config.env.db.user} -p#{@config.env.db.password} #{db} < #{file}", callback

  _mysqlDump: (db, file, callback) ->
    exec "mysqldump -u#{@config.env.db.user} -p#{@config.env.db.password} #{db} > #{file}", callback

  _connect: (options = {}) ->
    config =
      user: @config.env.db.user
      password: @config.env.db.password
      multipleStatements: true

    mysql.createConnection (_.extend config, options)


module.exports = BaseProduct