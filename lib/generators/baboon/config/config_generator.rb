require 'rails/generators/base'

module Baboon
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      desc 'Creates a yaml for Baboon at config/baboon.yml'

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def create_initializer_file
        template "baboon.yml", "config/baboon.yml"
      end
    end
  end
end