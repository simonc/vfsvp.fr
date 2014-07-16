require 'bundler/setup'
require 'sinatra/base'

require 'newrelic_rpm'
ENV['NEW_RELIC_LICENSE_KEY'] && RACK_ENV = 'production'

# The project root directory
$root = ::File.dirname(__FILE__)

use Rack::Deflater

class SinatraStaticServer < Sinatra::Base

  get(/(.*apprendre-angular-en-un-jour-le-guide-ultime.*)/) do
    redirect to('http://www.tinci.fr/blog/apprendre-angular-en-un-jour-le-guide-ultime/')
  end

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  not_found do
    send_file(File.join(File.dirname(__FILE__), 'public', '404.html'), {:status => 404})
  end

  def send_sinatra_file(path, &missing_file_block)
    file_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i
    File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  end

end

run SinatraStaticServer
