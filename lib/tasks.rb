require 'fileUtils'
require 'rainbow'

namespace :jobs do
  desc 'Init Jobs Folders'
  task :init do
    FileUtils.mkdir(Rails.root.join('/tmp/jobs'))
  end
  
  task :run do
    
  end
end
