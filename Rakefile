require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Build and push the gem to RubyGems"
task :release do
  sh "nix develop -c gem build"
  sh "nix develop -c gem push *.gem"
end
