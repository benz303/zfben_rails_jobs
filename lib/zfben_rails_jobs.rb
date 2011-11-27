require 'fileutils'
require 'rainbow'
require 'uuid'
require 'yaml'

module ZfbenRailsJobs
  if defined? Rails
    class Railtie < Rails::Railtie
      railtie_name :zfben_rails_jobs  
      path = File.realpath(File.dirname(__FILE__))
      rake_tasks do
        require File.join(path, 'tasks.rb')
      end
    end
  end
end

class Jobs
  def import id
    if File.exists?(@path + id)
      yaml = YAML::load(File.read(@path + id))
      @id = yaml[:id]
      @list = yaml[:list]
    else
      false
    end
  end
  
  def add cls, method, args = nil
    unless locked?
      @list.push [cls.to_s, method, args]
      true
    else
      false
    end
  end
  
  def save
    unless locked?
      @locked = true
      File.open(@path + @id, 'w'){ |f| f.write data.to_yaml }
      true
    else
      false
    end
  end
  
  def id
    @id
  end
  
  def list
    @list
  end
  
  def data
    { id: @id, list: @list, at: @at }
  end
  
  def result
    successed = 0
    failed = 0
    pending = 0
    @list.map{ |l|
      if l.length < 4
        pending = pending + 1
      elsif l[3]
        successed = successed + 1
      else
        failed = failed + 1
      end
    }
    { successed: successed, failed: failed, pending: pending }
  end
  
  def finished?
    r = result
    r[:failed] == 0 && r[:pending] == 0
  end
  
  def locked?
    @locked
  end
  
  def run
    unless @at.nil?
      if Time.now < @at
        return false
      end
    end
    
    @locked = true
    
    @list.each_index do |i|
      if !@list[i][3]
        unless Object.const_defined?(@list[i][0])
          @list[i].push false, 'Class missing'
          next
        end
        
        obj = Object.const_get(@list[i][0])
        
        unless obj.respond_to?(@list[i][1])
          @list[i].push false, 'Method missing'
          next
        end
        
        obj.send @list[i][1], *@list[i][2]
        
        @list[i].push true, 'Finished'
      end
    end
    
    update
    true
  end
  
  private
  
  def initialize at = nil
    @id = UUID.new.generate
    @list = []
    @path = File.realpath(Rails.root) + '/tmp/jobs/'
    FileUtils.mkdir(@path) unless File.exists?(@path)
    @locked = false
    @at = at
  end
  
  def update
    if File.exists? @path + @id
      if finished?
        File.delete @path + @id
      else
        File.open(@path + @id, 'w'){ |f| f.write data.to_yaml }
      end
    end
  end
end
