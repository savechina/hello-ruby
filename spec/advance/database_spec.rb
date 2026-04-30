# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Database module" do
  it "executes without error" do
    expect { Hello::Advance::DatabaseSample.run }.not_to raise_error
  end
end
