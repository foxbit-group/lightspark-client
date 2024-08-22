# frozen_string_literal: true

RSpec.describe LightsparkClient do
  it "expects to have the correct version" do
    expect(LightsparkClient::VERSION).to be "0.1.0"
  end
end
