PROJECT_ROOT = File.expand_path(File.dirname(__FILE__))
$: << File.join(PROJECT_ROOT, 'lib')
 
require 'rubygems'
require 'jeweler'
require 'spec/rake/spectask'
 
Jeweler::Tasks.new do |s|
  s.name = 'ruby-adt'
  s.description = 'A small fast library for reading Advantage Database Server database files (ADT).'
  s.summary = 'Read ADT files'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Chase Gray']
  s.email = 'chase@ratchetsoftware.com'
  s.add_dependency('activesupport', ['>= 2.1.0'])
  s.homepage = 'http://github.com/chasemgray/Ruby-ADT'
end

Jeweler::GemcutterTasks.new
 
task :default => :spec
 
desc "Run specs"
Spec::Rake::SpecTask.new :spec do |t|
  t.spec_files = FileList['spec/**/*spec.rb']
end
 
desc "Run spec docs"
Spec::Rake::SpecTask.new :specdoc do |t|
  t.spec_opts = ["-f specdoc"]
  t.spec_files = FileList['spec/**/*spec.rb']
end