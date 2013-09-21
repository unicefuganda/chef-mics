#
# Cookbook Name:: mics
# Recipe:: default
#
# Copyright 2013, Unicef Uganda 
#
# All rights reserved - Do Not Redistribute

package 'git' do
   action :install
end

#python dependencies

execute 'update system' do
   command 'sudo apt-get update'
   action :run
end

%w{ build-essential python-dev python-setuptools python-pip libpq-dev libxml2 libxml2-dev libxslt1-dev }.each do |pkg|
    package pkg do
	action :install
    end
end

execute 'Install virtual env' do
  command 'pip install virtualenv'
  action :run
end

execute 'create virtual env' do
  cwd '/home/vagrant'
  command 'virtualenv mics_env'
  action :run
end

execute 'owns the mics virtualenv' do
  command 'sudo chown vagrant:vagrant /home/vagrant/mics_env/ -R'
  action :run
end

git "/vagrant/mics/" do
  repository "https://github.com/unicefuganda/mics.git"
  action :checkout
end

execute 'copy localsettings.example' do
	cwd '/vagrant/mics/mics'
	command "cp localsettings.py.example localsettings.py"
	action :run
end

%w{libmemcached-dev  libsasl2-dev libcloog-ppl-dev libcloog-ppl0 }.each do |pkg|
		package pkg
end

package 'postgresql' do
  action :install
end

template "/etc/postgresql/9.1/main/pg_hba.conf" do
  user "postgres"
  source "pg_hba.conf.erb"
end

template "/etc/postgresql/9.1/main/postgresql.conf" do
  user "postgres"
  source "postgresql.conf.erb"
end

service "postgresql" do
  action :restart
end

execute "Create empty database" do
  command "createdb mics_test"
  user "postgres"
  not_if "psql --list | grep mics", :user => 'postgres'
  action :run
end

execute'activating virtual env and installing pip requirements' do
   cwd '/vagrant/mics/'
   command "bash -c 'source /home/vagrant/mics_env/bin/activate && pip install -r pip-requires.txt'"
   action :run
end	

execute "syncdb and run migrations" do
    cwd '/vagrant/mics/'
    command "bash -c 'source /vagrant/mics_env/bin/activate && python manage.py syncdb --noinput --settings=mics.testsettings && python manage.py migrate --settings=mics.testsettings'"
    action :run
end

package 'nginx' do
  action :install
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
end

template "/etc/nginx/conf.d/nginx.conf" do
  source "custom_nginx.conf.erb"
end

service 'nginx' do
  action :restart
end

package 'uwsgi' do
	action :install
end

package 'uwsgi-plugin-python' do
	action :install
end

template '/etc/uwsgi/apps-enabled/mics.ini' do
	source 'custom_mics_uwsgi.ini.erb'
end

template "/etc/uwsgi/apps-available/mics.ini" do
	source 'custom_mics_uwsgi.ini.erb'
end

execute 'Delete /var/www/sockets' do
	command 'rm -rf /var/www/sockets'
	action :run
end

execute 'create /var/www/sockets' do
	command 'mkdir /var/www/ && mkdir /var/www/sockets'
	action :run
end

service 'uwsgi' do
	action :start
end
