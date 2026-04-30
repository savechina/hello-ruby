# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Testing module" do
  it "executes without error" do
    expect { Hello::Advance::TestingSample.run }.not_to raise_error
  end
end
