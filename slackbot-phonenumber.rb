require 'slack-ruby-client'
require 'net/http'
require 'uri'
require 'pry'

TOKEN = ENV['TOKEN']
SANSAN_API_KEY = ENV['SANSAN_API_KEY']

Slack.configure do |config|
  config.token = TOKEN
end

client = Slack::RealTime::Client.new

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
      "#{d['companyName']} #{d['departmentName']} #{d['lastName']} #{d['firstName']}様 tel:#{d['tel']}"
    else
      nil
    end
  end
end

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on :message do |data|
  case data.attachments ? data.text+data.attachments.to_s : data.text
  when 'bot hi' then
    client.message(channel: data.channel, text: "Hi <@#{data.user}>!")
  when /(\+81[\-\d]{1,}\d)/ then
    n = $1.gsub(/^\+81/, '0')
    result = phonenumber_search(n)
    result = "なし" unless result
    client.message(channel: data.channel,
               text: "Sansan 検索結果: #{result}\n電話帳ナビ検索: https://www.telnavi.jp/phone/#{n}",
               thread_ts: data.thread_ts || data.ts)
  end
end

client.on :close do |_data|
  puts "Client is about to disconnect"
end

client.on :closed do |_data|
  puts "Client has disconnected successfully!"
end

client.start!
