require 'chefspec'

describe 'git::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'git::default' }
  it 'should do something' do
    expect(chef_run).to install_package 'git'
  end
end
