fs = require 'fs-extra'
mkdirp = require 'mkdirp'
ClonerFactory = require './products/ClonerFactory'
EventEmitter = (require 'events').EventEmitter
utils = require './utils'
rimraf = require 'rimraf'
mysql = require 'mysql2'
exec = (require 'child_process').exec

class Cloner extends EventEmitter

  constructor: (@vars, @config, @lp, @subdomain) ->

    @dest = "#{@config.env.destDir}/#{@subdomain}#{@config.env.domain}/public_html"
    @srcDir = "#{@config.env.srcDir}/#{@lp}/htdocs"

    EventEmitter.call @

  clone: (force) ->
    fs.exists @dest, (exists) =>
      if exists
        if not force
          utils.HandleError.call @, new Error('El dominio ya existe'), 'domain_exists', @subdomain
          return
        else
            rimraf @dest, (err) =>
              if err
                utils.HandleError.call @, err, 'rmmdir'
                return
              @dropDb (err) => 
                @createDir()
      else
        @createVirtualMinHost()
              

  createVirtualMinHost: () ->
    Product = ClonerFactory.getCloner @lp, @config, @vars, @subdomain, @dest
    fqdn = "#{@subdomain}#{@config.env.domain}"
    exec "virtualmin create-domain --domain #{fqdn} --parent cloner.cl.finderit.com --web --dns --dir --mysql --ftp", (err, stdout, stderr) =>
      if err
        utils.HandleError.call @, err, 'virtualmin create-host'
        return cb(err)

      fs.copy @srcDir, @dest, (err) =>
        console.log @dest
        if err
          utils.HandleError.call @, err, 'copy', @srcDir, @dest
          return 

        Product.compile()

        Product.on 'success', (domain) =>
          @_fixPerms Product, () =>
              @emit 'success', domain
        
        Product.on 'error', (err, type, args) =>
          @emit 'error', err, type, args

  dropDb: (callback) ->
    conn = mysql.createConnection 
      user: @config.env.db.user
      password: @config.env.db.password

    conn.execute "DROP DATABASE lp_#{@subdomain}", (err, res) ->
      conn.end -> 
        callback err

  _fixPerms: (product, cb) ->
    exec "chown cloner:#{@config.env.unix.httpGroup} -R #{product.baseDir}", (err, stdout, stderr) =>
      exec "chmod 775 -R #{product.baseDir}", (err, stdout, stderr) =>
      if err
        utils.HandleError.call @, err, 'chown_err'
      cb(err)

module.exports = Cloner