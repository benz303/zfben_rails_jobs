require 'uuid'

module ZfbenRailsJobs
  class Railtie < Rails::Railtie
      railtie_name :zfben_rails_jobs  
      path = File.realpath(File.dirname(__FILE__))
      rake_tasks do
        require File.join(path, 'jobs.rake')
      end
    end
end
