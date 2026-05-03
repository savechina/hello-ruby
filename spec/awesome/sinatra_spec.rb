# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Sinatra module" do
  it "executes without error" do
    expect { Hello::Awesome::SinatraSample.run }.not_to raise_error
  end

  describe "RealTaskAPI" do
    it "is a Sinatra::Base subclass" do
      expect(Hello::Awesome::RealTaskAPI < Sinatra::Base).to be true
    end

    it "has a health endpoint" do
      expect(Hello::Awesome::RealTaskAPI.routes.keys).to include("GET")
    end
  end

  describe "MemoryTaskStore" do
    it "creates and lists tasks" do
      store = Hello::Awesome::MemoryTaskStore.new
      task = store.create(title: "Test", status: "pending")
      expect(task["title"]).to eq("Test")
      expect(store.list.length).to eq(1)
    end

    it "finds existing tasks" do
      store = Hello::Awesome::MemoryTaskStore.new
      store.create(title: "A", status: "pending")
      task = store.find(1)
      expect(task).not_to be_nil
      expect(task["title"]).to eq("A")
    end

    it "returns nil for missing tasks" do
      store = Hello::Awesome::MemoryTaskStore.new
      expect(store.find(99)).to be_nil
    end

    it "updates tasks" do
      store = Hello::Awesome::MemoryTaskStore.new
      store.create(title: "A", status: "pending")
      updated = store.update(1, status: "done")
      expect(updated["status"]).to eq("done")
    end

    it "deletes tasks" do
      store = Hello::Awesome::MemoryTaskStore.new
      store.create(title: "A", status: "pending")
      result = store.delete(1)
      expect(result[:status]).to eq("deleted")
      expect(store.list.length).to eq(0)
    end

    it "returns not_found for deleting missing tasks" do
      store = Hello::Awesome::MemoryTaskStore.new
      result = store.delete(99)
      expect(result[:status]).to eq("not_found")
    end
  end
end
