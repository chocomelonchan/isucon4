set :stage, :production
set :branch, :master
set :node_env, :production

servers = %w(
  104.155.212.181
)

role :app, servers
role :web, servers

# namespace :deploy do
#   before :deploy, 'deploy:push_tags'
# end
