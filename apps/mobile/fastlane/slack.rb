# Slack notifications shared by the iOS and Android Fastfiles.
#
# Posts with `chat.postMessage` using a bot token. Without SLACK_BOT_TOKEN and SLACK_CICD_CHANNEL
# nothing is sent and the lane runs as usual. A failed notification only warns: it never breaks a lane.

require "json"
require "net/http"
require "uri"

module SlackNotify
  ENDPOINT = "https://slack.com/api/chat.postMessage".freeze

  module_function

  def enabled?
    !ENV["SLACK_BOT_TOKEN"].to_s.empty? && !ENV["SLACK_CICD_CHANNEL"].to_s.empty?
  end

  # Returns true when Slack accepted the message, false when skipped or failed.
  def post(text)
    return false unless enabled?

    uri = URI(ENDPOINT)
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV.fetch('SLACK_BOT_TOKEN')}"
    request["Content-Type"] = "application/json; charset=utf-8"
    request.body = JSON.generate(channel: ENV.fetch("SLACK_CICD_CHANNEL"), text: text)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
      http.request(request)
    end
    body = JSON.parse(response.body.to_s)
    warn("Slack notification failed: #{body['error']}") unless body["ok"]
    body["ok"] == true
  rescue StandardError => e
    warn("Slack notification failed: #{e.class}: #{e.message}")
    false
  end

  def started(platform, lane, env)
    post("🚀 #{platform} #{lane} (#{env}) started")
  end

  def succeeded(platform, lane, env)
    post("🌼 #{platform} #{lane} (#{env}) finished")
  end

  def failed(platform, lane, env, message)
    post("🔥 #{platform} #{lane} (#{env}) failed: #{message}")
  end
end
