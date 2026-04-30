# frozen_string_literal: true

require "spec_helper"

RSpec.describe "AsyncAwait module" do
  it "executes without error" do
    expect { Hello::Advance::AsyncAwaitSample.run }.not_to raise_error
  end
end
