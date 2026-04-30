# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Control Flow module" do
  it "executes without error" do
    expect { Hello::Basic::ControlFlowSample.run }.not_to raise_error
  end
end
