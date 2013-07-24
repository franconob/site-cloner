Cloner = (require '../src/cloner')
config = require '../src/config'

exports.clone = (req, res) ->
  lp = req.params.landingPage
  domain = req.params.domain

  config_env = config[req.app.get 'env']

  config_env['all'] = config['all']

  data = req.body.data

  cloner = new Cloner(data, config_env, lp, domain)

  cloner.clone()

  cloner.on 'success', (domain) ->
    res.json
      status: 'success'
      domain: "#{domain}#{config_env.domain}"

  cloner.on 'error', (err, type, args) ->
    res.json
      status: 'error'
      error:
        code: err.code
        message: err.toString()
