# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ThreadsFibers module" do
  it "executes without error" do
    expect { Hello::Advance::ThreadsFibersSample.run }.not_to raise_error
  end
end
