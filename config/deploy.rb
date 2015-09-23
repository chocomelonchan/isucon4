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
        invoke 'notify:start_bench'
        execute './benchmarker bench --host localhost | tee ~/bench.log'
        invoke 'notify:finish _bench'
      end
    end
  end
  before 'bench:exec', 'notify:start_bench'
  after  'bench:exec', 'notify:finish_bench'
end

namespace :deploy do
  after :finishing, 'deploy:cleanup'
  after 'deploy:publishing', 'deploy:restart'
  before 'deploy:updated', 'npm:install'
  after 'deploy:restart', 'npm:restart'
  before 'deploy:starting', 'notify:start_deploy'
  after 'deploy', 'notify:finish_deploy'
end
