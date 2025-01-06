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

Check the [test cookbook](test/cookbooks/test) for examples on how to use the resources

* [caddy_build](docs/caddy_build.md)
* [caddy_site](docs/caddy_site.md)
* [caddy_service](docs/caddy_service.md)
* [caddy_snippet](docs/caddy_snippet.md)

