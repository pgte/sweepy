# Install hook code here

require 'fileutils'

conf_path = File.join(RAILS_ROOT, 'config', 'sweepy.yml')
if(!File.exists?(conf_path))
  FileUtils.cp(File.join(File.dirname(__FILE__), 'templates', 'sweepy.yml'), conf_path)
end

