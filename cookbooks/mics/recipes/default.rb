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

execute'activating virtual env and installing pip requirements' do
   cwd '/vagrant/mics/'
   command "bash -c 'source /home/vagrant/mics_env/bin/activate && pip install -r pip-requires.txt'"
   action :run
end	

execute "syncdb and run migrations" do
    cwd '/vagrant/mics/'
    command "bash -c 'source /vagrant/mics_env/bin/activate && python manage.py syncdb --noinput && python manage.py migrate'"
    action :run
end