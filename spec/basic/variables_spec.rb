# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Variables module" do
  it "executes without error" do
    expect { Hello::Basic::VariablesSample.run }.not_to raise_error
  end
end
