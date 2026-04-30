# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SystemProgramming module" do
  it "executes without error" do
    expect { Hello::Advance::SystemProgrammingSample.run }.not_to raise_error
  end
end
