# frozen_string_literal: true

require "spec_helper"

RSpec.describe "File Management module" do
  it "executes without error" do
    expect { Hello::Basic::FileManagementSample.run }.not_to raise_error
  end
end
