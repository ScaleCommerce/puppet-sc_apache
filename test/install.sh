#!/bin/bash
apt-get update
apt-get -y install curl sudo puppet ruby1.9.1-dev make gcc nano software-properties-common rsync git dnsutils unzip whois python-software-properties python-pip psmisc
gem install --no-rdoc --no-ri librarian-puppet
curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec
ln -sf /builds/sc-puppet/puppet-sc_apache/test/hiera.yaml /etc/puppet/
ln -sf /builds/sc-puppet/puppet-sc_apache/test/Puppetfile /etc/puppet/
ln -sf /builds/sc-puppet/puppet-sc_apache/test/hiera /var/lib/hiera
ln -sf /builds/sc-puppet/puppet-sc_apache /etc/puppet/modules/sc_apache
cd /etc/puppet ; librarian-puppet install
curl https://gitlab.scale.sc/scalecommerce/postinstall/raw/master/puppet.conf.sample > /etc/puppet/puppet.conf
puppet config set certname puppet-test.scalecommerce