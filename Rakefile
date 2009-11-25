#!/usr/bin/env ruby
 
#--
# Copyright &169;2001-2008 Integrallis Software, LLC. 
# All Rights Reserved.
# 
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#++

require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'
begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end

# --------------------------------------------------------------------

desc "Default Task"
task :default => :test_all

# Test Tasks ---------------------------------------------------------

desc "Run all tests"
task :test_all => [:test_units]
task :ta => [:test_all]

task :tu => [:test_units]

Rake::TestTask.new("test_units") do |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose = false
end

# Create RDOC documentation ------------------------------------------

rd = Rake::RDocTask.new("rdoc") { |rdoc|
  rdoc.rdoc_dir = 'html/rdoc'
  rdoc.title    = "Excemel"
  rdoc.options << '--line-numbers' << '--inline-source' << '--main' << 'README'
  rdoc.rdoc_files.include('lib/**/*.rb', '[A-Z]*', 'doc/**/*.rdoc')
  rdoc.template = 'jamis'
}

task :filelist do
  puts FileList['pkg/**/*'].inspect
end

# Hoe down ------------------------------------------------------------
begin
  MANIFEST = FileList["History.txt", "Manifest.txt", "README.txt", 
    "Rakefile", "LICENSE", "lib/**/*.rb", "lib/java/xom-1.1.jar"]

  file "Manifest.txt" => :manifest
  task :manifest do
    File.open("Manifest.txt", "w") {|f| MANIFEST.each {|n| f << "#{n}\n"} }
  end
  Rake::Task['manifest'].invoke # Always regen manifest, so Hoe has up-to-date list of files

  require 'hoe'
  Hoe.new("excemel", "0.0.1") do |p|
    p.rubyforge_name = "excemel"
    p.url = "http://excemel.rubyforge.org"
    p.author = "Brian Sam-Bodden"
    p.email = "bsbodden@integrallis.com"
    p.summary = "JRuby DSL for XOM"
    p.platform = 'jruby'
    p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
    p.description = p.paragraphs_of('README.txt', 0...1).join("\n\n")
    p.extra_deps.reject!{|d| d.first == "hoe"}
  end
rescue LoadError
  puts "You really need Hoe installed to be able to package this gem"
end