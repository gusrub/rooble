module Rooble
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Creates the initializer for Rooble"

      def copy_initializer
        template 'config_initializer.rb', 'config/initializers/rooble.rb'
      end
    end
  end
end
