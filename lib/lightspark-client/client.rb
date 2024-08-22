# frozen_string_literal: true

module LightsparkClient
  class Client
    include LightsparkClient::Mutations::Invoice
    include LightsparkClient::Queries::Invoice
    include LightsparkClient::Queries::Transaction

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
    LOGGER_TAG = "LightsparkClient"

    attr_reader :client_id, :client_secret, :api_url, :logger

    def initialize(client_id:, client_secret:, api_url: DEFAULT_API_URL, logger: nil)
      @client_id = client_id
      @client_secret = client_secret
      @api_url = api_url
      @logger = logger
    end

    private

    def request(payload)
      log("Requesting Lightspark API")
      log("Payload: #{payload}")

      reponse = Typhoeus.post(
        api_url,
        body: payload.to_json,
        headers: request_headers
      )

      handle_response(response)
    end

    def request_headers
      token = Base64.encode64("#{client_id}:#{client_secret}")

      {
        "Authorization" => "Basic #{token}",
        "Content-Type" => "application/json"
      }
    end

    def log(message, level = :info)
      if logger && looger.respond_to?(:tagged) && logger.respond_to?(level)
        logger.send(:tagged, LOGGER_TAG) { logger.send(level, message) }
      else
        puts "[#{LOGGER_TAG}] #{message}"
      end
    end

    def handle_response(response)
      handle_status(response)

      response_body = JSON.parse(response.body)

      handle_errors(response_body)

      log("Request to Lightspark API was successful")

      response_body["data"]
    end

    def handle_status(response)
      return response if response.success?

      status = response.code
      status = "5xx" if status >= 500

      message = LIGHTSPARK_ERRORS[status.to_s]
      message ||= DEFAULT_ERROR_MESSAGE

      log("Request failed with status: #{response.code}. Message: #{message}", :error)

      raise LightsparkClient::Errors::RequestError, message
    end

    def handle_errors(body)
      return if body["errors"].nil? || body["errors"].empty?

      message = body["errors"].map { |error| error["message"] }.join(", ")

      log("Request failed with errors: #{message}", :error)

      raise LightsparkClient::Errors::RequestError, message
    end
  end
end
