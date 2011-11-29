namespace :jobs do
  jobs_root = File.realpath(Rails.root) << '/tmp/jobs/'
  
  desc 'Init Jobs Folders'
  task :init do
    FileUtils.mkdir(jobs_root) unless File.exists? jobs_root
  end
  
  desc 'Start Jobs'
  task :start => [:init, :environment] do
    print "Starting jobs at process##{Process.pid}\n"
    loop do
      list = Dir[jobs_root + '*']
      if list.length > 0
        print "#{list.length} jobs found, running..\n"
        list.each do |id|
          print "Run Job##{id}@#{Time.now.to_s}\n"
          jobs = Jobs.new
          jobs.import File.basename(id)
          print "Jobs detail: #{jobs.data}\n"
          jobs.run
        end
      else
        print "No job found, skipping..\n"
      end
      sleep 10
    end
  end
  
  desc 'Stop Jobs'
  task :stop do
    if File.exists? jobs_root + '/.lock'
      system 'kill `cat ' + jobs_root + '/.lock`'
    end
  end
end
