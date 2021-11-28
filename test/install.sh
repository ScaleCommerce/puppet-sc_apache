#!/bin/bash
export PATH=/opt/puppetlabs/bin:$PATH
sed -i -e "s/nodaemon=true/nodaemon=false/" /etc/supervisord.conf
/usr/local/bin/supervisord -c /etc/supervisord.conf
echo "Running in $(pwd)"
echo "Puppet Version: $(puppet -V)"

# configure puppet
ln -sf $(pwd)/test/hiera.yaml $(puppet config print confdir |cut -d: -f1)/
ln -sf $(pwd)/test/puppet.conf > $(puppet config print confdir |cut -d: -f1)/puppet.conf
ln -sf $(pwd)/test/hieradata $(puppet config print confdir |cut -d: -f1)/hieradata
puppet config set certname puppet-test.scalecommerce

# install puppet modules
puppet module install ajcrowe-supervisord
puppet module install puppetlabs-apache --version 2.3.1
puppet module install puppetlabs-apt --version 2.4.0
puppet module install puppetlabs-inifile --version 1.6.0
puppet module install yo61-logrotate
git clone https://github.com/ScaleCommerce/puppet-supervisor_provider.git $(puppet config print modulepath |cut -d: -f1)/supervisor_provider
ln -sf $(pwd) $(puppet config print modulepath |cut -d: -f1)/sc_apache

curl -s https://omnitruck.chef.io/install.sh | bash -s -- -P inspec -v 3.9.3
