require "spec_helper"

describe Lita::RackApp do
  let(:handler_class) do
    Class.new(Lita::Handler) do
      http.get "web", :web
      http.post "path/with/:id", :path_with_variable
      http.link "foo", :foo

      def web(request, response)
        response.write("it worked")
      end

      def path_with_variable(request, response)
        id = request.env["router.params"][:id]
        response.write("id is #{id}")
      end

      def self.name
        "Lita::Handlers::Test"
      end
    end
  end

  let(:robot) { instance_double("Lita::Robot") }

  before { allow(Lita).to receive(:handlers).and_return([handler_class]) }

  subject { described_class.new(robot) }

  it "responds to requests for simple paths" do
    env = Rack::MockRequest.env_for("/web")
    status, _headers, body_proxy = subject.call(env)
    expect(status).to eq(200)
    expect(body_proxy.body.first).to eq("it worked")
  end

  it "responds to requests with variable paths" do
    env = Rack::MockRequest.env_for("/path/with/some_id", method: "POST")
    status, _headers, body_proxy = subject.call(env)
    expect(status).to eq(200)
    expect(body_proxy.body.first).to eq("id is some_id")
  end

  it "responds to HEAD requests for GET routes" do
    env = Rack::MockRequest.env_for("/web", method: "HEAD")
    status, _headers, body = subject.call(env)
    expect(status).to eq(204)
    expect(body).to be_empty
  end

  it "doesn't respond to HEAD requests for non-GET routes" do
    env = Rack::MockRequest.env_for("/path/with/some_id", method: "HEAD")
    status, _headers, _body = subject.call(env)
    expect(status).to eq(405)
  end
end
