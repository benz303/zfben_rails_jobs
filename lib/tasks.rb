namespace :jobs do
  jobs_root = File.realpath(Rails.root) << '/tmp/jobs/'
  
  desc 'Init Jobs Folders'
  task :init do
    FileUtils.mkdir(jobs_root) unless File.exists? jobs_root
  end
  
  desc 'Start Jobs'
  task :start => :init do
    if File.exists? jobs_root + '/.lock'
      STDERR.print "Jobs are running, please run after they finished.\n"
      exit!
    else
      File.open(jobs_root + '/.lock', 'w'){ |f| f.write Process.pid.to_s }
      print "Starting jobs at process##{Process.pid}\n"
      list = Dir[jobs_root + '*']
      if list.length > 0
        Rake::Task[:environment].execute
        list.each do |id|
          jobs = Jobs.new
          jobs.import File.basename(id)
          jobs.run
        end
      end
      File.delete(jobs_root + '/.lock')
      print "Finished jobs\n"
    end
  end
  
  desc 'Stop Jobs'
  task :stop do
    if File.exists? jobs_root + '/.lock'
      system 'kill `cat ' + jobs_root + '/.lock`'
    end
  end
end
