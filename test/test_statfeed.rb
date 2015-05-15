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
    assert_each_in_delta [3.3633, 3.3933, 3.4233], actual
  end

  def test_sort_options
    actual = @sf.sort_options([0.3, 0.5, 0.4])
    assert_each_equal %w(a c b), actual
  end

  def test_n_decisions
    # Should have N possible decisions
  end

  def test_m_options
    # Should have a common pool of M possible options
  end

  def test_s_sub_m
    # Should have a statistic S_m for the statistic associated with option m
  end

  def test_a_sub_n
    # Accent (stress) associated with the decision n
  end

  def test_h_sub_n
    # Heterogeneity associated with decision n
  end

  def test_w_sub_m_n
    # Weight associated with option m during decision n
  end

  def test_u_sub_m_n
    # Uniformly distributed random number for each option of each decision
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
