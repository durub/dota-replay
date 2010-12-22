verbose(false) # Don't output commands

task :default do
  puts "Nothing to do. Consider using \"rake -T\" to see available tasks."
end

desc "Generate documentation"
task :doc do
  sh "yardoc"
end

desc "Test specifications"
task :test do
  sh "rspec spec"
end
