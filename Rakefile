require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "tokyo_store"
    gem.summary = "Tokyo Tyrant rails session store"
    gem.email = "x@nofxx.com"
    gem.homepage = "http://github.com/nofxx/tokyo_store"
    gem.authors = ["Marcos Piccinini"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

task :default => :spec

