Cloner = (require '../src/cloner')
config = require '../src/config'

exports.clone = (req, res) ->
  lp = req.params.landingPage
  domain = req.params.domain

  config = config[req.app.get 'env']

  srcDir = config.srcLp
  destDir = config.destLp

  data = req.body.data

  cloner = new Cloner(data, srcDir, destDir, lp, domain, config)

  try
    cloner.clone ->
      status = 'success'
      res.json status: status, domain: "#{domain}#{config.domain}"
  catch error
      res.json status: "error"
