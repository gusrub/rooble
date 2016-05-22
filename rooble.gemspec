# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rooble/version'

Gem::Specification.new do |spec|
  spec.name        = 'rooble'
  spec.version     = '0.1.0'
  spec.authors     = ["Gustavo Rubio"]
  spec.email       = 'gus@ahivamos.net'

  spec.summary     = "Allows to paginate and search through ActiveRecord associations in rails."
  spec.description = "Yet another unnecessary and selfishly-created pagination and search gem for rails. This gem will add methods to your ActiveRecord associations and classes so you can search and paginate."
  spec.homepage    = 'http://github.com/gusrub/rooble'
  spec.license     = 'MIT'
  spec.date        = Date.today.to_s
  spec.require_paths = ["lib"]
  spec.files       = ["lib/rooble.rb", "lib/rooble/version.rb"]
  spec.platform    = Gem::Platform::RUBY
  spec.post_install_message = "Here, have a cookie for installing this wonderful gem: 🍪"

  spec.add_dependency 'activesupport', '~> 4.0', '>= 4.0.0'
  spec.add_dependency 'activerecord', '~> 4.0', '>= 4.0.0'

  spec.add_development_dependency 'bundler', '~> 1.0', '>= 1.0.0'
  spec.add_development_dependency "rake", "~> 10.0"
end
