describe package('php5.6-cli') do
 it { should be_installed }
end
describe service('apache2') do
 it { should be_running }
end
describe http('http://localhost/server-status?auto') do
  its('status') { should cmp 200 }
  its('body') { should match '^Total Accesses' }
end
describe port(80) do
  it { should be_listening }
  its('processes') {should include 'apache2'}
end
