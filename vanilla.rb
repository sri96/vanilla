require 'optparse'
require 'vamlc'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-c", "--compile", "Compile to latex") do |v|
    options[:compile] = v
	p options
	end
	
  opts.on('-a', '--about', 'About the project' ) do|file|
     options[:about] = file
	 p options
   end
   
  
end.parse!