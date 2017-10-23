class ScrapingExpert

  def self.login_user(location)
    @@location = location
    @@driver = Selenium::WebDriver.for :chrome
    @@driver.navigate.to 'https://ssl.jobcan.jp/login/client/?url=https%3A%2F%2Fssl.jobcan.jp%2Fclient%2F'

    company_id = @@driver.find_element(:id, 'client_login_id')
    company_id.send_keys('div')

    client_manager_id = @@driver.find_element(:id, 'client_manager_login_id')
    client_manager_id.send_keys('online')

    password = @@driver.find_element(:id, 'client_login_password')
    password.send_keys('exponline')

    @@driver.find_element(:xpath, '/html/body/div/div[1]/form/div[5]/button').click
    move_to_schedule_page
  end

  def self.move_to_schedule_page
    e = @@driver.find_element(:xpath, '//*[@id="header"]/div[2]/div/ul/li[2]/a')
    @@driver.mouse.move_to(e) ##シフト管理ボタンにマウスオーバー

    @@driver.find_element(:xpath, '//*[@id="shift-manage-menu"]/ul/li[2]/dl/dt/a').click

    select = Selenium::WebDriver::Support::Select.new(@@driver.find_element(:id, 'work_kind1'))
    select.select_by(:value, '3')

    @@driver.find_element(:xpath, '//*[@id="search"]/table[1]/tbody/tr[2]/td/div[1]/div[2]/div/span[2]').click if Date.tomorrow.strftime("%-d").to_i == date = Date.new(Time.now.year, Time.now.month, -1).day ##月の最終日だったら、次の月のページに遷移

    @@driver.find_element(:xpath, '//*[@id="search"]/div[1]/a/div').click ##表示ボタンをクリック(デフォルトで9/1~9/30になっているため、ボタンクリックだけでOK)
    get_shift_schedule
  end

  def self.get_shift_schedule
    expert_mentor_shift = []
    num = 3
    while true do
      expert_mentor = {}
      tomorrow_date = Date.tomorrow.strftime("%-d").to_i
      if @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/td[#{tomorrow_date}]").text == "-" || @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/td[#{tomorrow_date}]").text == ""
      else
        expert_mentor["#{tomorrow_date}"] = @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/td[#{tomorrow_date}]").text
      end
      name = @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/th").text.sub("エキスパート", "").sub("ビジネス", "").gsub(/(\s)/,"")
      expert_mentor_name = User.where(name: name).first_or_initialize
      expert_mentor_name.save
      expert_mentor.each do |key, value|
        Shift.create(date: key, time: value, user_id: expert_mentor_name.id, location: @@location) ##ここも動的にしたい
      end
      num += 1
      break if @@driver.find_element(:xpath, "//*[@id='month']/table/tbody/tr[#{num}]/th[1]").text.include?("2017年")
    end
    if num == 53
      @@driver.execute_script('window.scroll(0,10000);')
      @@driver.find_element(:xpath, '//*[@id="month"]/div[2]/p/a[5]/span[contains(@class, "glyphicon-chevron-right")]').click
      get_shift_schedule
    else
    end
    @@driver.quit
    Jobcan.cooperate_with_slack(@@location)
  end

end
