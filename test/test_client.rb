require 'minitest/autorun'
require 'time'
require "uri"
require 'json'
require 'query'
require 'client'

class ClientTest < Minitest::Test
  def test_execute
    # TODO mock post
    db = 2
    c = Client.new

    bit_map = Bitmap.new(10, 'foo')
    c.execute(db, bit_map)

    q = bit_map.to_pql
    uri = URI.parse("http://#{c.hosts[0]}/query?db=#{db}")

    # mock_post.assert_called_with <uri, data=query>

  end

  def test_invalid_query_input
    # TODO


  end

  def test_schema
    # sanity check - requires pilosa node
    assert_equal 200, Client.new.schema.code.to_i
  end

  def test_execute_query_string
    # test responses - requires pilosa node
    db = 2
    c = Client.new

    set_bit1 = SetBit.new(10, 'foo', 1).to_pql
    set_bit2 = SetBit.new(20, 'foo', 2)
    set_response1 = c.execute(db, set_bit1)
    set_response2 = c.execute(db, set_bit2)
    assert_equal 200, set_response1.code.to_i
    assert_equal 200, set_response2.code.to_i

    bitmap1 = Bitmap.new(10, 'foo').to_pql
    bitmap2 = Bitmap.new(20, 'foo')
    get_response1 = c.execute(db, bitmap1)
    get_response2 = c.execute(db, bitmap2)
    assert_equal 200, get_response1.code.to_i
    assert_equal 200, get_response2.code.to_i

    resp1_json = JSON.parse(get_response1.body)
    resp2_json = JSON.parse(get_response2.body)
    assert_equal [1], resp1_json['results'][0]['bits']
    assert_equal [2], resp2_json['results'][0]['bits']

  end

end
