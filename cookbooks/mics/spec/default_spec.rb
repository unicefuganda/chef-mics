require 'chefspec'

describe 'mics::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'mics::default' }

describe 'Install git'do

    it 'installs git package' do
	expect(chef_run).to install_package 'git'
    end
end

describe 'python and its dependencies' do
   
  it 'executes apt-get update' do
     expect(chef_run).to execute_command('sudo apt-get update')
   end

   it 'installs python dependencies' do
    ['build-essential',
    'python-dev', 
    'python-setuptools', 
    'python-pip',
    'libpq-dev',
    'libxml2',
    'libxml2-dev',
    'libxslt1-dev']
    .each {|package|
	expect(chef_run).to install_package package  
      }
   end

   it 'installs virtual env' do
      expect(chef_run).to execute_command('pip install virtualenv')
    end
 
    it 'creates the mics virtual env' do
       expect(chef_run).to execute_command('virtualenv mics_env').with(:cwd =>'/home/vagrant')
   end
  
    it 'changes ownership of the virtual env' do
      expect(chef_run).to execute_command('sudo chown vagrant:vagrant /home/vagrant/mics_env/ -R')
   end

 end
 
describe 'Mics project configuration' do
   
   it 'it activates virtualenv and installs requirements' do
       expect(chef_run).to execute_command("bash -c 'source /home/vagrant/mics_env/bin/activate && pip install -r pip-requires.txt'").with(:cwd =>'/vagrant/mics/')
   end

   it 'syncs the database and runs migrations and 'do
	    command="bash -c 'source /vagrant/mics_env/bin/activate && python manage.py syncdb --noinput && python manage.py migrate'"
      expect(chef_run).to execute_command(command).with(:cwd =>'/vagrant/mics/')
   end
end
end
