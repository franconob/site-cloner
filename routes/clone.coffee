Cloner = (require '../src/cloner')
config = (require '../src/config')
fs = require 'fs-extra'
exec = (require 'child_process').exec

exports.clone = (req, res) ->

  req.connection.setTimeout 10 * 60 * 1000

  force = req.query.force

  lp = req.params.landingPage
  subdomain = req.params.domain

  _config = {}
  _config = config['products'][lp]
  _config['env'] = config[req.app.get 'env']

  data = req.body.data

  cloner = new Cloner data, _config, lp, subdomain

  cloner.clone(force)

  cloner.on 'success', (domain) ->
    res.json
      status: 'success'
      domain: domain

  cloner.on 'error', (err, type, args) ->
    exec "virtualmin delete-domain --domain #{subdomain}.#{_config['env'].domain}"
    res.json 200,
      status: 'error'
      error:
        type: type
        code: err.code
        message: err.toString()

exports.catalog = (req, res) ->
  console.log config[req.app.get 'env'].srcDir
  fs.readdir config[req.app.get 'env'].srcDir, (err, dirs) ->
    res.format
      html: ->
        res.render('index', {webs: dirs})
      json: ->
        res.json
          status: 'success'
          catalog: dirs
      'default': ->
        res.send('nada')

exports.public = (req, res) ->
  fs.readdir config[req.app.get 'env'].destDir, (err, dirs) ->
    res.json
      status: 'success'
      webs: dirs



