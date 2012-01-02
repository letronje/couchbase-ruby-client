require File.join(File.dirname(__FILE__), 'setup')

class TestArithmetic < MiniTest::Unit::TestCase

  def setup
    @mock = start_mock
  end

  def teardown
    stop_mock(@mock)
  end

  def test_trivial_incr_decr
    connection = Couchbase.new(:port => @mock.port)

    connection.set(test_id, 1)
    val = connection.incr(test_id)
    assert_equal 2, val
    val = connection.get(test_id)
    assert_equal 2, val

    connection.set(test_id, 7)
    val = connection.decr(test_id)
    assert_equal 6, val
    val = connection.get(test_id)
    assert_equal 6, val
  end

  def test_it_fails_to_incr_decr_missing_key
    connection = Couchbase.new(:port => @mock.port)

    assert_raises(Couchbase::Error::NotFound) do
      connection.incr(test_id(:missing))
    end
    assert_raises(Couchbase::Error::NotFound) do
      connection.decr(test_id(:missing))
    end
  end

  def test_it_creates_missing_key_when_initial_value_specified
    connection = Couchbase.new(:port => @mock.port)

    val = connection.incr(test_id(:missing), :initial => 5)
    assert_equal 5, val
    val = connection.incr(test_id(:missing), :initial => 5)
    assert_equal 6, val
    val = connection.get(test_id(:missing))
    assert_equal 6, val
  end

  def test_it_uses_zero_as_default_value_for_missing_keys
    connection = Couchbase.new(:port => @mock.port)

    val = connection.incr(test_id(:missing), :create => true)
    assert_equal 0, val
    val = connection.incr(test_id(:missing), :create => true)
    assert_equal 1, val
    val = connection.get(test_id(:missing))
    assert_equal 1, val
  end

  def test_it_allows_custom_ttl
    connection = Couchbase.new(:port => @mock.port)

    val = connection.incr(test_id(:missing), :create => true, :ttl => 1)
    assert_equal 0, val
    val = connection.incr(test_id(:missing), :create => true)
    assert_equal 1, val
    sleep(1)
    refute connection.get(test_id(:missing))
  end

  def test_it_allows_custom_delta
    connection = Couchbase.new(:port => @mock.port)

    connection.set(test_id, 12)
    val = connection.incr(test_id, 10)
    assert_equal 22, val
  end

end
