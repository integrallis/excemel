Gem::Specification.new do |s|
  s.name = "excemel"
  s.version = "1.1.1"
  s.platform = "java"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Sam-Bodden"]
  s.date = "2013-11-06"
  s.description = "JRuby DSL for XML Building and Manipulation with XPath"
  s.email = "bsbodden@integrallis.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "History.txt",
    "LICENSE",
    "Manifest.txt",
    "Rakefile",
    "lib/excemel.rb",
    "lib/excemel/excemel.rb",
    "lib/java/xom-1.2.10.jar",
    "lib/module/lang.rb",
    "lib/module/xom.rb"
  ]
  s.homepage = "http://github.com/bsbodden/excemel"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "JRuby DSL for XOM"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<blankslate>, ["~> 3.1.2"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 3.7"])
    else
      s.add_dependency(%q<blankslate>, ["~> 3.1.2"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 3.7"])
    end
  else
    s.add_dependency(%q<blankslate>, ["~> 3.1.2"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 3.7"])
  end
end

