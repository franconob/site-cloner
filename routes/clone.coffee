Cloner = (require '../src/cloner')
config = require '../src/config'

exports.clone = (req, res) ->

  req.connection.setTimeout 10 * 60 * 1000

  lp = req.params.landingPage
  subdomain = req.params.domain

  _config = {}
  _config = config['products'][lp]
  _config['env'] = config[req.app.get 'env']

  data = req.body.data

  cloner = Cloner.create data, _config, lp, subdomain

  cloner.clone()

  cloner.on 'success', (domain) ->
    res.json
      status: 'success'
      domain: domain

  cloner.on 'error', (err, type, args) ->
    console.log err, type, args
    res.json 500,
      status: 'error'
      error:
        type: type
        code: err.code
        message: err.toString()
