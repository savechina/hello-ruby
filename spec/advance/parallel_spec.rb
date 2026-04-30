# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Parallel module" do
  it "executes without error" do
    expect { Hello::Advance::ParallelSample.run }.not_to raise_error
  end
end
