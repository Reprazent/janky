require 'net/http'
require 'json'

module Janky
  module ChatService
    class Slack
      attr_accessor :token
      attr_accessor :from
      attr_accessor :team_name
      attr_accessor :room_names

      def initialize(settings)
        @token = settings["JANKY_CHAT_SLACK_TOKEN"]
        @team_name = settings["JANKY_CHAT_SLACK_TEAM"]
        @from = settings["JANKY_CHAT_SLACK_FROM"] || "CI"
        raise Error, "JANKY_CHAT_SLACK_TOKEN setting is required" unless @token
        raise Error, "JANKY_CHAT_SLACK_TEAM setting is required" unless @token
      end

      def speak(message, room_id, opts={})
        payload = {text: message, username: @from}
        payload.merge!({ channel: room_id }) if room_id
        req = Net::HTTP::Post.new "#{uri.path}?#{uri.query}"
        req.body = payload.to_json
        Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          http.ssl_version = :SSLv3
          http.request req
        end
      end

      def uri
        @uri ||= URI("https://#{team_name}.slack.com/services/hooks/incoming-webhook?token=#{token}")
      end

      def rooms
        #TODO get the room names out of slack
        @rooms = []
      end

    end
  end
  register_chat_service "slack", ChatService::Slack

end
