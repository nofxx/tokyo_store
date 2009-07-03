# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tokyo_store}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcos Piccinini"]
  s.date = %q{2009-07-03}
  s.email = %q{x@nofxx.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "benchmark/tokyo_store.rb",
     "lib/rack/session/tokyo.rb",
     "lib/tokyo_cache_store.rb",
     "lib/tokyo_store.rb",
     "spec/spec_helper.rb",
     "spec/tokyo_session_store_spec.rb",
     "spec/tokyo_store_rufus_spec.rb",
     "spec/tokyo_store_spec.rb",
     "tokyo_store.gemspec"
  ]
  s.homepage = %q{http://github.com/nofxx/tokyo_store}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Tokyo Tyrant rails session store}
  s.test_files = [
    "spec/tokyo_store_spec.rb",
     "spec/spec_helper.rb",
     "spec/tokyo_store_rufus_spec.rb",
     "spec/tokyo_session_store_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
