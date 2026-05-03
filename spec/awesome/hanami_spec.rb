# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Hanami module" do
  it "executes without error" do
    expect { Hello::Awesome::HanamiSample.run }.not_to raise_error
  end

  describe "Task entity" do
    it "creates a valid task" do
      task = Hello::Awesome::Task.new(id: 1, title: "Test", status: "pending", priority: "high")
      expect(task.title).to eq("Test")
      expect(task.status).to eq("pending")
    end
  end

  describe "TaskRepository" do
    it "creates and lists tasks" do
      repo = Hello::Awesome::TaskRepository.new
      repo.create(title: "A", status: "pending", priority: "medium")
      expect(repo.all.length).to eq(1)
    end

    it "filters by status" do
      repo = Hello::Awesome::TaskRepository.new
      repo.create(title: "A", status: "done", priority: "low")
      repo.create(title: "B", status: "pending", priority: "medium")
      expect(repo.by_status("done").length).to eq(1)
    end

    it "filters by priority" do
      repo = Hello::Awesome::TaskRepository.new
      repo.create(title: "A", status: "pending", priority: "high")
      repo.create(title: "B", status: "pending", priority: "low")
      expect(repo.by_priority("high").length).to eq(1)
    end
  end

  describe "validate_params" do
    it "accepts valid params" do
      result = Hello::Awesome.validate_params(title: "Test", status: "pending", priority: "high")
      expect(result.success?).to be true
    end
  end
end
