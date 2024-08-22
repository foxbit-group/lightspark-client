# frozen_string_literal: true

module LightsparkClient
  class Base
    DEFAULT_API_URL = "https://api.lightspark.com/graphql/server/2023-09-13"
    DEFAULT_ERROR_MESSAGE = "An error occurred while processing the request"
    LIGHTSPARTK_ERRORS = {
      "400": "You may have malformed your GraphQL request (for example, forgot to include the query field in the \
              payload)",
      "401": "The token/token_id pair is not valid and we cannot authenticate your account in the request.",
      "402": "Your account might be on hold because of billing issues, or you are trying to use a feature that \
              is not in your plan.",
      "403": "Your account might be on hold because of suspicious activity.",
      "429": "Your account sent too many requests in a short period of time and was rate limited.",
      "5xx": "The server is experiencing a problem. Please try again later."
    }

    def initialize(client_id:, client_secret:, api_url: DEFAULT_API_URL, logger: nil)
      @client_id = client_id
      @client_secret = client_secret
      @api_url = api_url
      @logger = logger
    end

    private

    def request(payload)
      write_log("Requesting Lightspark API")
      write_log("Payload: #{payload}")

      reponse = Typhoeus.post(
        @api_url,
        body: payload.to_json,
        headers: request_headers
      )

      handle_response(response)
    end

    def request_headers
      token = Base64.encode64("#{@client_id}:#{@client_secret}")

      {
        "Authorization" => "Basic #{token}",
        "Content-Type" => "application/json"
      }
    end

    def write_log(message, level = :info)
      return unless @logger && @looger.respond_to?(:write_log)

      @logger.send(:write_log, message, level: level)
    end

    def handle_response(response)
      handle_status(response)

      response_body = JSON.parse(response.body)

      handle_errors(response_body)

      response_body["data"]
    end

    def handle_status(response)
      return response if response.success?

      status = response.code
      status = "5xx" if status >= 500

      message = LIGHTSPARK_ERRORS[status.to_s]
      message ||= DEFAULT_ERROR_MESSAGE

      raise LightsparkClient::Exception, message
    end

    def handle_errors(body)
      return if body["errors"].nil? || body["errors"].empty?

      message = body["errors"].map { |error| error["message"] }.join(", ")
      raise LightsparkClient::Exception, message
    end
  end
end
