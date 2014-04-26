module Baboon
  class Util
    class << self
      # file_check!
      # @param: String file path
      # @return: Boolean || String depending on if file is found
      def file_check! file
        file.nil? || !file ? false : true
      end

      # locate_baboon_configuration_file
      # Will try and locate the baboon.rb file it it does not exist. Great method
      # used especially for testing Baboon.
      # @param:
      # @return: String[file path, used to locate and initialize the configuration file]
      def locate_baboon_configuration_file
        config_file = nil
        default_baboon_file_path = 'config/baboon.yml'
        if File.exists?(default_baboon_file_path)
          config_file = default_baboon_file_path
        else
          Find.find('.') do |path|
            if path.include?('baboon.yml')
              config_file = path
              break
            end
          end
        end
        config_file
      end
    end # class << self
  end # class Util
end # module Baboon
