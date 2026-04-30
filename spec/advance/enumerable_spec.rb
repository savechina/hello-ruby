# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Enumerable module" do
  it "executes without error" do
    expect { Hello::Advance::EnumerableSample.run }.not_to raise_error
  end
end
