# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Data Processing module" do
  it "executes without error" do
    expect { Hello::Advance::DataProcessingSample.run }.not_to raise_error
  end
end
