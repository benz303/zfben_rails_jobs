# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "zfben_rails_jobs"
  s.version     = '0.0.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben"]
  s.email       = ["ben@zfben.com"]
  s.homepage    = "https://github.com/benz303/zfben_rails_jobs"
  s.summary     = %q{}
  s.description = %q{}
  s.post_install_message =%q{********************************************************************************
  Thank you for using zfben_rails_jobs!
  
  Please follow @zfben on Twitter for announcements, updates, and news.
  https://twitter.com/zfben

********************************************************************************
}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.required_ruby_version     = '>= 1.9'
  
  s.add_dependency 'rails', '>=3.1.0'
  s.add_dependency 'uuid'
  s.add_dependency 'whenever'
  s.add_dependency 'rainbow'
end
