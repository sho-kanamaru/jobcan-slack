namespace :jobcan_task do
  desc "渋谷のシフト"
  task :jobcan => :environment do
    ScrapingShibuya.login_user("shibuya")
  end

  desc "早稲田のシフト"
  task :waseda => :environment do
    ScrapingShibuya.login_user("waseda")
  end
end
