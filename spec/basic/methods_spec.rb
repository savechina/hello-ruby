# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Methods module" do
  it "executes without error" do
    expect { Hello::Basic::MethodsSample.run }.not_to raise_error
  end
end
