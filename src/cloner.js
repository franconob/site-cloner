// Generated by CoffeeScript 1.6.3
(function() {
  var Cloner, exec, fs, hogan, mkdirp, mysql;

  fs = require('fs-extra');

  mkdirp = require('mkdirp');

  hogan = require('hogan.js');

  mysql = require('mysql2');

  exec = (require('child_process')).exec;

  Cloner = (function() {
    function Cloner(vars, srcDir, destDir, lp, domain) {
      this.vars = vars;
      this.srcDir = srcDir;
      this.destDir = destDir;
      this.lp = lp;
      this.domain = domain;
      this.baseSQL = "db.sql";
      this.dbCompiled = null;
    }

    Cloner.prototype.clone = function(callback) {
      var _this = this;
      this.callback = callback;
      this.dest = "" + this.destDir + "/" + this.domain;
      return mkdirp(this.dest, function(err) {
        if (err) {
          throw err;
        }
        return fs.copy(_this.srcDir, _this.dest, function(err) {
          if (err) {
            throw err;
          }
          return _this._compileDb(function() {
            return _this._createDb(function() {
              return _this.callback();
            });
          });
        });
      });
    };

    Cloner.prototype._connect = function(options) {
      var config;
      if (options == null) {
        options = {};
      }
      config = {
        user: 'root',
        password: 'echesortufc',
        multipleStatements: true
      };
      return this.conn = mysql.createConnection(config);
    };

    Cloner.prototype._createDb = function(callback) {
      var dbName,
        _this = this;
      dbName = "lp_" + this.domain;
      this._connect();
      return this.conn.query("CREATE DATABASE " + dbName + " CHARACTER SET utf8 COLLATE utf8_general_ci", function(err, result) {
        if (err) {
          throw err;
        }
        return _this._mysqlCmd(dbName, "" + _this.dest + "/" + _this.baseSQL, function(err, stdout, stderr) {
          if (err) {
            throw err;
          }
          console.log(stdout);
          console.log(stderr);
          return _this.conn.end(function(err) {
            return callback();
          });
        });
      });
    };

    Cloner.prototype._compileDb = function(callback) {
      var _this = this;
      return fs.readFile("" + this.srcDir + "/" + this.baseSQL, {
        encoding: 'utf8'
      }, function(err, data) {
        var template;
        template = hogan.compile(data);
        _this.dbCompiled = template.render(_this.vars);
        return fs.writeFile("" + _this.dest + "/" + _this.baseSQL, _this.dbCompiled, function(err) {
          if (err) {
            throw err;
          }
          return callback();
        });
      });
    };

    Cloner.prototype._mysqlCmd = function(db, file, callback) {
      return exec("mysql -uroot -pechesortufc " + db + " < " + file, callback);
    };

    return Cloner;

  })();

  module.exports = Cloner;

}).call(this);
