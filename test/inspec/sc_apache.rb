# php-cli installed and correct version?
describe package('phpy${php_major_version}-cli') do
 it { should be_installed }
end

# apache2 running?
describe processes('apache2') do
  it { should exist }
end
describe port(80) do
  it { should be_listening }
  its('processes') {should include 'apache2'}
end

# mod_server-status enabled?
describe http('http://localhost/server-status?auto') do
  its('status') { should cmp 200 }
  its('body') { should match '^Total Accesses' }
end

# php running in apache?
describe http('http://localhost/info.php') do
  its('status') { should cmp 200 }
end

# apache php version correct?
describe http('http://localhost/version.php') do
  its('body') { should match '^${php_major_version}' }
end

# php-cli version correct?
describe command('php -r "echo phpversion();"') do
  its('stdout') { should match '^${php_major_version}' }
end


# memcached-extension enabled in cli?
describe command('php -m | grep memcached') do
 its('exit_status') { should eq 0 }
end
# memcached-extension enabled in apache?
describe command('curl -s http://localhost/extensions.php | grep memcached') do
 its('exit_status') { should eq 0 }
end

# common module (example: status module) enabled in apache?
describe command('apache2ctl -M | grep status_module') do
  its('exit_status') { should eq 0 }
end

# custom module (example: access_compat) enabled in apache?
describe command('apache2ctl -M | grep access_compat_module') do
  its('exit_status') { should eq 0 }
end
