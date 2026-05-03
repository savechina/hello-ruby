# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Grape module" do
  it "executes without error" do
    expect { Hello::Awesome::GrapeSample.run }.not_to raise_error
  end

  describe "TaskAPI" do
    it "is a Grape::API subclass" do
      expect(Hello::Awesome::TaskAPI < Grape::API).to be true
    end

    it "has routes defined" do
      expect(Hello::Awesome::TaskAPI.routes).not_to be_empty
    end
  end
end
