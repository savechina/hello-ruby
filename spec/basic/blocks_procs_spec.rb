# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Blocks & Procs module" do
  it "executes without error" do
    expect { Hello::Basic::BlocksProcsSample.run }.not_to raise_error
  end
end
