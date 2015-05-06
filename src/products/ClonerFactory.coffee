products = require('./products')

ClonerFactory =
	getCloner: (landingPage, config, vars, subdomain, destDir) ->
		cloner = switch landingPage
			when 'wordpress' then new products.Wordpress(config, vars, subdomain, landingPage, destDir)
			when 'wordpress_001' then new products.Wordpress(config, vars, subdomain, landingPage, destDir)
			when 'wordpress_blog' then new products.Wordpress(config, vars, subdomain, landingPage, destDir)
			when 'joomla' then new products.Joomla(config, vars, subdomain, landingPage, destDir)
			when 'limesurvey' then new products.Limesurvey(config, vars, subdomain, landingPage, destDir)
			when 'moodle' then new products.Moodle(config, vars, subdomain, landingPage, destDir)
			when 'prestashop' then new products.Prestashop(config, vars, subdomain, landingPage, destDir)
			when 'vtiger' then new products.Vtiger(config, vars, subdomain, landingPage, destDir)
			when 'elgg' then new products.Elgg(config, vars, subdomain, landingPage, destDir)
		cloner

module.exports = ClonerFactory

