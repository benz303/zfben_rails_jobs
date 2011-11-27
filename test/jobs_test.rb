require File.realpath(File.dirname(__FILE__)) << '/../lib/zfben_rails_jobs.rb'
# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rails/test_help'

Rails.backtrace_cleaner.remove_silencers!

class JobsTest < Test::Unit::TestCase
  def test_jobs_new
    assert_equal Jobs.new.list, []
    assert !Jobs.new.locked?
  end
  
  def test_jobs_add
    jobs = Jobs.new
    assert jobs.add Example, :job_0
    assert_equal jobs.list, [['Example', :job_0, nil]]
    assert jobs.add Example, :job, 5
    assert_equal jobs.list, [['Example', :job_0, nil], ['Example', :job, 5]]
  end
  
  def test_jobs_save
    jobs = Jobs.new
    jobs.add Example, :job_0
    assert jobs.save
  end
  
  def test_jobs_import
    jobs = Jobs.new
    jobs.add Example, :job_0
    jobs.save
    jobs2 = Jobs.new
    assert jobs2.import(jobs.id)
    assert_equal jobs.data, jobs2.data
  end
  
  def test_jobs_run
    jobs = Jobs.new
    jobs.add Example, :job_0
    jobs.add Example, :job, 1
    jobs.save
    assert jobs.run
    assert_equal jobs.result[:successed], 2
    jobs2 = Jobs.new
    jobs2.import jobs.id
    assert jobs2.run
    assert_equal jobs.result[:successed], 2
  end
  
  def test_jobs_run_at
    at = 1.seconds.from_now
    jobs = Jobs.new(at)
    jobs.add Example, :job_0
    assert !jobs.run
    sleep 2
    assert jobs.run
  end
end
