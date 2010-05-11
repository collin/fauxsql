# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fauxsql}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Collin Miller"]
  s.date = %q{2010-05-11}
  s.description = %q{And description}
  s.email = %q{collintmiller@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "Gemfile",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "fauxsql.gemspec",
     "lib/fauxsql.rb",
     "lib/fauxsql/attribute_list.rb",
     "lib/fauxsql/attribute_manymany.rb",
     "lib/fauxsql/attribute_map.rb",
     "lib/fauxsql/attribute_wrapper.rb",
     "lib/fauxsql/attributes.rb",
     "lib/fauxsql/dereferenced_attribute.rb",
     "lib/fauxsql/dsl.rb",
     "lib/fauxsql/list_wrapper.rb",
     "lib/fauxsql/manymany_wrapper.rb",
     "lib/fauxsql/map_wrapper.rb",
     "lib/fauxsql/options.rb",
     "test/helper.rb",
     "test/test_fauxsql.rb"
  ]
  s.homepage = %q{http://github.com/collin/fauxsql}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{This is summary}
  s.test_files = [
    "test/helper.rb",
     "test/test_fauxsql.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_runtime_dependency(%q<datamapper>, [">= 0"])
      s.add_runtime_dependency(%q<do_sqlite3>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.pre"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<datamapper>, [">= 0"])
      s.add_dependency(%q<do_sqlite3>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 3.0.pre"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<datamapper>, [">= 0"])
    s.add_dependency(%q<do_sqlite3>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 3.0.pre"])
  end
end

