require 'slack-ruby-client'
require 'net/http'
require 'uri'
require 'pry'

TOKEN = ENV['TOKEN']

Slack.configure do |config|
  config.token = TOKEN
end

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
end

client.on :message do |data|
  case data.attachments ? data.text+data.attachments.to_s : data.text
  when 'bot hi' then
    client.message(channel: data.channel, text: "Hi <@#{data.user}>!")
  when /(\+81[\-\d]{1,}\d)/ then
    n = $1.gsub(/^\+81/, '0')
    client.message(channel: data.channel,
               text: "電話帳ナビ検索: https://www.telnavi.jp/phone/#{n}",
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
