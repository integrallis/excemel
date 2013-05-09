#!/usr/bin/env ruby
 
#--
# Copyright &169;2001-2013 Integrallis Software, LLC. 
# All Rights Reserved.
# 
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#++

# encoding: utf-8

# --------------------------------------------------------------------

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

# --------------------------------------------------------------------

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "excemel"
  gem.homepage = "http://github.com/bsbodden/excemel"
  gem.license = "MIT"
  gem.summary = "JRuby DSL for XOM"
  gem.description = "JRuby DSL for XML Building and Manipulation with XPath & XQuery"
  gem.email = "bsbodden@integrallis.com"
  gem.authors = ["Brian Sam-Bodden"]
  gem.platform = "java"
  gem.files = FileList["History.txt", "Manifest.txt", "README.rdoc", "Gemfile", "Rakefile", "LICENSE", "lib/**/*.rb", "lib/java/*.jar"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

# --------------------------------------------------------------------

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

# --------------------------------------------------------------------

require 'simplecov'
SimpleCov.command_name 'Unit Tests'
SimpleCov.start do
  add_group "source", "lib"
end

task :default => :test

# --------------------------------------------------------------------

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "excemel #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# --------------------------------------------------------------------