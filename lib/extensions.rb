# encoding: utf-8

class Hash
  def present?
    !self.empty?
  end

  def shrink!(max_length = 10000)
    each do |k, v|
      if v.is_a?(Hash)
        v.clean
      elsif v.to_s.length > max_length
        delete(k)
      end
    end
  end

  def clean
    each do |k, v|
      if v.is_a?(Hash)
        v.clean
      elsif v.to_s.empty?
        delete(k)
      end
    end
  end

  def symbolize_keys_recursive
    inject({}) do |_, (key, value)|
      value = value.symbolize_keys_recursive if value.is_a?(Array) || value.is_a?(Hash)
      _[key.to_sym] = value
      _
    end
  end

end

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def present?
    !self.empty?
  end

  def ip_to_i
    self.split('.').inject(0) {|total,value| (total << 8 ) + value.to_i}
  end

  def words
    self.split(/\s+/)
  end

  def urlize
    self.strip.downcase.gsub(/[^a-z]+/, '_')
  end

  def shortize
    self.words.first.downcase
  end

end

class Array
  def present?
    !self.empty?
  end

  def to_pretty_json
    ['[', self.collect {|e| e.to_json}.join(",\n"), ']'].join("\n")
  end

  def symbolize_keys_recursive
    inject([]) do |_, value|
      value = value.symbolize_keys_recursive if value.is_a?(Array) || value.is_a?(Hash)
      _ << value
      _
    end
  end
end

class Symbol
  def <=>(other)
    return to_s <=> other.to_s
  end
end

class NilClass
  def present?
    !!self
  end

  def <=>(other)
    return self.to_s <=> other.to_s
  end
end

class Object

  def sanitize_string(string)
    return string unless string.is_a? String

    # Try it as UTF-8 directly
    cleaned = string.dup.force_encoding('UTF-8')
    if cleaned.valid_encoding?
      cleaned
    else
      # Some of it might be old Windows code page
      string.encode(Encoding::UTF_8, Encoding::Windows_1250)
    end
  rescue EncodingError
    # Force it to UTF-8, throwing out invalid bits
    string.encode!('UTF-8', invalid: :replace, undef: :replace)
  end

  def dur(arr)
    d = {}
    arr.each{|a|
      if a =~ /day$/i or a =~ /days$/i
        d["days"] = a.scan(/([\d.]+)/).flatten.first
      elsif a =~ /week$/i or a =~ /weeks$/i
        d["weeks"] = a.scan(/([\d.]+)/).flatten.first
      elsif a =~ /month$/i or a =~ /months$/i or a =~ /month\(s\)$/i
        d["months"] = a.scan(/([\d.]+)/).flatten.first
      elsif a =~ /year$/i or a =~ /years$/i
        d["years"] = a.scan(/([\d.]+)/).flatten.first
      elsif a=~ /h$/i or a =~ /hours$/i or a =~ /hour$/i or a =~ /hrs/ or a =~ /hr$/
        d["hours"] = a.scan(/([\d.]+)/).flatten.first
      elsif a =~ /m$/i or a =~ /minutes$/i or a =~ /minute$/i or a =~ /min$/ or a =~ /mins$/
        d["minutes"] = a.scan(/([\d.]+)/).flatten.first
      elsif (a =~ /s$/i or a =~ /seconds$/i or a =~ /second$/i)
        tmp = a.scan(/([\d.]+)/).flatten.first
        d["seconds"] = tmp unless tmp == "0"
      end
    }
    return d
  end

  def attribute( node, attr )
    !node ? '' : node.attr( attr )
  end

  def append_base(uri, sub_url)
    case sub_url
    when nil, '', '/'
      ''
    when /^http/
      sub_url
    when /^\/\//
      "http://#{sub_url[2..-1]}"
    else
      if sub_url =~ /^\// || uri =~ /\/$/
        uri.strip + (sub_url.strip).gsub(/(\/)+/,'/').strip
      else
        uri.strip + ('/'+sub_url.strip).gsub(/(\/)+/,'/').strip
      end
    end
  end

  def normalise_utf8_spaces(raw_text)
    raw_text&&raw_text.gsub(/\xC2\xA0/, ' ')
  end

  def strip_all_spaces(text)
    text&&normalise_utf8_spaces(text).strip.gsub(/\s+/,' ')
  end

  def clean_text(raw_element)
    if raw_element.is_a?(Nokogiri::XML::Node)
      cleaned_up_text = strip_all_spaces(raw_element.inner_text)
    else
      strip_all_spaces(raw_element.text)
    end
  end

  def all_text(str)
    ret = []
    if str.kind_of? (Nokogiri::XML::Element)
      tmp = []
      str.children().each{|st|
        tmp << all_text(st)
      } unless str.name == "script" or str.name == 'style'
      ret << tmp
    elsif str.kind_of? (Nokogiri::XML::NodeSet)
      str.collect().each{|st|
        ret << all_text(st)
      }
    elsif str.kind_of? (Nokogiri::XML::Text)
      ret << clean_text(str)
    end
    return ret.flatten
  end

  def is_integer?
    return true if self =~ /^[\d]+$/
    return false
  end

  def seconds_in_words
    secs = self.to_i

    words = [[60, :second], [60, :minute], [24, :hour], [365, :day], [1000000, :year]].collect do |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        [n.to_i, name.to_s.pluralize(n)] unless n.to_i.zero?
      end
    end.compact.reverse

    words.collect {|word| word.join(' ')}.join(', ')
  end

  def pm
    self.public_methods - Object.new.public_methods
  end

  def stats(a = 'to_s')
    self.group_by { |o| o.send(a) }.
         collect  { |(v, o)| [v, o.length] }.
         sort_by  { |(v, o)| o }
  end

  def to_bool
    return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
    return false
  end

  def with_retry(options = {})
    default_options = {
      exceptions: Exception,
      max_retries: 5,
      try: 0,
    }

    o = default_options.merge(options)

    begin
      yield
    rescue *o[:exceptions] => e
      o[:try] += 1
      retry if o[:try] < o[:max_retries]
      raise e
    end
  end

  def normalize
    self.to_s.strip.downcase
  end

  def i_to_ip
    [self.to_i].pack('N').unpack('C4').join('.')
  end

  def to_csv_value
    self.to_s
  end

  def to_e
    self unless self.blank?
  end

end
