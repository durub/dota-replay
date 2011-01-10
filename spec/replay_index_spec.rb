require "replay_index"
require "fakefs/safe"

describe ReplayIndex do
  describe "loading and saving" do
    before(:all) do
      FakeFS.activate!
    end

    after(:all) do
      FakeFS.deactivate!
    end

    it "should load from filesystem" do
      File.open('file.idx', 'w') do |f|
        contents = <<C
          <replay>
            <id>0</id>
            <sentinel>Test</sentinel>
          </replay>
C

        f << contents
      end

      index = ReplayIndex.new("file.idx")
      index.replays[0][:sentinel].should eq("Test")
    end

    it "should save to filesystem" do
      index = ReplayIndex.new("replay.idx")
      index.save

      File.exist?("replay.idx").should be_true
    end

    it "should save to filesystem using a different file name" do
      index = ReplayIndex.new("replay.idx")
      index.save("new.idx")

      File.exist?("new.idx").should be_true
    end

    it "should be equal in state after saving and loading" do
      File.open('index.idx', 'w') do |f|
        contents = <<C
          <replay>
            <id>0</id>
            <sentinel>Test</sentinel>
          </replay>

          <replay>
            <id>1</id>
            <scourge>String</scourge>
          </replay>
C

        f << contents
      end

      index = ReplayIndex.new("index.idx")
      index.save("another.idx")

      ReplayIndex.new("another.idx").replays.should eq(index.replays)
    end
  end

  describe "adding and removing" do
    it "should add replays" do
      index = ReplayIndex.new
      index.add_replay({:id => 0})
      index.add_replay({:id => 1})

      index.replays.length.should eq(2)
    end

    it "should not add anything that doesn't have an id" do
      index = ReplayIndex.new
      index.add_replay({})
      index.add_replay(Object.new)

      index.replays.length.should be_zero
    end

    it "should return nil when something doesn't have an id" do
      index = ReplayIndex.new

      index.add_replay({}).should be_nil
    end

    it "should remove based on an id" do
      replays = [{:id => 0}, {:id => 1}]

      index = ReplayIndex.new
      index.add_replay(replays[0])
      index.add_replay(replays[1])
      index.remove_replay(replays[0][:id])

      index.replays.length.should eq(1)
    end
  end

  describe "manipulating replay data" do
    it "should check if a replay exists based on an id" do
      index = ReplayIndex.new
      index.add_replay({:id => 0})
      index.add_replay({:id => 1})

      index.replay_exist?(1).should be_true
    end

    it "should yield each replay" do
      index = ReplayIndex.new
      index.add_replay({:id => 0})

      index.each_replay do |replay|
        replay[:id].to_i.should eq(0)
      end
    end
  end

  it "should provide Enumerable stuff" do
    ReplayIndex.include?(Enumerable).should be_true
  end
end
