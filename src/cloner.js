// Generated by CoffeeScript 1.7.1
(function() {
  var Cloner, ClonerFactory, EventEmitter, exec, fs, mkdirp, mysql, rimraf, utils,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  fs = require('fs-extra');

  mkdirp = require('mkdirp');

  ClonerFactory = require('./products/ClonerFactory');

  EventEmitter = (require('events')).EventEmitter;

  utils = require('./utils');

  rimraf = require('rimraf');

  mysql = require('mysql2');

  exec = (require('child_process')).exec;

  Cloner = (function(_super) {
    __extends(Cloner, _super);

    function Cloner(vars, config, lp, subdomain) {
      this.vars = vars;
      this.config = config;
      this.lp = lp;
      this.subdomain = subdomain;
      this.dest = "" + this.config.env.destDir + "/" + this.subdomain + this.config.env.domain;
      this.srcDir = "" + this.config.env.srcDir + "/" + this.lp + "/htdocs";
      EventEmitter.call(this);
    }

    Cloner.prototype.clone = function(force) {
      return fs.exists(this.dest, (function(_this) {
        return function(exists) {
          if (exists) {
            if (!force) {
              utils.HandleError.call(_this, new Error('El dominio ya existe'), 'domain_exists', _this.subdomain);
            } else {
              return rimraf(_this.dest, function(err) {
                if (err) {
                  utils.HandleError.call(_this, err, 'rmmdir');
                  return;
                }
                return _this.dropDb(function(err) {
                  return _this.createDir();
                });
              });
            }
          } else {
            return _this.createVirtualMinHost();
          }
        };
      })(this));
    };

    Cloner.prototype.createVirtualMinHost = function() {
      var Product, fqdn;
      Product = ClonerFactory.getCloner(this.lp, this.config, this.vars, this.subdomain, this.dest);
      fqdn = "" + this.subdomain + this.config.env.domain;
      console.log("virtualmin create-domain --domain " + fqdn + " --parent cloner.cl.finderit.com --web --dns --dir --mysql --ftp");
      return exec("virtualmin create-domain --domain " + fqdn + " --parent cloner.cl.finderit.com --web --dns --dir --mysql --ftp", (function(_this) {
        return function(err, stdout, stderr) {
          console.log(stdout, stderr);
          if (err) {
            utils.HandleError.call(_this, err, 'virtualmin create-host');
            return cb(err);
          }
          return fs.copy(_this.srcDir, _this.dest, function(err) {
            if (err) {
              utils.HandleError.call(_this, err, 'copy', _this.srcDir, _this.dest);
              return;
            }
            Product.compile();
            Product.on('success', function(domain) {
              return _this._fixPerms(Product, function() {
                return _this.emit('success', domain);
              });
            });
            return Product.on('error', function(err, type, args) {
              return _this.emit('error', err, type, args);
            });
          });
        };
      })(this));
    };

    Cloner.prototype.dropDb = function(callback) {
      var conn;
      conn = mysql.createConnection({
        user: this.config.env.db.user,
        password: this.config.env.db.password
      });
      return conn.execute("DROP DATABASE lp_" + this.subdomain, function(err, res) {
        return conn.end(function() {
          return callback(err);
        });
      });
    };

    Cloner.prototype._fixPerms = function(product, cb) {
      return exec("chown cloner:" + this.config.env.unix.httpGroup + " -R " + product.baseDir, (function(_this) {
        return function(err, stdout, stderr) {
          exec("chmod 775 -R " + product.baseDir, function(err, stdout, stderr) {});
          if (err) {
            utils.HandleError.call(_this, err, 'chown_err');
          }
          return cb(err);
        };
      })(this));
    };

    return Cloner;

  })(EventEmitter);

  module.exports = Cloner;

}).call(this);

//# sourceMappingURL=cloner.map
