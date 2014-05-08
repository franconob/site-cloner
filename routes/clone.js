// Generated by CoffeeScript 1.7.1
(function() {
  var Cloner, config, exec, fs;

  Cloner = require('../src/cloner');

  config = require('../src/config');

  fs = require('fs-extra');

  exec = (require('child_process')).exec;

  exports.clone = function(req, res) {
    var cloner, data, force, lp, subdomain, _config;
    req.connection.setTimeout(10 * 60 * 1000);
    force = req.query.force;
    lp = req.params.landingPage;
    subdomain = req.params.domain;
    _config = {};
    _config = config['products'][lp];
    _config['env'] = config[req.app.get('env')];
    data = req.body.data;
    cloner = new Cloner(data, _config, lp, subdomain);
    cloner.clone(force);
    cloner.on('success', function(domain) {
      return res.json({
        status: 'success',
        domain: domain
      });
    });
    return cloner.on('error', function(err, type, args) {
      exec("virtualmin delete-domain --domain " + subdomain + "." + _config['env'].domain);
      return res.json(200, {
        status: 'error',
        error: {
          type: type,
          code: err.code,
          message: err.toString()
        }
      });
    });
  };

  exports.catalog = function(req, res) {
    return fs.readdir(config[req.app.get('env')].srcDir, function(err, dirs) {
      return res.format({
        html: function() {
          return res.render('index', {
            webs: dirs
          });
        },
        json: function() {
          return res.json({
            status: 'success',
            catalog: dirs
          });
        },
        'default': function() {
          return res.send('nada');
        }
      });
    });
  };

  exports["public"] = function(req, res) {
    return fs.readdir(config[req.app.get('env')].destDir, function(err, dirs) {
      return res.json({
        status: 'success',
        webs: dirs
      });
    });
  };

}).call(this);

//# sourceMappingURL=clone.map
