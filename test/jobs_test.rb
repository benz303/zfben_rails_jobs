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
    assert jobs.add class: Example, method: :job_0, args: nil
    assert_equal jobs.list, Jobs.new(class: Example, method: :job_0).list
    assert jobs.add class: Example, method: :job, args: 5
    assert_equal jobs.list, [{class: :Example, method: :job_0, args: nil}, {class: :Example, method: :job, args: 5}]
  end
  
  def test_jobs_save
    jobs = Jobs.new
    jobs.add class: Example, method: :job_0
    assert jobs.save
    jobs.destroy
  end
  
  def test_jobs_import
    jobs = Jobs.new
    jobs.add class: Example, method: :job_0
    jobs.save
    jobs2 = Jobs.new
    assert jobs2.import(jobs.id)
    assert_equal jobs.data, jobs2.data
    jobs.destroy
  end
  
  def test_jobs_run
    jobs = Jobs.new
    jobs.add class: Example, method: :job_0
    jobs.add class: Example, method: :job, args: 1
    jobs.save
    assert jobs.run
    assert_equal jobs.result[:successed], 2
    jobs2 = Jobs.new
    jobs2.import jobs.id
    assert jobs2.run
    assert_equal jobs.result[:successed], 2
    jobs.destroy
  end
  
  def test_jobs_run_at
    at = 1.seconds.from_now
    jobs = Jobs.new at: at
    jobs.add class: Example, method: :job_0
    assert !jobs.run
    sleep 2
    assert jobs.run
  end
end
