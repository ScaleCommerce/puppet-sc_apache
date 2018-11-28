# tideways-extension enabled in apache?
describe command('curl -s http://localhost/extensions.php | grep tideways') do
 its('exit_status') { should eq 0 }
end
# tideways-daemon running?
describe processes('tideways-daemon') do
  it { should exist }
end
