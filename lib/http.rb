require "net/http"

# Class to easily handle http-related stuff, like downloading web pages
class HTTP
  # Download a web page and return the HTML content
  #
  # @param [String] path the url
  # @return [String] the HTML content of the web site specified by the url
  # @example
  #   HTTP.download("http://www.google.com")
  def self.download(path)
    url = URI.parse(path)
    Net::HTTP.get(url)
  end
end
