require "nokogiri"

# The parser handles the parsing of list of replays (the replays index)
class Parser
  class << self
    # Parse the HTML of a list of replays and return replay data
    # as an array of hashes, each hash being a replay.
    #
    # Following data is available for each replay:
    # * :id       => the gosugamers replay id
    # - :sentinel => the sentinel team name
    # - :scourge  => the scourge team name
    # - :version  => replay dota version
    # - :event    => the event that the game was played at
    # - :rating   => the gosugamers rating for the replay
    # - :dl_count => the gosugamers download count for the replay
    # - :date     => the date the replay was put online in gosugamers
    # - :link     => the gosugamers replay link (relative to http://www.gosugamers.net/dota)
    #
    # @param [String] html the html content
    # @return [Array<{Symbol => String}>] replay data
    # @example
    #   index = HTTP.download("http://www.gosugamers.net/dota/replays")
    #   replays = Parser.parse_replay_list(index)
    #   replay = replays[0]
    #
    #   puts "Latest replay:"
    #   puts "Sentinel team was: #{replay[:sentinel]}"
    #   puts "Scourge team was: #{replay[:scourge]}"
    #   puts "Replay version: #{replay[:version]}"
    #   puts "Replay link: #{replay[:link]}"
    def parse_replay_list(html)
      document = Nokogiri::HTML(normalize_tr(html))
      replays = []

      document.xpath("//tr[@class=\"wide_middle\"]").each do |row|
        replays << parse_replay_tr(row)
      end

      replays
    end

    # Parse the HTML of a list of replays and return the next pages links
    # as an array of strings
    #
    # @param [String] html the html content
    # @return [Array<String>] links url
    # @example
    #   index = HTTP.download("http://www.gosugamers.net/dota/replays")
    #   pages = Parser.parse_replay_list_pages(index)
    #
    #   p pages
    #   # => ["replays.php?&start=30", "replays.php?&start=60", "replays.php?&start=90"]
    #
    # @example
    #   index = HTTP.download("http://www.gosugamers.net/dota/replays")
    #   pages = Parser.parse_replay_list_pages(index)
    #   second_page = pages[0]
    #
    #   second_page_list = HTTP.download("http://www.gosugamers.net/dota/#{second_page}")
    #   replays = Parser.parse_replay_list(second_page_list)
    #   replay = replays[0]
    #
    #   puts "First replay from second page:"
    #   puts "Sentinel team was: #{replay[:sentinel]}"
    #   puts "Scourge team was: #{replay[:scourge]}"
    #   puts "Replay version: #{replay[:version]}"
    #   puts "Replay link: #{replay[:link]}"
    def parse_replay_list_pages(html)
      document = Nokogiri::HTML(html)
      pages = []

      # xpath: get all anchors from a td with a wide_middle class and 800 width
      nodeset = document.xpath("//td[@class=\"wide_middle\" and @width=800]/a")
      values = nodeset.first(5).map { |link| parse_href_start_number(link) }

      step = values[1] - values[0]
      first_link = values[0]
      last_link = values[4]

      (first_link..last_link).step(step) do |value|
        pages << "replays.php?&start=#{value}"
      end

      pages
    end

    private
      def parse_replay_tr(tr)
        innermost = tr.children.children.children
        link = tr.first(2)[1][1]

        replay = { :id       => link.split("/")[2],
                   :sentinel => innermost[2].text,
                   :scourge  => innermost[3].text,
                   :version  => innermost[4].text,
                   :event    => innermost[5].text,
                   :rating   => innermost[6].text,
                   :dl_count => innermost[7].text,
                   :date     => innermost[8].text,
                   :link     => link }

        replay.each_value(&:strip!)
      end

      # Gosugamers html sucks
      # We have to close the tr tags ourselves so Nokogiri can work properly
      def normalize_tr(html)
        html.gsub(/(\d{4}-\d{2}-\d{2})(\s+)?<tr class="wide_middle"/, '\\1</tr><tr class="wide_middle"')
      end

      # Get the numerical "start" value from the url
      # Example:
      #   link = "replay.php?&start=30"
      #   parse_href_start_number(link)
      #   # => 30
      def parse_href_start_number(link)
        link["href"].split("=")[1].to_i
      end
  end
end
