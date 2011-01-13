require_relative "replay_index"
require_relative "parser"
require_relative "http"

# The Crawler class crawls gosugamers replay pages, extracting the replays main information and saving them to an index<br />
# {#crawl} provides a good level of control over the crawling process. provided that you supply a block to it. <br />
class Crawler
  # A ReplayIndex instance, by default
  # @return [ReplayIndex]
  attr_accessor :index

  # Base URL to start crawling.<br />
  # Default is the Gosugamers replays index page
  # @return [String]
  attr_accessor :base_url

  # @param [String] index_index index filename
  def initialize(index_file = "")
    @index = ReplayIndex.new(index_file)
    @base_url = "http://www.gosugamers.net/dota/replays"
  end

  # Crawls {#base_url}, jumping from page to page, recovering replay data and saving them to an index<br />
  # This method is auxiliated by {HTTP}, {Parser} and {ReplayIndex} ({#index})
  #
  # If a block is supplied, crawl yields two values. The first is the current page number being crawled, after
  # it has been crawled, parsed and indexed.<br /> The second is a constant, the total page count. Note that
  # not necessarily +crawl+ will crawl all these pages. If the crawler finds a replay that already exists, it simply stops.
  #
  # @param [Block] blk optional
  # @yield [count, total] current page number and the total page count
  #
  # @example
  #   crawler = Crawler.index("index.idx")
  #   crawler.crawl
  #
  # @example
  #   crawler = Crawler.index("index.idx")
  #   crawler.crawl do |count, total|
  #     percentage = (count * 100.0) / total
  #     puts "Progress: #{percentage} (#{count}/#{total})"
  #   end
  #
  # @example
  #   crawler = Crawler.index("index.idx")
  #   crawler.crawl do |count, total|
  #     break if count >= 5 # crawl and index only the first five pages
  #   end
  def crawl(&blk)
    first_page = HTTP.download(@base_url)
    pages = Parser.parse_replay_list_pages(first_page)
    pages.reverse!.push(@base_url).reverse!

    if block_given?
      crawl_pages_with_progress(pages, &blk)
    else
      crawl_pages(pages)
    end
  end

  private
    def crawl_pages(pages)
      crawl_pages_with_progress(pages) do
        # do nothing
      end
    end

    def crawl_pages_with_progress(pages)
      i = 0

      @continue = true
      pages.each do |page|
        crawl_page(page)

        break unless @continue

        @index.save

        i += 1
        yield i, pages.length
      end
    end

    def crawl_page(page)
      content = HTTP.download(join_url(page))
      replays = Parser.parse_replay_list(content)

      replays.each do |replay|
        if index.replay_exist?(replay[:id])
          @continue = false
        else
          index.add_replay(replay)
        end
      end
    end

    # Parser returns relative URL pages, relative to gosugamers.net/dota/
    # We have to join them, but only if the url is not absolute
    def join_url(url)
      if @base_url =~ /gosugamers\.net/ && url !~ /gosugamers\.net/
        "http://www.gosugamers.net/dota/#{url}"
      else
        url
      end
    end
end
