require 'fileutils'

namespace :jobs do
  if defined? Rails
    jobs_root = Rails.root.join('tmp/jobs').to_s
  else
    jobs_root = File.realpath('.') << '/tmp/jobs'
  end

  desc 'Start Jobs'
  task :start do
    system 'rake jobs:run >> log/jobs.log&'
  end
  
  desc 'Run Jobs'
  task :run do
    if defined? Rails
      Rake::Task[:environment].execute
    end
    FileUtils.mkdir(jobs_root) unless File.exists? jobs_root
    File.open(jobs_root + '/.lock', 'w'){ |f| f.write Process.pid.to_s }
    print "Starting jobs at process##{Process.pid}\n"
    loop do
      list = Dir.glob(jobs_root + '/[a-z0-9-]*')
      if list.length > 0
        print "#{list.length} jobs found, running..\n"
        list.each do |id|
          print "Run Job##{id}@#{Time.now.to_s}\n"
          jobs = Jobs.new
          jobs.import File.basename(id)
          print "Jobs detail: #{jobs.data}\n"
          print "Jobs result: #{jobs.run}\n"
        end
      end
      sleep 10
    end
  end
  
  desc 'Stop Jobs'
  task :stop do
    if File.exists? jobs_root + '/.lock'
      system 'kill `cat ' + jobs_root + '/.lock`;rm ' + jobs_root + '/.lock'
    end
  end

  desc 'Clear jobs'
  task :clear do
    system 'rm -r ' + jobs_root + '/*'
  end
end
