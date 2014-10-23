desc "run the http server"
task :default do
   sh "cp config/config_local.yml config/config.yml"
  sh "ruby app.rb"
end
=begin
desc "run the server via rackup"
task :rackup do
  sh "rackup"
end
=end
desc "Open app in Heroku"
task :app  do
  sh "heroku open"
end

desc "Open repository"
task :repo do
  sh "gnome-open https://github.com/alu0100207385/SYTW_p4"
end

