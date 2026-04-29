# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Strings module" do
  it "executes without error" do
    expect { Hello::Basic::Strings.run }.not_to raise_error
  end
end
