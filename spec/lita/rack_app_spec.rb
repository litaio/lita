require "spec_helper"

describe Lita::RackApp do
  let(:handler_class) do
    Class.new(Lita::Handler) do
      http.get "web", :web
      http.post "path/with/:id", :variable
      http.link "foo", :foo
      http.get "heres/*a/glob/in/a/path", :glob
      http.get ":var/otherwise/identical/path", :constraint, var: /\d+/
      http.get ":var/otherwise/identical/path", :no_constraint

      def web(_request, response)
        response.write("it worked")
      end

      def variable(request, response)
        id = request.env["router.params"][:id]
        response.write("id is #{id}")
      end

      def glob(request, response)
        segments = request.env["router.params"][:a]
        response.write(segments.join("/"))
      end

      def constraint(_request, response)
        response.write("constraint")
      end

      def no_constraint(_request, response)
        response.write("no constraint")
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

  it "responds to requests with globs in their paths" do
    env = Rack::MockRequest.env_for("/heres/a/giant/glob/in/a/path")
    status, _headers, body_proxy = subject.call(env)
    expect(status).to eq(200)
    expect(body_proxy.body.first).to eq("a/giant")
  end

  it "responds to requests with variable path constraints" do
    env = Rack::MockRequest.env_for("/123/otherwise/identical/path")
    status, _headers, body_proxy = subject.call(env)
    expect(status).to eq(200)
    expect(body_proxy.body.first).to eq("constraint")

    env = Rack::MockRequest.env_for("/an/otherwise/identical/path")
    status, _headers, body_proxy = subject.call(env)
    expect(status).to eq(200)
    expect(body_proxy.body.first).to eq("no constraint")
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
