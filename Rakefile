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
require 'coveralls'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

# --------------------------------------------------------------------

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

# --------------------------------------------------------------------

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