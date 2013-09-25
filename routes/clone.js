// Generated by CoffeeScript 1.6.3
var Cloner, config, fs;

Cloner = require('../src/cloner');

config = require('../src/config');

fs = require('fs-extra');

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
  cloner = Cloner.create(data, _config, lp, subdomain);
  cloner.clone(force);
  cloner.on('success', function(domain) {
    return res.json({
      status: 'success',
      domain: domain
    });
  });
  return cloner.on('error', function(err, type, args) {
    console.log(err, type, args);
    return res.json(500, {
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
    return res.json({
      status: 'success',
      catalog: dirs
    });
  });
};
