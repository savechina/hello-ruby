# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CliAdvanced module" do
  it "executes without error" do
    expect { Hello::Advance::CliAdvancedSample.run }.not_to raise_error
  end
end
