# frozen_string_literal: true

RSpec.describe LightsparkClient do
  it "expects to have the correct version" do
    expect(LightsparkClient::VERSION).to be "0.0.1"
  end
end
