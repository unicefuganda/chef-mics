require 'chefspec'

describe 'python::default' do

  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'python::default' }

  it 'executes apt-get update' do
    expect(chef_run).to execute_command( "sudo apt-get update")
  end

  it "installs python packages" do

    python_packages_to_install = ["build-essential",
                      "python-setuptools",
                      "python-dev",
                      "python-pip",
                      "libpq-dev",
                      "libxml2",
                      "libxml2-dev",
                      "libxslt1-dev"
                      ]

       python_packages_to_install.each{ |package|
         expect(chef_run).to install_package package
       }
  end

  it "installs python virtual env" do
    expect(chef_run).to execute_command("pip install virtualenv")
  end

  it "changes into vagrant home directory and creates virtual env" do
    expect(chef_run).to execute_command("virtualenv mics_env").with(:cwd => "/home/vagrant")
  end

  it "changes ownership of the mics virtualenv to vagrant user" do
    expect(chef_run).to execute_command("sudo chown vagrant:vagrant /home/vagrant/mics_env/ -R")
  end

end
