require "minitest/autorun"
require "statfeed"

class TestStatfeed < Minitest::Test
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
end
