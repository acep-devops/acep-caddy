default['golang']['version'] = '1.22.1'

default['gcp']['service_account_json'] = '/etc/caddy/gcp_service_account.json'
default['gcp']['service_account_vault'] = 'gcp_service_account_json'
default['gcp']['project'] = 'clound-dns-321021'

default['chef-vault']['databag_fallback'] = true

default['caddy']['user'] = 'caddy'
default['caddy']['group'] = 'caddy'
default['caddy']['wildcard_domain'] = '*.lab.acep.uaf.edu'
default['caddy']['acme_email'] = 'uaf-acep-ci@alaska.edu'

default['acep']['proxy_sites'] = [{
    name: "test",
    fqdn: "test.camio.lab.acep.uaf.edu",
    upstream: "http://localhost:8080",
    self_signed: false
}]
