products = require('./products')

ClonerFactory =
	getCloner: (landingPage, config, vars, subdomain, destDir) ->
		cloner = switch landingPage
			when 'wordpress' then new products.Wordpress(config, vars, subdomain, destDir)
			when 'joomla' then new products.Joomla(config, vars, subdomain, destDir)
			when 'limesurvey' then new products.Limesurvey(config, vars, subdomain, destDir)
			when 'moodle' then new products.Moodle(config, vars, subdomain, destDir)
			when 'prestashop' then new products.Prestashop(config, vars, subdomain, destDir)
			when 'vtiger' then new products.Vtiger(config, vars, subdomain, destDir)
			when 'elgg' then new products.Elgg(config, vars, subdomain, destDir)
		cloner

module.exports = ClonerFactory

