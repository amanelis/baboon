require 'spec_helper'

describe Baboon::Cli do
  describe "#initialize" do
    before do
      $stdout.sync ||= true
    end
    
    context "when a proper configuration file is in the current path" do
      context "when `baboon` is called from the command line with no parameters" do
        it "gives the proper output and usage for baboon" do
          content = capture(:stdout) { Baboon::Cli.start([]) }
          expect(content).to match(/Tasks:\n/)
          expect(content).to match(/configuration  # Shows the current configuration for baboon.\n/)
          expect(content).to match(/deploy         # Deploys the application to the configured servers.\n/)
          expect(content).to match(/help \[TASK\]    # Describe available tasks or one specific task\n\n/)
        end
      end
      
      context "when `baboon configuration` is called from the command line" do
        it "it lists the configuration settings for the current baboon installation" do
          content = capture(:stdout) { Baboon::Cli.start(['configuration']) }
          expect(content).to match(/Baboon\[Application\]: console/)
          expect(content).to match(/Baboon\[Repository\]: git@github.com:128lines\/console.fm.git/)
          expect(content).to match(/Baboon\[Deploy_path\]: \/home\/rails\/console.fm\//)
          expect(content).to match(/Baboon\[Deploy_user\]: :rails/)
          expect(content).to match(/Baboon\[Branch\]: :master/)
          expect(content).to match(/Baboon\[Rails_env\]: :production/)
          expect(content).to match(/Baboon\[Servers\]: \[\"10.0.0.1\", \"10.0.0.1\"\]/)
        end
      end
    end 
  end #intiailize do
end #describe Baboon::Cli do