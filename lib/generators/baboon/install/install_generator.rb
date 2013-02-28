require 'rails/generators/base'

module Baboon
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Creates an initializer for Baboon at config/baboon.yml'
      source_root File.expand_path('../templates', __FILE__)
      
      def create_initializer_file
        template 'baboon.yml', 'config/baboon.yml'
      end
    end
  end
end