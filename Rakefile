require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "tokyo_store"
    gem.summary = %Q{TODO}
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

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |spec|
    spec.libs << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tokyo_store #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

