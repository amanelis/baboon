require 'rails/generators/base'

module Baboon
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Creates an initializer for Baboon at config/initializers/baboon.rb'

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def create_initializer_file
        template "baboon.rb", "config/initializers/baboon.rb"
      end
    end
  end
end