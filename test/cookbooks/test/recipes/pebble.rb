include_recipe 'golang::default'
execute 'go install github.com/jsha/minica@latest' do
  env 'PATH' => "/usr/local/go/bin:#{ENV['PATH']}"
end

docker_installation 'default'
docker_service 'default' do
  action [:create, :start]
end

directory '/etc/pebble' do
  action :create
end

directory '/etc/pebble/certs' do
  action :create
end

execute 'minica -ca-cert pebble.minica.pem -ca-key pebble.minica.key.pem -domains localhost,pebble -ip-addresses 127.0.0.1' do
  cwd '/etc/pebble/certs'
  env 'PATH' => "~/go/bin:#{ENV['PATH']}"
  not_if { ::File.exist?('/etc/pebble/certs/localhost/cert.pem') }
  action :run
end

file '/etc/pebble/config.json' do
  content <<-EOF
{
  "pebble": {
    "listenAddress": "0.0.0.0:14000",
    "managementListenAddress": "0.0.0.0:15000",
    "certificate": "/test/certs/localhost/cert.pem",
    "privateKey": "/test/certs/localhost/key.pem",
    "httpPort": 5002,
    "tlsPort": 5001,
    "ocspResponderURL": "",
    "externalAccountBindingRequired": false,
    "domainBlocklist": ["blocked-domain.example"],
    "retryAfter": {
        "authz": 3,
        "order": 5
    },
    "profiles": {
      "default": {
        "description": "The profile you know and love",
        "validityPeriod": 7776000
      },
      "shortlived": {
        "description": "A short-lived cert profile, without actual enforcement",
        "validityPeriod": 518400
      }
    }
  }
}
  EOF
end

docker_image 'ghcr.io/letsencrypt/pebble' do
  tag 'latest'
end

docker_container 'pebble' do
  repo 'ghcr.io/letsencrypt/pebble'
  tag 'latest'
  port [
    '14000:14000',
    '15000:15000',
  ]
  command '-config /test/config.json'
  volumes [
    '/etc/pebble:/test',
  ]

  env [
    'PEBBLE_VA_NOSLEEP=1',
    'PEBBLE_VA_ALWAYS_VALID=1',
  ]

  action :run
end
