# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Falcon module" do
  it "executes without error" do
    expect { Hello::Awesome::FalconSample.run }.not_to raise_error
  end

  describe "build_rack_app" do
    let(:app) { Hello::Awesome::FalconSample.build_rack_app }

    it "responds to root path" do
      status, _headers, body = app.call("REQUEST_METHOD" => "GET", "PATH_INFO" => "/")
      expect(status).to eq(200)
      expect(body.first).to include("Hello from Falcon-compatible")
    end

    it "responds to /api/status with JSON" do
      status, headers, body = app.call("REQUEST_METHOD" => "GET", "PATH_INFO" => "/api/status")
      expect(status).to eq(200)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(body.first).to include('"status":"ok"')
    end

    it "responds to /users/:id" do
      status, _headers, body = app.call("REQUEST_METHOD" => "GET", "PATH_INFO" => "/users/42")
      expect(status).to eq(200)
      expect(body.first).to include('"id":"42"')
    end

    it "returns 404 for unknown paths" do
      status, _headers, _body = app.call("REQUEST_METHOD" => "GET", "PATH_INFO" => "/unknown")
      expect(status).to eq(404)
    end
  end
end
