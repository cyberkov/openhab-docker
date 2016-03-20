# spec/Dockerfile_spec.rb

require "serverspec"
require "docker"
require "timeout"

describe "Dockerfile" do
  before(:all) do
    @image = Docker::Image.build_from_dir('.', :dockerfile => 'Dockerfile.x86') do |v|
      if (log = JSON.parse(v)) && log.has_key?("stream")
        $stdout.puts log["stream"]
      end
    end
    @container = @image.run('debug')

    set :os, family: :ubuntu
    set :backend, :docker
#    set :docker_image, @image.id
    set :docker_container, @container.id
    set :docker_container
  end
  after(:all) do
#        @image.remove(:force => true)
    @container.kill!
    @container.remove
  end


  describe "basics" do
    it "should exist" do
      expect(@image).not_to be_nil
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
    #EXPOSE 8080 8443 5555
    it "should expose the default ports" do
      expect(@image.json["Config"]["ExposedPorts"].has_key?("8080/tcp")).to be_truthy
      expect(@image.json["Config"]["ExposedPorts"].has_key?("8443/tcp")).to be_truthy
      expect(@image.json["Config"]["ExposedPorts"].has_key?("5555/tcp")).to be_truthy
    end

    # Port tests should be the last one as Java takes some time to load...
    describe "blocking port tests" do
      Timeout::timeout(5*60) do
        describe command('while ! nc -w 1 localhost 8080 2>/dev/null; do echo -n .; sleep 1; done') do
          its(:exit_status) { should eq 0 }
        end
        describe command('while ! nc -w 1 localhost 8443 2>/dev/null; do echo -n .; sleep 1; done') do
          its(:exit_status) { should eq 0 }
        end
      end
    end
  end
end
