// Generated by CoffeeScript 1.6.3
(function() {
  var ClonerFactory, products;

  products = require('./products');

  ClonerFactory = {
    getCloner: function(landingPage, config, vars, subdomain, destDir) {
      var cloner;
      cloner = (function() {
        switch (landingPage) {
          case 'wordpress':
            return new products.Wordpress(config, vars, subdomain, landingPage, destDir);
          case 'wordpress_001':
            return new products.Wordpress(config, vars, subdomain, landingPage, destDir);
          case 'wordpress_blog':
            return new products.Wordpress(config, vars, subdomain, landingPage, destDir);
          case 'joomla':
            return new products.Joomla(config, vars, subdomain, landingPage, destDir);
          case 'limesurvey':
            return new products.Limesurvey(config, vars, subdomain, landingPage, destDir);
          case 'moodle':
            return new products.Moodle(config, vars, subdomain, landingPage, destDir);
          case 'prestashop':
            return new products.Prestashop(config, vars, subdomain, landingPage, destDir);
          case 'vtiger':
            return new products.Vtiger(config, vars, subdomain, landingPage, destDir);
          case 'elgg':
            return new products.Elgg(config, vars, subdomain, landingPage, destDir);
        }
      })();
      return cloner;
    }
  };

  module.exports = ClonerFactory;

}).call(this);
