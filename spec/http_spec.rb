require "http"

describe HTTP do
  it "should download a page" do
    string = <<HTML
<html>
<head>
  <title>Test page</title>
</head>
<body>
  <h1>Test</h1>
</body>
</html>
HTML

    request = double("request")
    request.stub(:body) { string }
    Net::HTTP.stub(:get) { request }

    page = HTTP.download("http://www.example.com")
    page.should == string
  end
end
