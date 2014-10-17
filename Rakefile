desc "run the http server"
task :default do
  sh "ruby app.rb"
end

desc "run the server via rackup"
task :rackup do
  sh "rackup"
end

desc "deploy  heroku app"
task :deploy  do
  sh "git push heroku master"
end

desc "Abre la app en Heroku"
task :app  do
  sh "heroku open"
end

