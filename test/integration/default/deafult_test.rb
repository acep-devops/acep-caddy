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
  its('content') { should match /@hello_lab_acep_uaf_edu/ }
end

describe command('sleep 5 && curl https://hello.lab.acep.uaf.edu --connect-to hello.lab.acep.uaf.edu:443:127.0.0.1 -k') do
  its('stdout') { should match /Hello, World!/ }
end
