require 'mina/bundler'
require 'mina/git'
require 'mina/rsync'

set :domain, ENV['domain'] || '104.155.212.181'
set :deploy_to, '/home/isucon/deploy'
set :repository, 'https://github.com/chocomelonchan/isucon4'
set :branch, 'master'

set :rsync_options, ['--rsh=ssh', '--recursive', '--delete', '--delete-excluded', '--exclude', '.git*', '--exclude', '/node_modules']
set :shared_paths, ['log', 'tmp', 'node_modules']

set :user, 'isucon'

desc "Stages rsync"
task "rsync:stage" do
  Dir.chdir settings.rsync_stage do
    system "cd qualifier/webapp/node && npm install"
  end
end

desc "Set envrionments in remote server"
task :environment do
end

desc "Setups remote server."
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/deploy"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/deploy"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/ema"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/ema"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/tile"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/tile"]

  queue! %[mkdir -p "#{deploy_to}/shared/node_modules"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/node_modules"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    queue %{
      curl --data-urlencode "source=でぷろいしまーす" https://idobata.io/hook/custom/1a49caad-d0c8-4cc5-9157-e6e60366a828
    }
    invoke :'rsync:deploy'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    queue %{
      curl --data-urlencode "source=でぷろいしましたー" https://idobata.io/hook/custom/1a49caad-d0c8-4cc5-9157-e6e60366a828
    }
  end
end
