require 'rake'
require 'rake/clean'
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

CLEAN.include('pkg/', 'tmp/')

$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'enc/version'

RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:cucumber)

task :bump do
  v = Gem::Version.new("#{Enc::VERSION}.0")
  s = <<-EOS
module Enc
  VERSION = '#{v.bump}'
end
EOS

  File.open('lib/enc/version.rb', 'w') do |file|
    file.print s
  end
  sh 'git add lib/enc/version.rb'
  sh "git commit -m 'Bump version'"
end

task :tag do
  v = Enc::VERSION
  tags = `git ls-remote --tags`.split("\t")

  unless tags.include?("refs/tags/#{v}\n")
    sh "git tag #{v}" unless `git tag`.split("\n").include?(v)
    sh 'git push origin --tags'
  end
end

task default: [:spec, :cucumber]
