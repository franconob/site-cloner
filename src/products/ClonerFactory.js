// Generated by CoffeeScript 1.6.3
var ClonerFactory, products;

products = require('./products');

ClonerFactory = {
  getCloner: function(landingPage, config, vars, subdomain, destDir) {
    var cloner;
    cloner = (function() {
      switch (landingPage) {
        case 'wordpress':
          return new products.Wordpress(config, vars, subdomain, destDir);
        case 'joomla':
          return new products.Joomla(config, vars, subdomain, destDir);
        case 'limesurvey':
          return new products.Limesurvey(config, vars, subdomain, destDir);
        case 'moodle':
          return new products.Moodle(config, vars, subdomain, destDir);
        case 'prestashop':
          return new products.Prestashop(config, vars, subdomain, destDir);
        case 'vtiger':
          return new products.Vtiger(config, vars, subdomain, destDir);
        case 'elgg':
          return new products.Elgg(config, vars, subdomain, destDir);
      }
    })();
    return cloner;
  }
};

module.exports = ClonerFactory;