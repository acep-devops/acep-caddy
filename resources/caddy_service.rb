# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
provides :caddy_service 

property :user, String, default: 'caddy'
property :group, String, default: 'caddy'

property :build_plugins, Array, default: []

action :install do 
    group new_resource.group do
        action :create
        system true
    end
    
    user new_resource.user do
        group new_resource.group
        manage_home true
        home '/var/lib/caddy'
        system true
        shell '/bin/false'
        action [:create, :manage]
    end
 
    directory '/etc/caddy' do
        owner new_resource.user
        group new_resource.group
        mode '0755'
        action :create
    end

    directory '/var/lib/caddy' do 
        owner new_resource.user
        group new_resource.group
        mode '0750'
        action :create
    end
   
    systemd_unit 'caddy.service' do
        content({
            Unit: {
                Description: 'Caddy HTTP/2 web server',
                Documentation: 'https://caddyserver.com/docs/',
                After: 'network.target network-online.target',
                Wants: 'network-online.target',
            },
            Service: {
                ExecStart: '/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile',
                ExecReload: '/usr/bin/caddy reload --config /etc/caddy/Caddyfile --force',
                Restart: 'on-abnormal',
                LimitNOFILE: 1048576,
                Type: 'notify',
                User: 'caddy',
                Group: 'caddy',
                TimeoutStopSec: '5s',
                PrivateTmp: true,
                ProtectSystem: 'full',
                AmbientCapabilities: 'CAP_NET_ADMIN CAP_NET_BIND_SERVICE',
            },
            Install: {
                WantedBy: 'multi-user.target',
            }
        })
        action [:create]
    end
end

action :enable do
    with_run_context :root do
        service 'caddy' do
            action :enable
        end
    end
end

action :start do
    with_run_context :root do
        service 'caddy' do
            action :start
        end
    end
end

action :restart do
    with_run_context :root do
        service 'caddy' do
            action :restart
        end
    end
end

action :reload do
    with_run_context :root do
        service 'caddy' do
            action :reload
        end
    end
end

action :stop do
    with_run_context :root do
        service 'caddy' do
            action :stop
        end
    end
end

action :disable do
    with_run_context :root do
        service 'caddy' do
            action :disable
        end
    end
end

