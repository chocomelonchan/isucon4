set :application, 'isucon'
set :repo_url, 'git@github.com:chocomelonchan/isucon4.git'
set :user, 'isucon'

ask :branch, :master

set :ssh_options,
  auth_methods: %w(publickey),
  user: fetch(:user)

SSHKit.config.command_map[:rake] = 'bundle exec rake'

set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}"
set :scm, :git

set :rsync_options, %w[--exclude=.git --exclude=current/qualifier/webapp/node/node_modules/]
set :linked_dirs, %w(qualifier/webapp/node/node_modules)
set :keep_releases, 20

namespace :bench do
  task :exec do
    on roles(:app), in: :parallel, limit: 4 do
      within "/home/#{fetch(:user)}" do
        execute './benchmarker bench --host localhost:8080 | tee ~/bench.log'
        execute 'curl --silent --data-urlencode "format=html" --data-urlencode "source=<span style=\'color:white\' class=\'label label-primary\'>bench</span><br><code>`cat ~/bench.log`</code>" https://idobata.io/hook/custom/1a49caad-d0c8-4cc5-9157-e6e60366a828'
      end
    end
  end
end

namespace :deploy do
  after :finishing, 'deploy:cleanup'
  after 'deploy:publishing', 'deploy:restart'
  before 'deploy:updated', 'npm:install'
  after 'deploy:restart', 'npm:restart'
  before 'deploy:starting', 'notify:start'
  after 'deploy', 'notify:finish'
end
