// Generated by CoffeeScript 1.7.1
(function() {
  var BaseProduct, EventEmitter, exec, fs, hogan, mysql, path, utils, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  hogan = require('hogan.js');

  mysql = require('mysql2');

  exec = (require('child_process')).exec;

  EventEmitter = (require('events')).EventEmitter;

  utils = require('../utils');

  fs = require('fs-extra');

  _ = require('underscore');

  path = require('path');

  BaseProduct = (function(_super) {
    __extends(BaseProduct, _super);

    BaseProduct.DBFILE = 'db.sql';

    function BaseProduct(config, vars, subdomain, landingpage, destDir) {
      this.config = config;
      this.vars = vars;
      this.subdomain = subdomain;
      this.landingpage = landingpage;
      this.vars = this.vars || {};
      this.dbname = "" + this.subdomain + "_cl_finderit_com";
      this.baseDir = this._getPath(destDir, '..');
      this.destDir = this._getPath(this.baseDir, 'public_html');
      this.srcDir = "" + this.config.env.srcDir + "/" + this.landingpage;
      this.configFile = this.config.configFile;
      this.fqdn = "" + this.subdomain + this.config.env.domain;
      this.dbName = "" + this.subdomain + "_cl_finderit_com";
      this.origDbName = "lp_base_" + (path.basename(this.srcDir));
      this.configFileVars = {
        destDir: this.destDir,
        baseDir: this.baseDir,
        domain: this.fqdn,
        subdomain: this.subdomain,
        dbUser: this.config.env.db.user,
        dbName: this.dbName,
        dbPassword: this.config.env.db.password
      };
      this.vars = _.extend({}, this.vars, this.configFileVars);
      EventEmitter.call(this);
    }

    BaseProduct.prototype.compile = function() {
      return this.compileDb((function(_this) {
        return function() {
          return _this.createDb(function() {
            return _this.compileConfig(function() {
              if (EventEmitter.listenerCount(_this, 'compile.success')) {
                return _this.emit('compile.success');
              } else {
                return _this.emit('success', _this.fqdn);
              }
            });
          });
        };
      })(this));
    };

    BaseProduct.prototype.compileConfig = function(callback) {
      var config;
      config = this._getPath(this.destDir, this.configFile);
      return fs.readFile(this._getPath(this._getPath(this.srcDir, 'htdocs'), "" + this.configFile + ".tpl"), {
        encoding: 'utf8'
      }, (function(_this) {
        return function(err, data) {
          var template;
          if (err) {
            utils.HandleError.call(_this, err, 'compileconfig_read');
            return callback(err);
          }
          template = hogan.compile(data);
          return fs.writeFile(config, template.render(_this.configFileVars), function(err) {
            if (err) {
              utils.HandleError.call(_this, err, 'compileconfig_write');
              return callback(err);
            }
            return callback();
          });
        };
      })(this));
    };

    BaseProduct.prototype.compileDb = function(callback) {
      var dbFile;
      dbFile = this._getPath(this.srcDir, "htdocs", BaseProduct.DBFILE);
      return this._mysqlDump(this.origDbName, dbFile, (function(_this) {
        return function(err, stdout, stderr) {
          if (err) {
            utils.HandleError.call(_this, err, 'compiledb_dump');
            return callback(err);
          }
          return fs.copy(dbFile, _this._getPath(_this.destDir, BaseProduct.DBFILE), function(err) {
            if (err) {
              utils.HandleError.call(_this, err, 'compiledb_copydb');
              return callback(err);
            }
            return fs.readFile(_this._getPath(_this.destDir, BaseProduct.DBFILE), {
              encoding: 'utf8'
            }, function(err, data) {
              var template;
              if (err) {
                utils.HandleError.call(_this, err, 'compiledb_read');
                return callback(err);
              }
              template = hogan.compile(data);
              _this.dbCompiled = template.render(_this.vars);
              fs.writeFile(_this._getPath(_this.destDir, BaseProduct.DBFILE), _this.dbCompiled, function(err) {});
              if (err) {
                utils.HandleError.call(_this, err, 'compiledb_write');
                return callback(err);
              }
              return callback(err);
            });
          });
        };
      })(this));
    };

    BaseProduct.prototype.createDb = function(callback) {
      return this._mysqlCmd(this.dbName, fs.realpathSync(this._getPath(this.destDir, BaseProduct.DBFILE)), (function(_this) {
        return function(err, stdout, stderr) {
          if (err) {
            utils.HandleError.call(_this, err, 'sourcedb', stderr);
            return callback(err);
          }
          return callback();
          return "conn = @_connect()\nconn.query \"CREATE DATABASE " + _this.dbName + " CHARACTER SET utf8 COLLATE utf8_general_ci\", (err, result) =>\n  if err\n    utils.HandleError.call @, err, 'createdb', @dbName\n    return callback err\n";
        };
      })(this));
    };

    BaseProduct.prototype._getPath = function() {
      var dir, path;
      dir = arguments[0], path = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      path.unshift(dir);
      return path.join('/');
    };

    BaseProduct.prototype._mysqlCmd = function(db, file, callback) {
      console.log("mysql -u" + this.config.env.db.user + " -p" + this.config.env.db.password + " " + db + " < " + file);
      return exec("mysql -u" + this.config.env.db.user + " -p" + this.config.env.db.password + " " + db + " < " + file, callback);
    };

    BaseProduct.prototype._mysqlDump = function(db, file, callback) {
      return exec("mysqldump -u" + this.config.env.db.user + " -p" + this.config.env.db.password + " " + db + " > " + file, callback);
    };

    BaseProduct.prototype._connect = function(options) {
      var config;
      if (options == null) {
        options = {};
      }
      config = {
        user: this.config.env.db.user,
        password: this.config.env.db.password,
        multipleStatements: true
      };
      return mysql.createConnection(_.extend(config, options));
    };

    return BaseProduct;

  })(EventEmitter);

  module.exports = BaseProduct;

}).call(this);

//# sourceMappingURL=BaseProduct.map
