require "spec_helper"

handler = Class.new do
  extend Lita::Handler::HTTPRouter

  namespace "test"

  http.get "web", :web
  http.post "path/with/:id", :variable
  http.link "foo", :foo
  http.get "heres/*a/glob/in/a/path", :glob
  http.get ":var/otherwise/identical/path", :constraint, var: /\d+/
  http.get ":var/otherwise/identical/path", :no_constraint
  http.get("block") { |_request, response| response.write("block") }
  http.get "middleware", :middleware
  http.get "boom", :boom

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

  def middleware(request, response)
    response["Custom-Header"] = request.env["header_value"] if request.env["use_header"]
    response.write("middleware worked") if request.env["custom_rack_middleware_working"]
  end

  def boom(_request, _response)
    1 + "2"
  end
end

describe handler, lita_handler: true do
  it "responds to requests for simple paths" do
    response = http.get("/web")
    expect(response.status).to eq(200)
    expect(response.body).to eq("it worked")
  end

  it "responds to requests with variable paths" do
    response = http.post("/path/with/some_id")
    expect(response.status).to eq(200)
    expect(response.body).to eq("id is some_id")
  end

  it "responds to requests with globs in their paths" do
    response = http.get("heres/a/giant/glob/in/a/path")
    expect(response.status).to eq(200)
    expect(response.body).to eq("a/giant")
  end

  it "responds to requests with variable path constraints" do
    response = http.get("/123/otherwise/identical/path")
    expect(response.status).to eq(200)
    expect(response.body).to eq("constraint")

    response = http.get("/an/otherwise/identical/path")
    expect(response.status).to eq(200)
    expect(response.body).to eq("no constraint")
  end

  it "responds to HEAD requests for GET routes" do
    response = http.head("/web")
    expect(response.status).to eq(204)
    expect(response.body).to be_empty
  end

  it "allows route callbacks to be provided as blocks" do
    response = http.get("/block")
    expect(response.status).to eq(200)
    expect(response.body).to eq("block")
  end

  context "when the handler raises an exception" do
    it "calls the error handler with the exception as argument" do
      expect(registry.config.robot.error_handler).to receive(:call).with(instance_of(TypeError))

      expect { http.get("/boom") }.to raise_error(TypeError, "String can't be coerced into Fixnum")
    end
  end
end

describe handler, lita_handler: true do
  let(:middleware) do
    Class.new do
      def initialize(app)
        @app = app
      end

      def call(env)
        env["custom_rack_middleware_working"] = true
        @app.call(env)
      end
    end
  end

  prepend_before { registry.config.http.middleware.push(middleware) }

  it "uses any custom middlewares registered" do
    response = http.get("/middleware")
    expect(response.body).to eq("middleware worked")
  end
end

describe handler, lita_handler: true do
  let(:middleware) do
    Class.new do
      def initialize(app, use_header = false, &block)
        @app = app
        @use_header = use_header
        @block = block
      end

      def call(env)
        env["use_header"] = @use_header
        env["header_value"] = @block.call
        @app.call(env)
      end
    end
  end

  prepend_before do
    registry.config.http.middleware.use(middleware, true) { "header value" }
  end

  it "uses any custom middlewares registered" do
    response = http.get("/middleware")
    expect(response["Custom-Header"]).to eq("header value")
  end
end
