require 'user_stream'
require 'hipchat-api'

if ARGV.include?("--production")
  Bundler.require
else
  Bundler.require(:default, :development)
end

class Listchat
  def initialize
    UserStream.configure do |config|
      config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
      config.oauth_token        = ENV['TWITTER_OAUTH_TOKEN']
      config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
    end

    @twitter = UserStream.client
    @hipchat = HipChat::API.new(ENV['HIPCHAT_API_TOKEN'])
  end

  def send_room_message_from_status(status)
    return unless status.user

    message = "https://twitter.com/#{status.user.id_str}/status/#{status.id_str}"

    # rooms_message(room_id, from, message, notify = 0, color = 'yellow', message_format = 'html')
    @hipchat.rooms_message(
      ENV['HIPCHAT_ROOM_ID'],
      ENV['HIPCHAT_FROM'],
      message,
      ENV['HIPCHAT_NOTIFY'],
      ENV['HIPCHAT_COLOR'],
      ENV['HIPCHAT_FORMAT']
    )
  end

  def watch
    @twitter.filter(track: ENV['TWITTER_TRACK']) do |status|
      send_room_message_from_status(status)
    end
  end
end


listchat = Listchat.new
listchat.watch
