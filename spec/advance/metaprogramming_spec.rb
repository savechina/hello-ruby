# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Metaprogramming module" do
  it "executes without error" do
    expect { Hello::Advance::MetaprogrammingSample.run }.not_to raise_error
  end
end
