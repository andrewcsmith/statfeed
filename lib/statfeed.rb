class Statfeed
  VERSION = "1.0.0"
  attr_accessor :weights
 
  def initialize size
    @weights = Array.new(size, 1)
  end

  def sample
    # Accumulator value
    acc = 0.0
    # Map the cumulative weights
    cdf = @weights.map { |w| acc += w }
    # Get a random number between 0.0 and the last value
    r = rand(cdf.last)
    # Gets the first number that's less than the random number
    index = cdf.find_index { |c| c > r }
    
    @weights = @weights.map { |w|
      # Increment the full thing by a total of 1.0
      w += (@weights[index].to_f / (@weights.size-1.0))
    }
    @weights[index] = 0

    if block_given?
      yield index
    else
      index
    end
  end
end
