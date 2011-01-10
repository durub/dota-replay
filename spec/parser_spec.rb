require "parser"

describe Parser do
  describe "parsing" do
    it "should parse a list of replays in html and return an array of hashes with replay data" do
      file = File.read(LIST_1)
      replays = Parser.parse_replay_list(file)
      data = [{ :id       => "1000",
                :sentinel => "Team Sentinel Name",
                :scourge  => "Team Scourge Name",
                :version  => "DotA Version",
                :event    => "Event",
                :rating   => "Rating",
                :dl_count => "Download count",
                :date     => "0000-00-00",
                :link     => "/replays/1000"},

              { :id       => "1001",
                :sentinel => "Sent",
                :scourge  => "Scourge",
                :version  => "v6.66b",
                :event    => "Dreamhack Winter",
                :rating   => "6.0",
                :dl_count => "1500",
                :date     => "2000-12-25",
                :link     => "/replays/1001"}]

      replays.should eq(data)
    end

    it "should parse a list of replays and return an array with the links of all pages, interpolating when necessary" do
      file = File.read(LIST_2)
      pages = Parser.parse_replay_list_pages(file)

      pages.should eq(["replays.php?&start=15", "replays.php?&start=30", "replays.php?&start=45" , "replays.php?&start=60",
                       "replays.php?&start=75", "replays.php?&start=90", "replays.php?&start=105", "replays.php?&start=120"])
    end
  end
end
