# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Sidekiq module" do
  it "executes without error" do
    expect { Hello::Awesome::SidekiqSample.run }.not_to raise_error
  end

  describe "EmailWorker" do
    it "includes Sidekiq::Worker" do
      expect(Hello::Awesome::EmailWorker.ancestors).to include(Sidekiq::Worker)
    end

    it "has queue options set" do
      expect(Hello::Awesome::EmailWorker.get_sidekiq_options).to include("queue" => "critical")
    end
  end

  describe "ReportWorker" do
    it "includes Sidekiq::Worker" do
      expect(Hello::Awesome::ReportWorker.ancestors).to include(Sidekiq::Worker)
    end

    it "has queue options set" do
      expect(Hello::Awesome::ReportWorker.get_sidekiq_options).to include("queue" => "low")
    end
  end
end
