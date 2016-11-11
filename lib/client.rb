require "net/http"
require "uri"
require_relative 'query'

Default_host = '127.0.0.1:15000'

class Client
  attr_reader :hosts

  def initialize(hosts=nil)
    @hosts = hosts
    if @hosts == nil
      @hosts = [Default_host]
    end
  end

  def execute(db, queries, profiles=false)
    # queries is a Query, list of Query, or valid pql string
    # profiles is a boolean that indicates whether to return the entire profile, or just the ID

    if queries.is_a? String
      return send_query_string_to_pilosa(db, queries, profiles)
    elsif not queries.is_a? Array
      queries = [queries]
    end

    queries.each do |q|
      raise InvalidQuery, "#{q} is not a Query" unless q.is_a? Query
    end

    queries_string = queries.map { |q| q.to_pql }.join(' ')
    return send_query_string_to_pilosa(db, queries_string, profiles)
  end

  def send_query_string_to_pilosa(db, q, profiles)
    # http://127.0.0.1:15000/query?db=exampleDB
    host = self.get_random_host
    uri = URI.parse("http://#{host}/query?db=#{db}")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = q
    http.request(request)
  end

  def get_random_host
    @hosts.sample
  end

  def schema()
    host = self.get_random_host
    uri = URI.parse("http://#{host}/schema")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.request(request)
  end
end
