require_relative './lib/version.rb'
Gem::Specification.new do |s|
  s.name        = "gosu_wrapper"
  s.version     = GosuWrapper::VERSION
  s.date        = "2017-03-21"
  s.summary     = "wrawrapper for gosu 2d game lib"
  s.description = ""
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["maxpleaner"]
  s.email       = 'maxpleaner@gmail.com'
  s.required_ruby_version = '~> 2.3'
  s.homepage    = "http://github.com/maxpleaner/gosu_wrapper"
  s.files       = Dir["lib/**/*.rb", "bin/*", "**/*.md", "LICENSE"]
  s.require_path = 'lib'
  s.required_rubygems_version = ">= 2.5.1"
  s.executables = Dir["bin/*"].map &File.method(:basename)
  s.add_dependency 'gosu'
  s.add_dependency 'activesupport'
  s.license     = 'MIT'
end
