# frozen_string_literal: true

require "spec_helper"

RSpec.describe LightsparkClient do
  it "expects to have the correct version" do
    expect(LightsparkClient::VERSION).to be "0.1.1"
  end
end
