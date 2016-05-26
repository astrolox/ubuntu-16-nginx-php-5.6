require 'serverspec'
require 'docker'

#Include Tests
base_spec_dir = Pathname.new(File.join(File.dirname(__FILE__)))
Dir[base_spec_dir.join('../../drone-tests/shared/**/*.rb')].sort.each { |f| require_relative f }

if not ENV['IMAGE'] then
  puts "You must provide an IMAGE env variable"
end

LISTEN_PORT=8080
CONTAINER_START_DELAY=2

RSpec.configure do |c|
  @image = Docker::Image.get(ENV['IMAGE'])
  set :backend, :docker
  set :docker_image, @image.id
  set :docker_container_create_options, {
    'User'     => '100000',
    'HostConfig'   => {
      'PortBindings' => {
        "#{LISTEN_PORT}/tcp" => [ { 'HostPort' => "#{LISTEN_PORT}" } ]
      }
    }
  }

  describe "tests" do
    include_examples 'docker-ubuntu-16'
    include_examples 'docker-ubuntu-16-nginx-1.10.0'
    include_examples 'php-5.6-tests'
  end
end
