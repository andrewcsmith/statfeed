require "minitest/autorun"
require "statfeed"

class TestStatfeed < Minitest::Test
  def setup
    @sf = Statfeed.new([0, 1, 2], %w(a b c))
    # Need to control the "random" numbers in order to assert answers
    @sf.randoms = [[0.1, 0.2, 0.3], [0.4, 0.5, 0.6], [0.7, 0.8, 0.9]]
  end

  def test_true_increment
    assert_in_delta 3.0, @sf.true_increment(0, 0)
  end

  def test_expected_increment
    actual = @sf.expected_increment(0, 0)
    assert_in_delta 3.03, actual
  end

  def test_scheduling_values
    actual = @sf.scheduling_values(0)
    assert_each_in_delta [3.03, 3.06, 3.09], actual
  end

  def test_sort_options
    actual = @sf.sort_options([0.3, 0.5, 0.4])
    assert_each_equal %w(a c b), actual
  end

  def test_populate_choices
    actual = @sf.populate_choices
    assert_each_equal %w(a b b), actual
  end

  def test_additional_constraints
    # Define a new method excluding the a
    def @sf.acceptable? o, *args
      o != 'a'
    end

    actual = @sf.populate_choices
    assert_each_equal %w(b c c), actual
  end

  def assert_each_in_delta exp, act, delta = 0.001
    exp.zip(act).each do |e, a|
      assert_in_delta e, a, delta
    end
  end

  def assert_each_equal exp, act
    exp.zip(act).each do |e, a|
      assert_equal e, a
    end
  end
end
