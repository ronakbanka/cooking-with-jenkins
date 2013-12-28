#
# Cookbook Name:: cooking-with-jenkins
# Recipe:: define-jenkins-jobs
#
# Adds jobs in Jenkins for testing our cookbooks
#
# Copyright (C) 2013 Zachary Stevens
# 
# All rights reserved - Do Not Redistribute
#

# Add Jenkins job for a repository
repo = "https://github.com/zts/chef-cookbook-managed_directory.git"
job_name = "cookbook-managed_directory"
job_config = File.join(node[:jenkins][:server][:home], "#{job_name}-config.xml")

jenkins_job job_name do
  action :nothing
  config job_config
end

build_command = <<-EOF
bundle install --path .vendor --without integration
bundle exec rake lint
bundle exec rake spec
bundle exec rake kitchen:all
EOF
template job_config do
  source 'cookbook-job.xml.erb'
  variables :git_url => repo, :git_branch => 'master', :command => build_command
  notifies  :update, "jenkins_job[#{job_name}]", :immediately
  notifies  :build, "jenkins_job[#{job_name}]", :immediately
end