# frozen_string_literal: true

require "hello"

RSpec.describe Hello do
  it "has a version" do
    expect(Hello::VERSION).not_to be_nil
  end

  it "loads without error" do
    expect(defined?(Hello)).to eq("constant")
  end
end
