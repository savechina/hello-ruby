# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Exceptions module" do
  it "executes without error" do
    expect { Hello::Basic::ExceptionsSample.run }.not_to raise_error
  end
end
