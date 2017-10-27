class ScrapingShibuya

  def self.login_user(location)
    @@location = location
    caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {args: ["--headless"]})
    @@driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
    @@driver.navigate.to 'https://ssl.jobcan.jp/login/client/?url=https%3A%2F%2Fssl.jobcan.jp%2Fclient%2F'

    company_id = @@driver.find_element(:id, 'client_login_id')
    company_id.send_keys('div')

    client_manager_id = @@driver.find_element(:id, 'client_manager_login_id')
    client_manager_id.send_keys('mentors')

    password = @@driver.find_element(:id, 'client_login_password')
    password.send_keys('divmentors')

    @@driver.find_element(:xpath, '/html/body/div/div[1]/form/div[5]/button').click
    move_to_schedule_page
  end

  def self.move_to_schedule_page
    e = @@driver.find_element(:xpath, '//*[@id="header"]/div[2]/div/ul/li[2]/a')
    @@driver.mouse.move_to(e) ##シフト管理ボタンにマウスオーバー
    @@driver.find_element(:xpath, '//*[@id="shift-manage-menu"]/ul/li[2]/dl/dt/a').click

    select_group = Selenium::WebDriver::Support::Select.new(@@driver.find_element(:id, 'group_id'))
    if @@location == "shibuya"
      Shift.delete_all
      select_group.select_by(:value, '30') ##渋谷
    elsif @@location == "waseda"
      select_group.select_by(:value, '33') ##早稲田
    elsif @@location == "tokyo"
      select_group.select_by(:value, '36') ##東京駅前
    elsif @@location == "ikebukuro"
      select_group.select_by(:value, '37') ##池袋
    elsif @@location == "shinjuku"
      select_group.select_by(:value, '38') ##新宿
    elsif @@location == "ochanomizu"
      select_group.select_by(:value, '41') ##御茶ノ水
    elsif @@location == "expert"
      select_group.select_by(:value, '42') ##エキスパート
    end

    select_staff = Selenium::WebDriver::Support::Select.new(@@driver.find_element(:id, 'work_kind1'))
    select_staff.select_by(:value, '3')

    @@driver.find_element(:xpath, '//*[@id="search"]/table[1]/tbody/tr[2]/td/div[1]/div[2]/div/span[2]').click if Date.tomorrow.strftime("%-d").to_i == date = Date.new(Time.now.year, Time.now.month, -1).day

    @@driver.find_element(:xpath, '//*[@id="search"]/div[1]/a/div').click ##表示ボタンをクリック(デフォルトで9/1~9/30になっているため、ボタンクリックだけでOK)
    get_shift_schedule
  end

  def self.get_shift_schedule
    shibuya_mentor_shift = []
    num = 3
    while true do
      shibuya_mentor = {}
      tomorrow_date = Date.tomorrow.strftime("%-d").to_i
      if @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/td[#{tomorrow_date}]").text == "-" || @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/td[#{tomorrow_date}]").text == ""
      else
        shibuya_mentor["#{tomorrow_date}"] = @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/td[#{tomorrow_date}]").text
      end
      if @@location == "shibuya"
        name = @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/th").text.sub("渋谷", "").sub("VR", "").gsub(/(\s)/,"")
      elsif @@location == "waseda"
        name = @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/th").text.sub("早稲田", "").gsub(/(\s)/,"")
      elsif @@location == "tokyo"
        name = @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/th").text.sub("東京駅前", "").gsub(/(\s)/,"")
      elsif @@location == "ikebukuro"
        name = @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/th").text.sub("池袋", "").gsub(/(\s)/,"")
      elsif @@location == "shinjuku"
        name = @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/th").text.sub("新宿", "").gsub(/(\s)/,"")
      elsif @@location == "ochanomizu"
        name = @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/th").text.sub("御茶ノ水", "").gsub(/(\s)/,"")
      elsif @@location == "expert"
        name = @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/th").text.sub("エキスパート", "").sub("ビジネス", "").gsub(/(\s)/,"")
      end
      shibuya_mentor_name = User.where(name: name).first_or_initialize
      shibuya_mentor_name.save
      shibuya_mentor.each do |key, value|
        Shift.create(date: key, time: value, user_id: shibuya_mentor_name.id, location: @@location)
      end
      num += 1
      break if @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/th[1]").text.include?("2017年")
    end
    if num == 53
      @@driver.execute_script('window.scroll(0,10000);')
      @@driver.find_element(:xpath, '//*[@id="month"]/div[2]/p/a[5]/span[contains(@class, "glyphicon-chevron-right")]').click
      # @@driver.find_element(:xpath, '//*[@id="month"]/div[2]/p/a[5]/span').click
      get_shift_schedule
    else
    end
    @@driver.quit
    Jobcan.cooperate_with_slack(@@location)
  end
end

