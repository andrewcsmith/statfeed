class Statfeed
  VERSION = "1.0.1"
  attr_accessor :weights, :choices, :randoms, :heterogeneities, :accents, :statistics, :size, :decisions, :options
 
  def initialize decisions, options, heterogeneity: 0.1, accent: 1.0
    @decisions = decisions
    @options = options

    # This will eventually be the result of applying statistical feedback
    @choices = Array.new(@decisions.size, nil)

    # Vector of heterogeneity values for each decision
    @heterogeneities = Array.new(decisions.size, heterogeneity)
    # Vector of accent values for each decision
    @accents = Array.new(decisions.size, accent)
    # Vector of statistic for each option
    reset_statistics

    # Fill matrix of random values
    populate_randoms
    # Fill matrix of weights
    populate_weights
  end

  def reset_statistics
    @statistics = Array.new(options.size, 0.0)
  end

  def populate_choices
    @decisions.each_index do |decision|
      vals = scheduling_values(decision)
      @choices[decision] = sort_options(vals).first
      increment_statistics decision, sort_option_indices(vals).first
      normalize_statistics! decision
    end
    @choices
  end

  def populate_randoms
    @randoms = Array.new @decisions.size do
      Array.new @options.size do
        rand
      end
    end
  end

  def populate_weights
    @weights = Array.new @decisions.size do
      Array.new @options.size do
        1.0 / @options.size
      end
    end
  end

  def expected_increment decision, option
    (@accents[decision] + (@heterogeneities[decision] * @randoms[decision][option])).to_f / @weights[decision][option]
  end

  def true_increment decision, option
    @accents[decision].to_f / @weights[decision][option]
  end

  def normalization_value decision
    @accents[decision].to_f / @weights[decision].inject(0.0, :+)
  end

  def scheduling_values decision
    (0...@options.size).map do |m|
      @statistics[m] + expected_increment(decision, m)
    end
  end

  # Feed the scheduling values into this (step 2)
  def sort_options vals
    @options.zip(vals).sort_by(&:last).map(&:first)
  end

  # Feed the scheduling values into this (step 2)
  def sort_option_indices vals
    (0...@options.size).to_a.zip(vals).sort_by(&:last).map(&:first)
  end

  def increment_statistics decision, option
    @statistics[option] += true_increment(decision, option)
  end

  def normalize_statistics decision
    @statistics.each_with_index.map do |statistic, m|
      if @weights[decision][m] > 0.0
        statistic - normalization_value(decision)
      else
        statistic
      end
    end
  end

  def normalize_statistics! decision
    @statistics = normalize_statistics decision
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
