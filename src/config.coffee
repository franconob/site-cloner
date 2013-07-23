module.exports =
  development:
    srcLp: "/tmp/landingpage/wordpress"
    destLp: "/tmp/clients"
    domain: ".prod.finderit.com"
    db:
      user: 'root'
      password: 'echesortufc'
  production:
    srcLp: "/var/www/catalog/wordpress"
    destLp: "/var/www/clients"
    domain: ".cl.finderit.com"
    db:
      user: 'root'
      password: 'Spiralti1017'