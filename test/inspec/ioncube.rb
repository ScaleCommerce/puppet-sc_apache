# ioncube loader enabled in cli?
describe command('php -m | grep "ionCube PHP Loader"') do
 its('exit_status') { should eq 0 }
end
# ioncube loader enabled in apache?
describe command('curl -s http://localhost/extensions.php | grep "ionCube Loader"') do
 its('exit_status') { should eq 0 }
end
