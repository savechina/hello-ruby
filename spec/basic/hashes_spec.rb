# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Hashes module" do
  it "executes without error" do
    expect { Hello::Basic::HashesSample.run }.not_to raise_error
  end
end
