set :application, 'isucon'
set :repo_url, 'git@github.com:chocomelonchan/isucon4.git'
set :user, 'isucon'

ask :branch, :master

set :nvm_type, :user
set :nvm_node, 'v4.1.0'
set :nvm_map_bins, %w{node npm}

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
  # ここにベンチするコードを書く
  # nodeを起動するやつをnpm.capへ集める
end

namespace :deploy do
  desc 'Add and push deploy tags'
  task :push_tags do
    user = `git config --get user.name`.chomp
    email = `git config --get user.email`.chomp
    time = Time.now.strftime('%Y%m%d-%H%M')

    puts `git fetch origin`
    puts `git tag #{time} -m "Deployed by #{user} <#{email}>" origin/#{fetch(:branch)}`
    puts `git push --tags origin`
  end

  after :finishing, 'deploy:cleanup'
  after 'deploy:publishing', 'deploy:restart'
  before 'deploy:updated', 'npm:install'
  # after 'deploy:restart', 'npm:restart'
  before 'deploy:starting', 'notify:start'
  after 'deploy', 'notify:finish'
end
