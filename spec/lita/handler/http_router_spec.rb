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
end
