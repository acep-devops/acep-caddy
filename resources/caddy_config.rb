# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
unified_mode false

provides :caddy_config

property :config_file, String, default: '/etc/caddy/Caddyfile'
property :user, String, default: 'caddy'
property :group, String, default: 'caddy'  
property :acme_email, String
property :acme_staging, [true, false], default: false
property :gcp_project, String
property :gcp_service_account_json, String

# related to add actions
property :domain, String
property :fqdn, String, name_property: true
property :content, String

action :add do 
    with_run_context :root do
        edit_resource(:template, new_resource.config_file) do |new_resource|
            variables[:domains] ||= {}
            variables[:domains][new_resource.domain] ||= {}
            variables[:domains][new_resource.domain][new_resource.fqdn] = new_resource.content            
        end
    end
end

action :create do 
    with_run_context :root do
        gcp_service_account_file = '/etc/caddy/gcp_service_account.json'
        
        file gcp_service_account_file do
            content new_resource.gcp_service_account_json
            owner new_resource.user
            group new_resource.group
            mode '0700'
            action :create
            notifies :reload, 'service[caddy]', :delayed
        end

        template new_resource.config_file do
            source 'Caddyfile_resource.erb'
            owner new_resource.user
            group new_resource.group
            mode '0700'
            variables( 
                domains: { },
                acme_email: new_resource.acme_email,
                acme_staging: new_resource.acme_staging,
                gcp_project: new_resource.gcp_project,
                gcp_service_account_file: gcp_service_account_file
            )
            action :nothing
            delayed_action :create
            notifies :reload, 'service[caddy]', :delayed
        end
    end
end

