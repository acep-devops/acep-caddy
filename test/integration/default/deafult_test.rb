# Chef InSpec test for recipe acep-caddy::debian

# The Chef InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe package('xcaddy') do
  it { should be_installed }
end

describe service('caddy') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(443) do
  it { should be_listening }
  its('processes') { should include 'caddy' }
end

describe file('/etc/caddy/Caddyfile') do
  it { should exist }
  its('content') { should match /test-gcp-project/ }
end
