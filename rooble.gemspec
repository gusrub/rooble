Gem::Specification.new do |s|
  s.name        = 'rooble'
  s.version     = '0.0.1'
  s.date        = '2016-04-05'
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Yet another unnecessary and selfishly-created pagination and search gem for rails"
  s.description = "Allows to paginate and search through ActiveRecord associations"
  s.authors     = ["Gustavo Rubio"]
  s.email       = 'gus@ahivamos.net'
  s.files       = ["lib/rooble.rb"]
  s.homepage    = 'http://github.com/gusrub/rooble'
  s.license     = 'MIT'
  s.add_dependency 'activesupport', '~> 4.0', '>= 4.0.0'
  s.add_development_dependency 'bundler', '~> 1.0', '>= 1.0.0'
end