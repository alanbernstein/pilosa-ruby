Gem::Specification.new do |s|
  s.name               = "pilosa"
  s.version            = "0.0.1"
  s.default_executable = "pilosa"  # TODO can this be blank

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
                                                                              s.authors = ["alan@pilosa.com"]
  s.date = %q{2016-11-11}
  s.description = %q{A simple client for the Pilosa bitmap database}
  s.email = %q{alan@pilosa.com}
  s.files = ["Rakefile", "lib/query.rb", "lib/client.rb"]
  s.test_files = ["test/test_query.rb"]
  s.homepage = %q{http://rubygems.org/gems/pilosa}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{2.4.5}
  s.summary = %q{A simple client for the Pilosa bitmap database}

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
