class RoobleRailtie < Rails::Generators::Base
  source_root(File.expand_path(File.dirname(__FILE__))

  def copy_initializer
    copy_file 'rooble_initializer.rb', 'config/initializers/rooble.rb'
  end
end