require "crawler"

describe Crawler do
  before(:each) do
    @index = double("Index")
    @crawler = Crawler.new
    @crawler.index = @index
  end

  describe "crawling" do
    it "should follow pages" do
      Parser.stub(:parse_replay_list).and_return([])
      Parser.stub(:parse_replay_list_pages).and_return(["page1", "page2"])
      @index.stub(:save)

      pages = []
      HTTP.stub(:download) do |page|
        pages << page
      end

      @crawler.base_url = "url"
      @crawler.crawl
      pages.should include("page1", "page2")
    end

    it "should stop when it sees a replay that already exists" do
      Parser.stub(:parse_replay_list).and_return([{:id => "1"}, {:id => "2"}])
      Parser.stub(:parse_replay_list_pages).and_return(["next_page"])
      @index.stub(:replay_exist?) { true }
      @index.stub(:save)

      HTTP.stub(:download) do |page|
        page.should_not eq("next_page")
      end

      @crawler.crawl
    end
  end

  describe "indexing" do
    before(:each) do
      HTTP.stub(:download)
      Parser.stub(:parse_replay_list).and_return([{ :id => "1", :data => "Test"}])
      Parser.stub(:parse_replay_list_pages).and_return([])
    end

    it "should not do anything if a replay already exists" do
      @index.should_receive(:replay_exist?).with("1").and_return(true)
      @index.stub(:save)

      @crawler.crawl
    end

    it "should add to index" do
      @index.should_receive(:add_replay).with({ :id => "1", :data => "Test" })
      @index.stub(:replay_exist?) { false }
      @index.stub(:save)

      @crawler.crawl
    end

    it "should save the index to filesystem" do
      @index.stub(:add_replay)
      @index.stub(:replay_exist?) { false }
      @index.should_receive(:save)

      @crawler.crawl
    end
  end

  describe "gosugamers" do
    it "should correctly join urls returned from parser" do
      Parser.stub(:parse_replay_list).and_return([])
      Parser.stub(:parse_replay_list_pages).and_return(["replays.php?&start=30"])
      @index.stub(:save)

      pages = []
      HTTP.stub(:download) do |page|
        pages << page
      end

      @crawler.crawl
      pages.should include("http://www.gosugamers.net/dota/replays.php?&start=30")
    end
  end

  describe "calling" do
    before(:each) do
      Parser.stub(:parse_replay_list).and_return([])
      Parser.stub(:parse_replay_list_pages).and_return(["replays.php?&start=30", "replays.php?&start=60"])
      HTTP.stub(:download)
      @index.stub(:save)
    end

    it "should report progress when a block is given" do
      data = []
      @crawler.crawl do |count, total|
        data << count << total
      end

      data.should eq([1, 3, 2, 3, 3, 3])
    end

    it "should stop when break is called in the block" do
      data = []
      @crawler.crawl do |count, total|
        data << count << total
        break
      end

      data.should eq([1, 3])
    end
  end
end
