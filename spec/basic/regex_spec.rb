# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Regex module" do
  it "executes without error" do
    expect { Hello::Basic::RegexSample.run }.not_to raise_error
  end
end
