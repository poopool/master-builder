#!/usr/bin/env bash

#Adding puppetlabs repo
cd /tmp
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb

#Installing puppet
sudo apt-get update
sudo apt-get install -y puppet