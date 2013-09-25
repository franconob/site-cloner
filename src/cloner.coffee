fs = require 'fs-extra'
mkdirp = require 'mkdirp'
ClonerFactory = require './products/ClonerFactory'
EventEmitter = (require 'events').EventEmitter
utils = require './utils'

class Cloner extends EventEmitter

  @instance = null

  @create: (vars, config, lp, subdomain) ->
    if Cloner.instance is null
      return Cloner.instance = new Cloner vars, config, lp, subdomain
    else
      return Cloner.instance
  
  constructor: (@vars, @config, @lp, @subdomain) ->

    @dest = "#{@config.env.destDir}/#{@subdomain}"
    @config.env.srcDir = "#{@config.env.srcDir}/#{@lp}"

    EventEmitter.call @

  clone: () ->

    fs.exists @dest, (exists) =>
      if exists
        utils.HandleError.call @, new Error('El dominio ya existe'), 'domain_exists', @subdomain
        return
      else
        Product = ClonerFactory.getCloner @lp, @config, @vars, @subdomain, @dest

        mkdirp @dest, (err) =>
          if err
            utils.HandleError.call @, err, 'mkdir', @dest
            return 

          fs.copy @config.env.srcDir, @dest, (err) =>
            if err
              utils.HandleError.call @, err, 'copy', @config.env.srcDir, @dest
              return 

            Product.compile()

            Product.on 'success', (domain) =>
              @_fixPerms Product, () =>
                @emit 'success', domain
            
            Product.on 'error', (err, type, args) =>
              @emit 'error', err, type, args

    

  _fixPerms: (product, cb) ->
    utils.GetUid "", 'u', (err, uid, stderr) =>
      utils.GetUid @config.env.unix.httpGroup, 'g', (err, gid, stderr) =>
        fs.chown product.baseDir, (parseInt uid), (parseInt gid), (err) =>
          if err
            utils.HandleError.call @, err, 'chown_err'
          cb()

module.exports = Cloner