# frozen_string_literal: true

require "spec_helper"

RSpec.describe "File I/O module" do
  it "executes without error" do
    expect { Hello::Basic::FileIOSample.run }.not_to raise_error
  end
end
