require 'minitest/autorun'
require 'time'
require 'query'

# TODO: use rspec?


class QueryTest < Minitest::Test
  def test_setbit
    assert_equal 'SetBit(id=2, frame="foo", profileID=10)', SetBit.new(2, 'foo', 10).to_pql
    # TODO value error for id, profileID as string

  end

  def test_clearbit
    assert_equal 'ClearBit(id=2, frame="foo", profileID=11)', ClearBit.new(2, 'foo', 11).to_pql

  end

  def test_bitmap
    assert_equal 'Bitmap(id=4, frame="a")', Bitmap.new(4, 'a').to_pql
    # TODO value error for id as string

  end

  def test_union
    q1 = Bitmap.new(4, 'a')
    q2 = Bitmap.new(5, 'b')
    q = Union.new(q1, q2)
    assert_equal 'Union(Bitmap(id=4, frame="a"), Bitmap(id=5, frame="b"))', q.to_pql
  end

  def test_intersect
    q1 = Bitmap.new(4, 'a')
    q2 = Bitmap.new(5, 'b')
    q = Intersect.new(q1, q2)
    assert_equal 'Intersect(Bitmap(id=4, frame="a"), Bitmap(id=5, frame="b"))', q.to_pql
  end

  def test_difference
    # TODO test input limit
    q1 = Bitmap.new(4, 'a')
    q2 = Bitmap.new(5, 'b')
    q = Difference.new(q1, q2)
    assert_equal 'Difference(Bitmap(id=4, frame="a"), Bitmap(id=5, frame="b"))', q.to_pql
  end

  def test_count
    # TODO test input limit
    q = Count.new(Bitmap.new(4, 'a'))
    assert_equal 'Count(Bitmap(id=4, frame="a"))', q.to_pql

  end

  def test_topn
    q = TopN.new(Bitmap.new(4, 'a'), "blah", 10)
    assert_equal 'TopN(Bitmap(id=4, frame="a"), frame="blah", n=10)', q.to_pql
  end

  def test_escape_string_value
    assert_equal escape_string_value(1), '1'
    assert_equal escape_string_value('abc'), '"abc"'
    assert_equal escape_string_value(true), 'true'
    assert_equal escape_string_value(false), 'false'
  end

  def test_range
    t1 = Time.parse("2016-11-08 23:04:00 UTC")
    t2 = Time.parse("2016-11-09 10:00:00 UTC")
    q = Range_.new(6, "snap", t1, t2)
    assert_equal 'Range(id=6, frame="snap", start="2016-11-08T23:04:00.000", end="2016-11-09T10:00:00.000")', q.to_pql
  end

  def test_setbitmapattrs
    q = SetBitmapAttrs.new(2, 'foo', 'bar': 2)
    assert_equal 'SetBitmapAttrs(id=2, frame="foo", bar=2)', q.to_pql
    q = SetBitmapAttrs.new(2, 'foo', 'bar': 'string')
    assert_equal 'SetBitmapAttrs(id=2, frame="foo", bar="string")', q.to_pql
    q = SetBitmapAttrs.new(2, 'foo', 'bar': true)
    assert_equal 'SetBitmapAttrs(id=2, frame="foo", bar=true)', q.to_pql

    # TODO: whats the right way to test an error is raised properly?
    begin
      q = SetBitmapAttrs.new(2, 'foo')  #
    rescue
      assert_equal 'no attribute provided', "#{$!}"
    end

  end

  def test_setprofileattrs
    assert_equal 'SetProfileAttrs(id=4, bar=5)', SetProfileAttrs.new(4, 'bar': 5).to_pql
  end
end

