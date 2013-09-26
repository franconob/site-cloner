// Generated by CoffeeScript 1.6.3
(function() {
  var BaseProduct, Elgg, Joomla, Limesurvey, Moodle, Prestashop, Vtiger, Wordpress, utils, _ref, _ref1, _ref2, _ref3,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseProduct = require('./BaseProduct');

  utils = require('../utils');

  Wordpress = (function(_super) {
    __extends(Wordpress, _super);

    function Wordpress(config, vars, subdomain, destDir) {
      var _this = this;
      Wordpress.__super__.constructor.call(this, config, vars, subdomain, destDir);
      this.on('compile.success', function() {
        return _this.updateDb();
      });
    }

    Wordpress.prototype.updateDb = function() {
      var conn,
        _this = this;
      conn = this._connect({
        database: "lp_" + this.subdomain
      });
      return conn.execute('UPDATE wp_options SET option_value = ? WHERE option_name = ?', ["http://" + this.fqdn, 'siteurl'], function(err, res) {
        if (err) {
          utils.HandleError.call(_this, err, 'updatedb_err');
          return;
        }
        conn.execute('UPDATE wp_options SET option_value = ? WHERE option_name = ?', ["http://" + _this.fqdn, 'home'], function(err, res) {
          if (err) {
            utils.HandleError.call(_this, err, 'updatedb_err');
          }
        });
        return _this.emit('success', _this.fqdn);
      });
    };

    return Wordpress;

  })(BaseProduct);

  Joomla = (function(_super) {
    __extends(Joomla, _super);

    function Joomla(config, vars, subdomain, destDir) {
      Joomla.__super__.constructor.call(this, config, vars, subdomain, destDir);
      this.configFileVars['logDir'] = this._getPath(this.destDir, 'logs');
      this.configFileVars['tmpDir'] = this._getPath(this.destDir, 'tmp');
    }

    return Joomla;

  })(BaseProduct);

  Limesurvey = (function(_super) {
    __extends(Limesurvey, _super);

    function Limesurvey() {
      _ref = Limesurvey.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return Limesurvey;

  })(BaseProduct);

  Moodle = (function(_super) {
    __extends(Moodle, _super);

    function Moodle() {
      _ref1 = Moodle.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    return Moodle;

  })(BaseProduct);

  Prestashop = (function(_super) {
    __extends(Prestashop, _super);

    function Prestashop() {
      _ref2 = Prestashop.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    return Prestashop;

  })(BaseProduct);

  Vtiger = (function(_super) {
    __extends(Vtiger, _super);

    function Vtiger() {
      _ref3 = Vtiger.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    return Vtiger;

  })(BaseProduct);

  Elgg = (function(_super) {
    __extends(Elgg, _super);

    function Elgg(config, vars, subdomain, destdir) {
      var _this = this;
      Elgg.__super__.constructor.call(this, config, vars, subdomain, destdir);
      this.on('compile.success', function() {
        return _this.updateDb();
      });
    }

    Elgg.prototype.updateDb = function() {
      var conn,
        _this = this;
      conn = this._connect({
        database: "lp_" + this.subdomain
      });
      return conn.execute('UPDATE `elgg_datalists` SET `value` = ? WHERE `name` = "path"', ["" + this.destDir + "/"], function(err, res) {
        if (err) {
          utils.HandleError.call(_this, err, 'updatedb_err');
        }
        return conn.execute('UPDATE `elgg_datalists` SET `value` = ? WHERE `name` = "dataroot"', ["" + _this.baseDir + "/elgg_data/"], function(err, res) {
          if (err) {
            utils.HandleError.call(_this, err, 'updatedb_err');
          }
          return conn.execute('UPDATE `elgg_sites_entity` SET `url` = ?', [_this.fqdn], function(err, res) {
            if (err) {
              utils.HandleError.call(_this, err, 'updatedb_err');
            }
            return conn.execute("UPDATE elgg_metastrings set string = ? WHERE id = (SELECT value_id from elgg_metadata where name_id = 						(SELECT * FROM (SELECT id FROM elgg_metastrings WHERE string = 'filestore::dir_root') as ms2) LIMIT 1)", ["" + _this.baseDir + "/elgg_data/"], function(err, res) {
              if (err) {
                utils.HandleError.call(_this, err, 'updatedb_err');
              }
              return conn.end(function(err) {
                if (err) {
                  utils.HandleError.call(_this, err, 'updatedb_err');
                }
                return _this.emit('success', _this.fqdn);
              });
            });
          });
        });
      });
    };

    return Elgg;

  })(BaseProduct);

  module.exports.Wordpress = Wordpress;

  module.exports.Joomla = Joomla;

  module.exports.Limesurvey = Limesurvey;

  module.exports.Moodle = Moodle;

  module.exports.Prestashop = Prestashop;

  module.exports.Vtiger = Vtiger;

  module.exports.Elgg = Elgg;

}).call(this);
