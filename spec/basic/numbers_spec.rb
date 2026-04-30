# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Numbers module" do
  it "executes without error" do
    expect { Hello::Basic::NumbersSample.run }.not_to raise_error
  end
end
