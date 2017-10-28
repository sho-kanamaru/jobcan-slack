class Jobcan

  require "slack"

  def self.cooperate_with_slack(location)

    Slack.configure do |config|
      config.token = 'xoxb-235273604049-9NcHGJ1tyKTn57UwGkzkRCpi'
    end

    youbi = %w[日 月 火 水 木 金 土]
    text = "【リマインダー】#{DateTime.tomorrow.year}/#{DateTime.tomorrow.month}/#{DateTime.tomorrow.day}(#{youbi[DateTime.tomorrow.wday]})\nこちらにメンションがついている `明日シフトの方は今日23時までに必ず本通知にリアクション` をお願いします。\n\n"
    tomorrow_date = Date.tomorrow.strftime("%-d")
    tomorrow_mentor_lists = Shift.where(date: tomorrow_date).where(location: location)
    tomorrow_mentor_lists.each do |mentor|
      text << "#{mentor.user.name}(<#{mentor.user.mention}>) #{mentor.time}\n"
    end

    if location == "shibuya"
      Slack.chat_postMessage(text: text, channel: '#jobcan-test')
    elsif location == "waseda"
      Slack.chat_postMessage(text: text, channel: '#jobcan-test')
    elsif location == "tokyo"
      Slack.chat_postMessage(text: text, channel: '#jobcan-test')
    elsif location == "ikebukuro"
      Slack.chat_postMessage(text: text, channel: '#jobcan-test')
    elsif location == "shinjuku"
      Slack.chat_postMessage(text: text, channel: '#jobcan-test')
    elsif location == "ochanomizu"
      Slack.chat_postMessage(text: text, channel: '#jobcan-test')
    elsif location == "expert"
      Slack.chat_postMessage(text: text, channel: '#jobcan-test')
    elsif location == "umeda"
      Slack.chat_postMessage(text: text, channel: '#jobcan-test')
    elsif location == "nagoya"
      Slack.chat_postMessage(text: text, channel: '#jobcan-test')
    end
  end

end
