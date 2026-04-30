# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Performance module" do
  it "executes without error" do
    expect { Hello::Advance::PerformanceSample.run }.not_to raise_error
  end
end
