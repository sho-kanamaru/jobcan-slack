class Scraping

  def self.login_user
    Shift.delete_all
    @@count = 0
    @@group_list = ["vr", "waseda", "tokyo", "ikebukuro", "shinjuku", "ochanomizu", "expert", "umeda", "nagoya"]
    caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {binary: "/app/.apt/usr/bin/google-chrome", args: ["--headless"]})
    @@driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
    @@driver.navigate.to 'https://ssl.jobcan.jp/login/client/?url=https%3A%2F%2Fssl.jobcan.jp%2Fclient%2F'

    company_id = @@driver.find_element(:id, 'client_login_id')
    company_id.send_keys(ENV["COMPANY_ID"])

    client_manager_id = @@driver.find_element(:id, 'client_manager_login_id')
    client_manager_id.send_keys(ENV["CLIENT_MANAGER_ID"])

    password = @@driver.find_element(:id, 'client_login_password')
    password.send_keys(ENV["PASSWORD"])

    @@driver.find_element(:xpath, '/html/body/div/div[1]/form/div[5]/button').click
    move_to_schedule_page
  end

  def self.move_to_schedule_page
    e = @@driver.find_element(:xpath, '//*[@id="header"]/div[2]/div/ul/li[2]/a')
    @@driver.mouse.move_to(e) ##シフト管理ボタンにマウスオーバー
    @@driver.find_element(:xpath, '//*[@id="shift-manage-menu"]/ul/li[2]/dl/dt/a').click

    select_group = Selenium::WebDriver::Support::Select.new(@@driver.find_element(:id, 'group_id'))

    select_type = Selenium::WebDriver::Support::Select.new(@@driver.find_element(:id, 'type-combo')) #追加
    select_type.select_by(:value, 'day2') #追加

    select_date = Selenium::WebDriver::Support::Select.new(@@driver.find_element(:name, 'from[day2][d]')) #追加
    select_date.select_by(:value, "#{Date.tomorrow.day}") #追加

    select_group.select_by(:value, '30')
    @@location = "shibuya"

    @@driver.find_element(:xpath, '//*[@id="with_child_groups"]').click

    if Date.today.strftime("%-d").to_i == date = Date.new(Time.now.year, Time.now.month, -1).day
      select_month = Selenium::WebDriver::Support::Select.new(@@driver.find_element(:name, 'from[day2][m]')) #追加
      select_month.select_by(:value, (Date.today >> 1).month.to_s) #追加
    end

    if Date.today.strftime("%-d").to_i == Date.new(Time.now.year, Time.now.month, -1).day && Date.today.strftime("%-m").to_i == 12
      select_date = Selenium::WebDriver::Support::Select.new(@@driver.find_element(:name, 'from[day2][y]')) #追加
      select_date.select_by(:value, "#{Date.tomorrow.year}") #追加
    end

    @@driver.find_element(:xpath, '//*[@id="search"]/div[1]/a/div').click ##表示ボタンをクリック(デフォルトで9/1~9/30になっているため、ボタンクリックだけでOK)
    get_shift_schedule
  end

  def self.change_group(group)
    @@count += 1
    select_group = Selenium::WebDriver::Support::Select.new(@@driver.find_element(:id, 'group_id'))
    if group == "vr"
      select_group.select_by(:value, '43') ##VR
    elsif group == "waseda"
      select_group.select_by(:value, '33') ##早稲田
    elsif group == "tokyo"
      select_group.select_by(:value, '36') ##東京駅前
    elsif group == "ikebukuro"
      select_group.select_by(:value, '37') ##池袋
    elsif group == "shinjuku"
      select_group.select_by(:value, '38') ##新宿
    elsif group == "ochanomizu"
      select_group.select_by(:value, '41') ##御茶ノ水
    elsif group == "expert"
      select_group.select_by(:value, '42') ##エキスパート
    elsif group == "umeda"
      select_group.select_by(:value, '31') ##梅田
    elsif group == "nagoya"
      select_group.select_by(:value, '40') ##名古屋
    end
    @@location = group

    @@driver.find_element(:xpath, '//*[@id="search"]/div[1]/a/div').click ##表示ボタンをクリック
    get_shift_schedule
  end

  def self.get_shift_schedule
    begin
      @@driver.find_element(:xpath, "//*[@id='shift-list']/tr[3]")
      mentor_num = 3
      mentor_count = @@driver.find_elements(:xpath, "//*[@id='shift-list']/tr").size
      while mentor_num <= mentor_count do
        name = @@driver.find_element(:xpath, "//*[@id='shift-list']/tr[#{mentor_num}]/td[1]").text.sub(" ", "")
        time = @@driver.find_element(:xpath, "//*[@id='shift-list']/tr[#{mentor_num}]/td[2]").text
        time_num = 3
        time_count = @@driver.find_elements(:xpath, "//*[@id='shift-list']/tr[#{mentor_num}]/td").size
        shift_type = []
        while time_num <= time_count do
          if @@driver.find_element(:xpath, "//*[@id='shift-list']/tr[#{mentor_num}]/td[#{time_num}]").text == ""
          else
            shift_type << @@driver.find_element(:xpath, "//*[@id='shift-list']/tr[#{mentor_num}]/td[#{time_num}]").text
          end
          time_num += 1
        end
        shift_type.uniq!
        mentor_name = User.where(name: name).first_or_initialize
        mentor_name.save
        if shift_type.size == 0
          Shift.create(time: time, user_id: mentor_name.id, location: @@location)
        elsif shift_type.size == 1
          if shift_type[0] == "rails" || shift_type[0] == "brf面談" || shift_type[0] == "(training 研修事業部)"
            Shift.create(time: time, user_id: mentor_name.id, location: @@location)
          elsif shift_type[0] == "(shibuya 渋谷)"
            Shift.create(time: time, user_id: mentor_name.id, location: "shibuya")
          elsif shift_type[0] == "(ai AIグループ)"
            Shift.create(time: time, user_id: mentor_name.id, location: "ai")
          elsif shift_type[0] == "(expert エキスパート)"
            Shift.create(time: time, user_id: mentor_name.id, location: "expert")
          elsif shift_type[0] == "VR"
            Shift.create(time: time, user_id: mentor_name.id, location: "vr")
          elsif shift_type[0] == "(ikebukuro 池袋)"
            Shift.create(time: time, user_id: mentor_name.id, location: "ikebukuro")
          elsif shift_type[0] == "(shinjuku 新宿)"
            Shift.create(time: time, user_id: mentor_name.id, location: "shinjuku")
          elsif shift_type[0] == "(ochanomizu 御茶ノ水)"
            Shift.create(time: time, user_id: mentor_name.id, location: "ochanomizu")
          elsif shift_type[0] == "(tokyo 東京駅前)"
            Shift.create(time: time, user_id: mentor_name.id, location: "tokyo")
          elsif shift_type[0] == "(waseda 早稲田)"
            Shift.create(time: time, user_id: mentor_name.id, location: "waseda")
          elsif shift_type[0] == "(nagoya 名古屋)"
            Shift.create(time: time, user_id: mentor_name.id, location: "nagoya")
          elsif shift_type[0] == "(umeda 梅田)"
            Shift.create(time: time, user_id: mentor_name.id, location: "umeda")
          else
            Shift.create(time: time, user_id: mentor_name.id, location: @@location)
          end
        else
          number = 0
          shift_type.each do |type|
            if type == "rails" || type == "brf面談" || type == "brf" || type == "(training 研修事業部)" || type == "NPS" || type == ""
              Shift.create(time: time, user_id: mentor_name.id, location: @@location) if number == 0
              number += 1
            elsif type == "(shibuya 渋谷)"
              Shift.create(time: time, user_id: mentor_name.id, location: "shibuya")
            elsif type == "(ai AIグループ)"
              Shift.create(time: time, user_id: mentor_name.id, location: "ai")
            elsif type == "(expert エキスパート)"
              Shift.create(time: time, user_id: mentor_name.id, location: "expert")
            elsif type == "VR"
              Shift.create(time: time, user_id: mentor_name.id, location: "vr")
            elsif type == "(ikebukuro 池袋)"
              Shift.create(time: time, user_id: mentor_name.id, location: "ikebukuro")
            elsif type == "(shinjuku 新宿)"
              Shift.create(time: time, user_id: mentor_name.id, location: "shinjuku")
            elsif type == "(ochanomizu 御茶ノ水)"
              Shift.create(time: time, user_id: mentor_name.id, location: "ochanomizu")
            elsif type == "(tokyo 東京駅前)"
              Shift.create(time: time, user_id: mentor_name.id, location: "tokyo")
            elsif type == "(waseda 早稲田)"
              Shift.create(time: time, user_id: mentor_name.id, location: "waseda")
            elsif type == "(nagoya 名古屋)"
              Shift.create(time: time, user_id: mentor_name.id, location: "nagoya")
            elsif type == "(umeda 梅田)"
              Shift.create(time: time, user_id: mentor_name.id, location: "umeda")
            else
              Shift.create(time: time, user_id: mentor_name.id, location: @@location)
            end
          end
        end
        mentor_num += 1
      end
    rescue => e
      alert = @@driver.switch_to.alert
      alert.accept
    end
    if @@count < 9
      change_group(@@group_list[@@count])
    else
      @@driver.quit
      Jobcan.sending_slack
    end
  end
end

