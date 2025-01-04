# acep-caddy

Initial cookbook for setting up caddy reverse proxy service for ACEP.

This currently has a few assumptions in place:

1. Using wildcard cert for all reverse proxy targets which means they have to all fall under the same root domain i.e. `*.lab.acep.uaf.edu`
2. Wildcard cert we will need to use the DNS-01 verification process for Let's Encrypt and is configured to use GCP Cloud DNS module.

## Credentials

Currently this is cookbook has to create dns entires in the GCP CloudDomain in order to handle wildcard certificates as such we need to provide the cookbook a service account json block. 

When creating a service account in GCP you can create a service key `JSON` this should be downloaded and a chef-vault created using the a command similar to the following.

*Note: Replace any value encased in `[]` with an the desired names* 

Set the correct attribute value for the cookbook to use in the nodes Policyfile

```ruby
default['gcp']['project'] = "[GCP_PROJECT_NAME]"
default['gcp']['service_account_vault'] = "[GCP_SECRET_VAULT_NAME]"
```

Once a node is provisioned it can be given access to the vault by adding the `clouddns` tag and refreshing the vault

```bash
knife tag create NODE_NAME clouddns
knife vault refresh credentials [GCP_SECRET_VAULT_NAME]
```

To create the chef vault use the following command

```bash
knife vault create credentials [GCP_SECRET_VAULT_NAME] -m client -S "tags:clouddns" -A "[admin1],[admin2],[admin3]" --file /path/to/credentials/file
```


## Resources

* caddy_build
* caddy_config
* caddy_service
* caddy_snippet

* TODO: Add documentation for resources
* Check the test cookbook `test/cookbooks/test` for examples on how to use the resources



* `wildcard_domain` - This is the domain that will be used to request a wildcard ssl certificate. Currently this cookbook assumes it's hosted in GCP CloudDomain and will need the appropriate credentials in order to set `txt` records for Let's Encrypt.
* `gcp_project` - the GCP project hosting the wildcard domain
* `sites` - An array of site configs that the caddy instance will proxy.
    * `name` - Unique name for the reverse proxy site
    * `upstream` - URL for the remote site to proxy
    * `fqdn` - The url that will be used for the proxy to the remote site. Must be covered by the wildcard host or cause SSL errors
    * `self_signed` - If the remote site for the proxy uses a self-signed proxy then this must be set to `true` in order to allow caddy to trust the remote site. Otherwise this should be `false` if using a real SSL certificate or is not using SSL.
