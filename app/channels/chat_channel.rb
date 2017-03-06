class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_channel"
    ActionCable.server.broadcast 'chat_channel', message: 'connected.'
  end

  def client
    client = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = I18n.t 'consumer_key'
      config.consumer_secret     = I18n.t 'consumer_secret'
      config.access_token        = I18n.t 'access_token'
      config.access_token_secret = I18n.t 'access_token_secret'
    end
    client
  end

  def speak(data)
    topics = data['message'].split(" ")
    client.filter(track: topics.join(",")) do |object|
      ActionCable.server.broadcast 'chat_channel', { title: object.user.name, text: object.text, image: object.user.profile_image_url_https(:mini).to_s } if object.is_a?(Twitter::Tweet)
    end
  end
end
