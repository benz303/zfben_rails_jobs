class Example
  class << self
    def job n
      p 'job ' + n.to_s
      sleep n
    end
    
    def job_0
      p 'job 0'
    end
  end
end
