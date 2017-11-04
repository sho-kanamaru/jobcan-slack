namespace :jobcan_task do

  desc "全拠点のシフト"
  task :all_group => :environment do
    Scraping.login_user
  end

  desc "渋谷校のシフト"
  task :shibuya => :environment do
    ScrapingShibuya.login_user("shibuya")
  end
  desc "早稲田校のシフト"
  task :waseda => :environment do
    ScrapingShibuya.login_user("waseda")
  end
  desc "池袋校のシフト"
  task :ikebukuro => :environment do
    ScrapingShibuya.login_user("ikebukuro")
  end
  desc "新宿校のシフト"
  task :shinjuku => :environment do
    ScrapingShibuya.login_user("shinjuku")
  end
  desc "東京駅前校のシフト"
  task :tokyo => :environment do
    ScrapingShibuya.login_user("tokyo")
  end
  desc "御茶ノ水校のシフト"
  task :ochanomizu => :environment do
    ScrapingShibuya.login_user("ochanomizu")
  end
  desc "エキスパートのシフト"
  task :expert => :environment do
    ScrapingShibuya.login_user("expert")
  end
  desc "名古屋校のシフト"
  task :nagoya => :environment do
    ScrapingShibuya.login_user("nagoya")
  end
  desc "梅田校のシフト"
  task :umeda => :environment do
    ScrapingShibuya.login_user("umeda")
  end
end
