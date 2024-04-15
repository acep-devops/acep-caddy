default['golang']['version'] = '1.22.1'

default['gcp']['service_account_json'] = '/etc/caddy/gcp_service_account.json'
default['gcp']['service_account_vault'] = 'gcp_service_account_json'
default['gcp']['project'] = ''

default['chef-vault']['databag_fallback'] = true

default['caddy']['user'] = 'caddy'
default['caddy']['group'] = 'caddy'
default['caddy']['wildcard_domain'] = '*.lab.acep.uaf.edu'
default['caddy']['acme_email'] = 'uaf-acep-ci@alaska.edu'
default['caddy']['sites_data_bag'] = ''
