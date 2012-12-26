# Utility class works like a Hash with supporting buffer size.
# Usage:
#   size = 3
#   initial_data = {"School1" => #<School:1>, "School2" => #<School:2>, "School3" => #<School:3>}
#   h = BufferHash.new(size, initial_data) do |key|
#     # Process to find the data
#     School.find_by_name(key)
#   end
#
class BufferedHash
  attr_reader :size, :data

  # Initialzize a new BufferedHash object.
  #
  # === Parameters
  #
  #   * size (Fixnum): the buffer size
  #   * initial_data (Hash) (optional): the initial data. This value must be a Hash.
  #   * block (Proc/Lambda) (optional): the finder block, will be called when the key is not found from the cache.
  #
  def initialize(size, initial_data = {}, &block)
    @size = size
    unless initial_data.is_a?(Hash)
      raise ArgumentError.new("Initial data must be a Hash")
    end

    if initial_data.length > @size
      # Take only a number of data items.
      @data = {}
      initial_data.each do |k, v|
        break if self.full?
        @data[k] = v
      end
    else
      @data = initial_data
    end

    @block = block
  end

  def [](key)
    self.get(key)
  end

  def get(key)
    obj = @data[key]
    if obj.nil? && @block
      # Call the block
      obj = @block.call(key)
      if obj
        if full?
          self.delete_last
          @data[key] = obj
        else
          @data[key] = obj
        end
      end
    end
    obj
  end

  def full?
    @data.length >= @size
  end

  protected

    # Remove the last item
    def delete_last
      @data.delete(@data.keys.last)
    end
end
