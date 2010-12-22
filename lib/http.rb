require "net/http"

# Class to easily handle http-related stuff, like downloading web pages
class HTTP
  # Download a web page and return the HTML content
  #
  # @param [String] path the url. example: "http://www.google.com"
  # @return [String] the HTML content of the web site specified by the url
  def self.download(path)
    url = URI.parse(path)
    Net::HTTP.get(url).body
  end
end
