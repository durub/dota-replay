require "nokogiri"

class ReplayIndex
  attr_reader :replays
  include Enumerable

  # A new instance of ReplayIndex
  #
  # @param [String] file filename attached to the index. the file gets loaded if it exists
  # @example
  #   index = ReplayIndex.new("index.idx")
  def initialize(file = "")
    @file = file
    @replays = []

    load if File.exist?(file)
  end

  # Save the index to the filesystem
  #
  # @param [String] filename alternative filename. uses the filename supplied in the constructor if not present
  def save(filename = nil)
    filename ||= @file

    File.open(filename, "w") do |f|
      f << generate_xml
    end
  end

  # Add a replay
  #
  # The replay must respond_to? [] and must have an [:id]
  # A Hash with an :id key meets this criteria, for example
  #
  # @param [Object] replay the object, meeting above criteria
  # @return [Array, nil] the replays array or nil, if the object doesn't meet the criteria
  # @example
  #   index = ReplayIndex.new
  #   index.add_replay({ :id => 100 })
  #     # => { :id => 100 }
  #   index.add_replay({})
  #     # => nil
  #   index.add_replay("")
  #     # => nil
  def add_replay(replay)
    @replays << replay if replay.respond_to?("[]") && replay[:id]
  end

  # Remove a replay given its id
  #
  # @param [Integer] id the replay id
  # @example
  #   index = ReplayIndex.new("index.idx")
  #   index.remove_replay(100)
  def remove_replay(id)
    @replays.delete_if do |replay|
      replay[:id] == id
    end
  end

  # Check if a replay exists in the index, given its id
  #
  # @param [Integer] id the replay id
  # @return [Boolean]
  # @example
  #  index = ReplayIndex.new("index.idx")
  #  index.replay_exist?(100)
  def replay_exist?(id)
    exist = @replays.find { |replay| replay[:id] == id }
    exist.nil? ? false : true
  end

  # Yields each replay
  #
  # @yield [Object] replay
  def each_replay(&blk)
    replays.each(&blk)
  end
  alias_method :each, :each_replay

  private
    def load
      doc = Nokogiri::XML(File.read(@file))
      replay = {}

      doc.xpath("//replay").each do |replay_xml|
        replay_xml.children.each do |element|
          replay[element.name.to_sym] = element.children.text if element.kind_of?(Nokogiri::XML::Element)
        end

        @replays << replay
        replay = {}
      end
    end

    def generate_xml
      doc = Nokogiri::XML("")
      doc.root = doc.create_element("replays")

      each_replay do |replay|
        doc.root.add_child(build_replay_element(doc, replay))
      end

      doc.to_xml
    end

    def build_replay_element(doc, replay)
      element = doc.create_element("replay")

      replay.each_pair do |key, value|
        child = doc.create_element(key.to_s)
        text = doc.create_text_node(value)

        child.add_child(text)
        element.add_child(child)
      end

      element
    end
end
