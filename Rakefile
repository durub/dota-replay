verbose(false) # Don't output commands

task :default do
  puts "Nothing to do. Consider using \"rake -T\" to see available tasks."
end

begin
  require "yard"

  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/*.rb']
    t.options = ['--output-dir', 'doc']
  end
rescue LoadError
  puts "Consider running bundle install"
end

desc "Run specifications"
task :spec do
  sh "rspec spec"
end
