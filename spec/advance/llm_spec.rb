# frozen_string_literal: true

require "spec_helper"

RSpec.describe "LLM module" do
  it "executes without error" do
    expect { Hello::Advance::LlmSample.run }.not_to raise_error
  end
end