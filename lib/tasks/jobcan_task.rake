namespace :jobcan_task do
  desc "task_sample_jobcan"
  task :jobcan => :environment do
    ScrapingShibuya.login_user("shibuya")
  end
end
