Cloner = (require '../src/cloner')
config = require '../src/config'

exports.clone = (req, res) ->
  lp = req.params.landingPage
  domain = req.params.domain

  config_env = config[req.app.get 'env']

  config_env['all'] = config['all']

  data = req.body.data

  cloner = new Cloner(data, config_env, lp, domain)

  try
    cloner.clone ->
      status = 'success'
      res.json status: status, domain: "#{domain}#{config_env.domain}"
  catch error
      res.json status: "error"
