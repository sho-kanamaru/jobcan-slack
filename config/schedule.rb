set :environment, :development

every 1.day, at: '17:00 pm' do
  rake "jobcan_task:jobcan"
end
