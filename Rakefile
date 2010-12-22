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
rescue NameError, LoadError
end

desc "Test specifications"
task :test do
  sh "rspec spec"
end
