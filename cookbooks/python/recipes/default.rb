#
# Cookbook Name:: python
# Recipe:: default
#
# Copyright 2013, ThoughtWorks, Inc
#

execute "install updates" do
  command "sudo apt-get update"
  action :run
end

%w{build-essential python-setuptools python-dev python-pip libpq-dev libxml2 libxml2-dev libxslt1-dev}.each do |pkg|
  package pkg do
    action :install
  end
end

execute "Install virtual env" do
  command "pip install virtualenv"
  action :run
end

execute "Creating mics virtualenv" do
  cwd "/home/vagrant"
  command "virtualenv mics_env"
  action :run
end

execute "Change ownership of mics virtualenv" do
  command "sudo chown vagrant:vagrant /home/vagrant/mics_env/ -R"
  action :run
end