module.exports =

  development:
    srcDir: '/home/fherrero/workspace/spiralti/finderit.workspace/cloner.cl.finderit.com/webs/catalog'
    destDir: '/home/fherrero/workspace/spiralti/finderit.workspace/cloner.cl.finderit.com/webs/public'
    domain: '.cl.finderit.local'
    db:
      user: 'root'
      password: 'echesortufc'
    unix:
      httpUser: 'http'
      httpGroup: 'http'

  production:
    srcDir: '/home/cloner/catalog'
    destDir: '/home/cloner/domains'
    domain: '.cl.finderit.com'
    db:
      user: 'cloner'
      password: 'Spiralti1017'
    unix:
      httpUser: 'cloner'
      httpGroup: 'cloner'
  
  products:
    wordpress:
      configFile: 'wp-config.php'
    wordpress_001:
      configFile: 'wp-config.php'
    wordpress_blog:
      configFile: 'wp-config.php'
    landing_001:
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
  

