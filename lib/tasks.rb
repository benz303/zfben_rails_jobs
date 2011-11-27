namespace :jobs do
  ROOT = File.realpath(Rails.root) << '/tmp/jobs/'
  
  desc 'Init Jobs Folders'
  task :init do
    FileUtils.mkdir(ROOT) unless File.exists? ROOT
  end
  
  desc 'Start Jobs'
  task :start => :init do
    if File.exists? ROOT + '/.lock'
      STDERR.print "Jobs are running, please run after they finished.\n"
      exit!
    else
      File.open(ROOT + '/.lock', 'w'){ |f| f.write Process.pid.to_s }
      print "Starting jobs at process##{Process.pid}\n"
      list = Dir[ROOT + '*']
      if list.length > 0
        Rake::Task[:environment].execute
        list.each do |id|
          jobs = Job.new
          jobs.import File.basename(id)
          jobs.run
        end
      end
      File.delete(ROOT + '/.lock')
      print "Finished jobs\n"
    end
  end
  
  desc 'Stop Jobs'
  task :stop do
    if File.exists? ROOT + '/.lock'
      system 'kill `cat ' + ROOT + '/.lock`'
    end
  end
end
