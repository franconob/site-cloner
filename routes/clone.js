// Generated by CoffeeScript 1.6.3
(function() {
  var Cloner, config;

  Cloner = require('../src/cloner');

  config = require('../src/config');

  exports.clone = function(req, res) {
    var cloner, data, destDir, domain, error, lp, srcDir;
    lp = req.params.landingPage;
    domain = req.params.domain;
    config = config[req.app.get('env')];
    srcDir = config.srcLp;
    destDir = config.destLp;
    data = req.body.data;
    cloner = new Cloner(data, srcDir, destDir, lp, domain);
    try {
      return cloner.clone(function() {
        var status;
        status = 'success';
        return res.json({
          status: status,
          domain: "" + domain + config.domain
        });
      });
    } catch (_error) {
      error = _error;
      return res.json({
        status: "error"
      });
    }
  };

}).call(this);
