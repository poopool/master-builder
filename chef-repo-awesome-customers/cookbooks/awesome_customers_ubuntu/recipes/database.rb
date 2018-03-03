#
# Cookbook:: awesome_customers_ubuntu
# Recipe:: database
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Configure the MySQL client.
mysql_client 'default' do
  action :create
end

link "/sbin/insserv" do
    to "/usr/lib/insserv/insserv"
  end

# Configure the MySQL service.
mysql_service 'default' do
  initial_root_password node['awesome_customers_ubuntu']['database']['root_password']
  provider provider Chef::Provider::MysqlServiceSysvinit
  action [:create, :start]
end

# Install the mysql2 Ruby gem.
mysql2_chef_gem 'default' do
  action :install
end

# Create the database instance.
mysql_database node['awesome_customers_ubuntu']['database']['dbname'] do
  connection(
    :host => node['awesome_customers_ubuntu']['database']['host'],
    :username => node['awesome_customers_ubuntu']['database']['root_username'],
    :password => node['awesome_customers_ubuntu']['database']['root_password']
  )
  action :create
end

# Add a database user.
mysql_database_user node['awesome_customers_ubuntu']['database']['admin_username'] do
  connection(
    :host => node['awesome_customers_ubuntu']['database']['host'],
    :username => node['awesome_customers_ubuntu']['database']['root_username'],
    :password => node['awesome_customers_ubuntu']['database']['root_password']
  )
  password node['awesome_customers_ubuntu']['database']['admin_password']
  database_name node['awesome_customers_ubuntu']['database']['dbname']
  host node['awesome_customers_ubuntu']['database']['host']
  action [:create, :grant]
end

# Create a path to the SQL file in the Chef cache.
create_tables_script_path = File.join(Chef::Config[:file_cache_path], 'create-tables.sql')

# Write the SQL script to the filesystem.
cookbook_file create_tables_script_path do
  source 'create-tables.sql'
  owner 'root'
  group 'root'
  mode '0600'
end

# Seed the database with a table and test data.
execute "initialize #{node['awesome_customers_ubuntu']['database']['dbname']} database" do
  command "mysql -h #{node['awesome_customers_ubuntu']['database']['host']} -u #{node['awesome_customers_ubuntu']['database']['admin_username']} -p#{node['awesome_customers_ubuntu']['database']['admin_password']} -D #{node['awesome_customers_ubuntu']['database']['dbname']} < #{create_tables_script_path}"
  not_if  "mysql -h #{node['awesome_customers_ubuntu']['database']['host']} -u #{node['awesome_customers_ubuntu']['database']['admin_username']} -p#{node['awesome_customers_ubuntu']['database']['admin_password']} -D #{node['awesome_customers_ubuntu']['database']['dbname']} -e 'describe customers;'"
end
