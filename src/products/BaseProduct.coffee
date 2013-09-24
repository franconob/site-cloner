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

    constructor: (@config, @vars, @subdomain, destDir) ->

        @vars = @vars || {}

        @baseDir = destDir
        @destDir = @_getPath @baseDir, 'htdocs'

        @srcDir = @config.env.srcDir
        @configFile = @config.configFile

        @domain = "#{@subdomain}#{@config.env.domain}"
        @dbName = "lp_#{@subdomain}"

        @origDbName = "lp_base_#{path.basename(@srcDir)}"

        @configFileVars =
            destDir: @destDir
            baseDir: @baseDir
            domain: @domain
            subdmain: @subdomain
            dbUser: @config.env.db.user
            dbName: @dbName
            dbPassword: @config.env.db.password

        @vars = _.extend @vars, @configFileVars

        EventEmitter.call @

    compile: (@conn) ->
        @compileDb =>
            @createDb =>
                @compileConfig =>
                    if EventEmitter.listenerCount @, 'compile.success'
                        @emit 'compile.success'
                    else
                        @emit 'success', @subdomain

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
            fs.copy dbFile, @destDir, (err) =>
                if err
                    utils.HandleError.call @, err, 'compiledb_copydb'
                    callback err
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

                    callback(err)

    createDb: (callback) ->
        dbName = "lp_#{@subdomain}"

        conn = @_connect()
        conn.query "CREATE DATABASE #{dbName} CHARACTER SET utf8 COLLATE utf8_general_ci", (err, result) =>
          if err
            utils.HandleError.call @, err, 'createdb', dbName
            return callback err

          @_mysqlCmd dbName, (@_getPath @destDir, BaseProduct.DBFILE), (err, stdout, stderr) =>
            if err
              utils.HandleError.call @, err, 'sourcedb', stderr
              return callback err

            conn.end (err) ->
              callback()

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