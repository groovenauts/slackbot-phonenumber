require 'slack-ruby-client'
require 'net/http'
require 'uri'
require 'pry'

WATCH_CHANNEL = ENV['WATCH_CHANNEL']
INTERVAL = ENV['INTERVAL']
APP_ID = ENV['APP_ID']
TOKEN = ENV['TOKEN']
SANSAN_API_KEY = ENV['SANSAN_API_KEY']

Slack.configure do |config|
  config.token = TOKEN
end

def phonenumber_search(n)
  uri = URI.parse("https://api.sansan.com/v2.5/bizCards/search?limit=1&tel=#{n}")
  request = Net::HTTP::Get.new(uri)
  request["X-Sansan-Api-Key"] = SANSAN_API_KEY

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  if response.code == '200'
    j = JSON(response.body)['data']
    if j.size > 0
      d = j.first
      "#{d['departmentName']}の#{d['lastName']} #{d['firstName']}様 tel:#{d['tel']}"
    else
      nil
    end
  end
end

client = Slack::Web::Client.new
client.auth_test
prev_time = Time.now.to_f

while true do
  time = Time.now.to_f
  messages = client.conversations_history(channel: WATCH_CHANNEL, latest: time, oldest: prev_time)["messages"]
  messages.each do |m|
    if m["bot_profile"] == nil || (m["bot_profile"]["app_id"] != APP_ID)
      if m["text"] =~ /(\+[\-\d]{3,}\d)/
        n = $1.gsub(/^\+81/, '0')
        result = phonenumber_search(n)
        result = "なし" unless result
        client.chat_postMessage(channel: WATCH_CHANNEL, text: "Sansan 検索結果: #{result}\njpnumber検索: https://www.jpnumber.com/searchnumber.do?number=#{n}")
      end
    end
  end
  prev_time = time
end

