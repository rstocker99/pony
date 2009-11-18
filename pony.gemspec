# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pony}
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Adam Wiggins", "maint: Ben Prew"]
  s.date = %q{2009-11-13}
  s.description = "Send email in one command: Pony.mail(:to => 'someone@example.com', :body => 'hello')"
  s.email = %q{ben.prew@gmail.com}
  s.files = ["README.rdoc", "Rakefile", "lib/pony.rb", "pony.gemspec", "spec/base.rb", "spec/pony_spec.rb"]
  s.has_rdoc = false
  s.homepage = %q{http://github.com/benprew/pony}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = s.description
  s.add_dependency('tmail', '>= 1.2.3')
  s.add_dependency('mime-types', '>= 1.16')
end
