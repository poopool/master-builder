#
# Cookbook:: awesome_customers_ubuntu
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'apt::default'
#include_recipe 'awesome_customers_ubuntu::firewall'
include_recipe 'awesome_customers_ubuntu::web_user'
include_recipe 'awesome_customers_ubuntu::web'
include_recipe 'awesome_customers_ubuntu::database'
include_recipe 'awesome_customers_ubuntu::supervisord'

template '/etc/supervisor/conf.d/supervisord.conf' do
  source 'supervisord.conf.erb'
  mode '0440'
  owner 'root'
  group 'root'
#  variables({
#    sudoers_groups: node['authorization']['sudo']['groups'],
#    sudoers_users: node['authorization']['sudo']['users']
#  })
end
