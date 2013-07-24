module.exports =
  development:
    srcDir: "/home/fherrero/workspace/spiralti/finderit.workspace/cl.finderit.com/webs/catalog/wordpress"
    destDir: "/home/fherrero/workspace/spiralti/finderit.workspace/cl.finderit.com/webs/catalog/clients"
    domain: ".prod.finderit.com"
    db:
      user: 'root'
      password: 'echesortufc'
  production:
    srcDir: "/var/www/catalog/wordpress"
    destDir: "/var/www/clients"
    domain: ".cl.finderit.com"
    db:
      user: 'root'
      password: 'Spiralti1017'

  all:
    configFile: "wp-config.php"
