
InvalidQuery = Class.new(StandardError)


def escape_string_value(val)
  # TODO: equivalent of basestring in python?
  if val.class == String
    return "\"#{val}\""
  end
  return val.to_s
end


class Query
  attr_reader :is_write

  def initialize(*inputs)
    @is_write = false
    @inputs = inputs
    self.check_inputs
  end

  def check_inputs
    # TODO: is there a cleaner way?
    # SetBit/ClearBit need to override is_write
    # Difference/Count need to define input_limit
    # in python these can be done concisely with class variables,
    # but they're weird in ruby
    # could call parent constructor, but this seems better than that
    if self.instance_variable_defined?(:@input_limit) and @inputs.count > @input_limit
      raise InvalidQuery, "too many inputs (#{@inputs.count} > #{@input_limit})"
    end
  end

  def to_pql()
    subq_str = @inputs.map { |subq| subq.to_pql }.join(', ')
    "#{self.class.name}(#{subq_str})"
  end
end


class SetBit < Query
  def initialize(id, frame, profile_id)
    @id = id
    @frame = frame
    @profile_id = profile_id
    @is_write = true
  end

  def to_pql
    # TODO concise self.class.name?
    "#{self.class.name}(id=#{@id}, frame=\"#{@frame}\", profileID=#{@profile_id})"
  end
end


ClearBit = Class.new(SetBit)


class SetBitmapAttrs < Query
  def initialize(id, frame, **attrs)
    @id = id
    @frame = frame
    @attrs = attrs
    raise InvalidQuery, 'no attribute provided' unless attrs.count > 0
  end

  def to_pql
    attrs_str = @attrs.map { |k, v| "#{k}=#{escape_string_value(v)}" }.join(', ')
    "#{self.class.name}(id=#{@id}, frame=\"#{@frame}\", #{attrs_str})"
  end
end


class Bitmap < Query
  def initialize(id, frame)
    @id = id
    @frame = frame
  end

  def to_pql
    "#{self.class.name}(id=#{@id}, frame=\"#{@frame}\")"
  end
end


class SetProfileAttrs < Query
  def initialize(id, **attrs)
    @id = id
    @attrs = attrs
    raise InvalidQuery, 'no attribute provided' unless attrs.count > 0
  end

  def to_pql
    attrs_str = @attrs.map { |k, v| "#{k}=#{escape_string_value(v)}" }.join(', ')
    "#{self.class.name}(id=#{@id}, #{attrs_str})"
  end
end

Union = Class.new(Query)

Intersect = Class.new(Query)

class Difference < Query
  # TODO cleaner way? see Query.initialize
  def initialize(*inputs)
    @is_write = false
    @input_limit = 2
    @inputs = inputs
    self.check_inputs
  end
end

class Count < Query
  # TODO cleaner way? see Query.initialize
  def initialize(*inputs)
    @is_write = false
    @input_limit = 1
    @inputs = inputs
    self.check_inputs
  end
end


class Range_ < Query
  # TODO Range is a reserved classname. is it possible/safe to overload this?
  # https://ruby-doc.org/core-2.2.0/Range.html
  def initialize(id, frame, range_start, range_end)
    @id = id
    @frame = frame
    @range_start = range_start
    @range_end = range_end
  end

  def to_pql
    start_str = @range_start.iso8601(3)[0..-2]
    end_str = @range_end.iso8601(3)[0..-2]
    "Range(id=#{@id}, frame=\"#{@frame}\", start=\"#{start_str}\", end=\"#{end_str}\")"
  end
end


class TopN < Query
  def initialize(query, frame, n, ids=nil, filter_field=nil, filter_values=[])
    @query = query
    @frame = frame
    @n = n
    # @ids = ids  # TODO: support 'ids'
    @filter_field = filter_field
    @filter_values = filter_values
  end

  def to_pql
    pql = "#{self.class.name}("
    if @query
      pql += sprintf('%s, ', @query.to_pql)
    end
    pql += "frame=\"#{@frame}\", n=#{@n}"
    if @filter_field
      values_str = @filter_values.map { |v| escape_string_value(v) }.join(', ')
      pql += ", field=\"#{@filter_field}\", [#{values_str}]"
    end
    pql += ')'
    pql
  end
end
