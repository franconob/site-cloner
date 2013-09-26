module.exports =

  development:
    srcDir: '/home/fherrero/workspace/spiralti/finderit.workspace/cl.finderit.com/webs/catalog'
    destDir: '/home/fherrero/workspace/spiralti/finderit.workspace/cl.finderit.com/webs/public'
    domain: '.cl.finderit.local'
    db:
      user: 'root'
      password: 'echesortufc'
    unix:
      httpUser: 'http'
      httpGroup: 'http'

  production:
    srcDir: '/var/www/catalog'
    destDir: '/var/www/public'
    domain: '.cl.finderit.com'
    db:
      user: 'root'
      password: 'Spiralti1017'
    unix:
      httpUser: 'www-data'
      httpGroup: 'www-data'
  
  products:
    wordpress:
      configFile: 'wp-config.php'
    wordpress_001:
      configFile: 'wp-config.php'
    joomla:
      configFile: 'configuration.php'
    limesurvey:
      configFile: 'application/config/config.php'
    moodle:
      configFile: 'config.php'
    prestashop:
      configFile: 'config/settings.inc.php'
    vtiger:
      configFile: 'config.inc.php'
    elgg:
      configFile: 'engine/settings.php'  
  

