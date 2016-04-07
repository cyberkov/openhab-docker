# spec/Dockerfile_spec.rb

require 'spec_helper'

describe "container" do
  before(:all) do
    @container = Docker::Container.create('Cmd' => ['server'], 'Image' => ENV['IMAGE']).start

    set :os, family: :ubuntu
    set :backend, :docker
    set :docker_container, @container.id
    set :docker_container
  end
  after(:all) do
    @container.kill!
    @container.remove
  end

  describe "basics" do
    it "should exist" do
      expect(@container).not_to be_nil
    end

    describe command('uname -p') do
      case ENV['IMAGE'].split(':')[1].split('-')[0]
      when 'amd64'
        its(:stdout) { should match (/x86_64/) }
      when 'arm64'
        its(:stdout) { should match(/arm64/) }
      when 'armhf'
        its(:stdout) { should match(/armhf/) }
      end
    end

    describe user('openhab') do
        it { expect(subject).to exist }
        it { expect(subject).to belong_to_group 'dialout' }
        it { expect(subject).to have_home_directory '/openhab' }
    end
  end

  describe "installed software" do
    packages = %w{ unzip oracle-java8-installer}
    packages.each do |pkg|
      it "should have #{pkg} installed" do
        expect(package(pkg)).to be_installed
      end
    end
  end

  describe "volumes" do
    directories = [ 
      '/openhab',
      '/openhab/conf',
      '/openhab/conf/items',
      '/openhab/conf/persistence',
      '/openhab/conf/rules',
      '/openhab/conf/services',
      '/openhab/conf/sitemaps',
      '/openhab/conf/things',
      '/openhab/conf/transform',
      '/openhab/userdata',
      '/openhab/userdata/logs',
    ]

    directories.each do |dir|
      it "should have a #{dir} directory" do
        expect(file(dir)).to be_directory
        expect(file(dir)).to be_owned_by('openhab')
      end
    end

    files = [ 
      '/openhab/userdata/logs/openhab.log',
      '/openhab/conf/services/addons.cfg',
      '/openhab/conf/services/runtime.cfg',
    ]

    files.each do |ohfile|
      describe file(ohfile) do
        it { expect(subject).to be_file }
        it { expect(subject).to be_owned_by('openhab') }
      end
    end
  end


  describe process("java") do
    it { should be_running }
    its(:user) { should eq "openhab" }
    its(:count) { should eq 1 }
  end

  describe "networking" do
    # Port tests should be the last one as Java takes some time to load...
#    describe "blocking port tests" do
#      Timeout::timeout(5*60) do
#        describe command('while ! nc -w 1 localhost 8080 2>/dev/null; do echo -n .; sleep 1; done') do
#          its(:exit_status) { should eq 0 }
#        end
#        describe command('while ! nc -w 1 localhost 8443 2>/dev/null; do echo -n .; sleep 1; done') do
#          its(:exit_status) { should eq 0 }
#        end
#      end
#    end
  end
end
