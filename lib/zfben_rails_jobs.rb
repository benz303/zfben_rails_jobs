require 'fileutils'
require 'uuid'
require 'yaml'

module ZfbenRailsJobs
  if defined? Rails
    class Railtie < ::Rails::Railtie
      railtie_name :zfben_rails_jobs  
      path = ::File.realpath(::File.dirname(__FILE__))
      rake_tasks do
        require ::File.join(path, 'tasks.rb')
      end
    end
  end
end

if !defined?(Rails) && defined?(Rake)
  require File.join(File.dirname(__FILE__), 'tasks.rb')
end

class Jobs
  def import id
    if File.exists?(@data[:dir] + id)
      @data = merge ::YAML::load_file(@data[:dir] + id)
      true
    else
      false
    end
  end
  
  def add opts = {}
    unless locked?
      [:class, :method].each{ |key|
        opts[key] = opts[key].to_s.to_sym
      }
      @data[:list].push opts
      true
    else
      false
    end
  end
  
  def save
    unless locked?
      @data[:locked] = true
      ::File.open(path, 'w'){ |f| f.write @data.to_yaml }
      true
    else
      false
    end
  end
  
  def destroy
    if ::File.exists? path
      ::File.delete path
    end
    @data = merge
  end
  
  def id
    @data[:id]
  end
  
  def list
    @data[:list]
  end
  
  def data
    @data
  end
  
  def path
    @data[:dir] + @data[:id]
  end
  
  def result
    successed = 0
    failed = 0
    pending = 0
    @data[:list].each{ |job|
      next if job.nil?
      if job.has_key? :status
        case job[:status]
        when :successed
          successed = successed + 1
        when :failed
          failed = failed + 1
        else
          pending = pending + 1
        end
      else
        pending = pending + 1
      end
    }
    { successed: successed, failed: failed, pending: pending, total: @data[:list].length }
  end
  
  def finished?
    r = result
    r[:failed] == 0 && r[:pending] == 0
  end
  
  def locked?
    @data[:locked]
  end
  
  def run
    unless @data[:at].nil?
      if ::Time.now < @data[:at]
        return false
      end
    end
    
    @data[:locked] = true
    
    @data[:list].map!{ |job|
      if !job.has_key?(:status) || job[:status] != :successed
        if job[:class] != :eval
          unless Object.const_defined?(job[:class])
            job[:status] = :failed
            job[:status_msg] = 'Class missing'
            next
          end
          
          obj = Object.const_get(job[:class])
          
          unless obj.respond_to?(job[:method])
            job[:status] = :failed
            job[:status_msg] = 'Method missing'
            next
          end
          
          begin
            obj.send job[:method], *job[:args]
          rescue => e
            job[:status] = :failed
            job[:status_msg] = e
            next
          end
        else
          begin
            Kernel.eval job[:method].to_s
          rescue => e
            job[:status] = :failed
            job[:status_msg] = e
            next
          end
        end
        job[:status] = :successed
      end
      job
    }
    
    if ::File.exists? path
      if finished?
        ::File.delete path
      else
        ::File.open(path, 'w'){ |f| f.write data.to_yaml }
      end
    end
    true
  end
  
  private
  
  
  def initialize opts = {}
    @data = merge opts
    ::FileUtils.mkdir(@data[:dir]) unless ::File.exists?(@data[:dir])
    if @data.has_key?(:class)
      add class: @data[:class], method: @data[:method], args: @data[:args]
      @data.delete :class
      @data.delete :method
      @data.delete :args
    end
  end
  
  def merge opts = {}
    {
      id: UUID.new.generate,
      list: [],
      at: nil,
      locked: false,
      dir: (defined?(::Rails) ? ::File.realpath(::Rails.root) : ::File.realpath('.')) << '/tmp/jobs/'
    }.merge(opts)
  end
end
