# frozen_string_literal: true

require "spec_helper"

RSpec.shared_examples "raises the correct error based on status" do
  before do
    stub_request(:post, "https://api.lightspark.com/graphql/server/2023-09-13").to_return(status: status)
  end

  it "expects to raise the correct error" do
    expect { client.send(:request, payload) }.to raise_error LightsparkClient::Errors::ClientError, message
  end
end

RSpec.describe LightsparkClient::Client do
  describe "constants" do
    it "expects to have the correct API_URL" do
      expect(LightsparkClient::Client::DEFAULT_API_URL).to eq "https://api.lightspark.com/graphql/server/2023-09-13"
    end

    it "expects to have the correct DEFAULT_ERROR_MESSAGE" do
      expect(LightsparkClient::Client::DEFAULT_ERROR_MESSAGE).to eq "An error occurred while processing the request"
    end

    it "expects to have the correct LIGHTSPARK_ERRORS" do
      expect(LightsparkClient::Client::LIGHTSPARK_ERRORS).to eq(
        "400" => "You may have malformed your GraphQL request (for example, forgot to include the query field in the payload)",
        "401" => "The token/token_id pair is not valid and we cannot authenticate your account in the request.",
        "402" => "Your account might be on hold because of billing issues, or you are trying to use a feature that is not in your plan.",
        "403" => "Your account might be on hold because of suspicious activity.",
        "429" => "Your account sent too many requests in a short period of time and was rate limited.",
        "5xx" => "The server is experiencing a problem. Please try again later."
      )
    end

    it "expects to have the correct LOGGER_TAG" do
      expect(LightsparkClient::Client::LOGGER_TAG).to eq "LightsparkClient"
    end
  end

  describe "#request" do
    let(:client) { described_class.new(client_id: "client_id", client_secret: "client_secret") }
    let(:payload) { { query: "query { mocked_reponse }" } }

    context "when the request is successful" do
      let(:response_body) { { "data" => { "mocked_reponse": true }, "errors" => nil }.to_json }
      let(:payload) { { query: "query { mocked_reponse }" } }

      before do
        stub_request(:post, "https://api.lightspark.com/graphql/server/2023-09-13").to_return(status: 200, body: response_body)
      end

      it "expects to return the response body" do
        expect(client.send(:request, payload)).to eq JSON.parse(response_body)["data"]
      end

      it "expects to generate the correct headers" do
        client.send(:request, payload)

        expect(a_request(:post, "https://api.lightspark.com/graphql/server/2023-09-13").with(
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Basic Y2xpZW50X2lkOmNsaWVudF9zZWNyZXQ=\n"
          }
        )).to have_been_made.once
      end

      it "expects to pass the correct payload" do
        client.send(:request, payload)

        expect(a_request(:post, "https://api.lightspark.com/graphql/server/2023-09-13").with(
          body: payload.to_json
        )).to have_been_made.once
      end
    end

    context "when the request returns 400" do
      let(:status) { 400 }
      let(:message) { "You may have malformed your GraphQL request (for example, forgot to include the query field in the payload)" }

      it_behaves_like "raises the correct error based on status"
    end

    context "when the request returns 401" do
      let(:status) { 401 }
      let(:message) { "The token/token_id pair is not valid and we cannot authenticate your account in the request." }

      it_behaves_like "raises the correct error based on status"
    end

    context "when the request returns 402" do
      let(:status) { 402 }
      let(:message) { "Your account might be on hold because of billing issues, or you are trying to use a feature that is not in your plan." }

      it_behaves_like "raises the correct error based on status"
    end

    context "when the request returns 403" do
      let(:status) { 403 }
      let(:message) { "Your account might be on hold because of suspicious activity." }

      it_behaves_like "raises the correct error based on status"
    end

    context "when the request returns 429" do
      let(:status) { 429 }
      let(:message) { "Your account sent too many requests in a short period of time and was rate limited." }

      it_behaves_like "raises the correct error based on status"
    end

    context "when the request returns 500" do
      let(:status) { 500 }
      let(:message) { "The server is experiencing a problem. Please try again later." }

      it_behaves_like "raises the correct error based on status"
    end

    context "when the request returns 200 ok but has error" do
      let(:response_body) { { "data" => nil, "errors" => [{ "message" => "An error occurred" }, { "message" => "Something goes wrong" }] }.to_json }

      before do
        stub_request(:post, "https://api.lightspark.com/graphql/server/2023-09-13").to_return(status: 200, body: response_body)
      end

      it "expects to raise an error" do
        expect { client.send(:request, payload) }.to raise_error LightsparkClient::Errors::ClientError, "An error occurred, Something goes wrong"
      end
    end
  end
end
