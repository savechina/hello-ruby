# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ErrorHandling module" do
  it "executes without error" do
    expect { Hello::Advance::ErrorHandlingSample.run }.not_to raise_error
  end
end
