class SimpleDiskStore
  EXPIRY = 1 * 60 * 60 * 24 # 1 day

  def initialize(path)
    @base_path = path
  end

  def path_for(key)
    digest = Digest::MD5.hexdigest key
    Pathname.new File.join(@base_path, digest[0...3], digest[3...6], digest[6...9], digest)
  end

  def read(key)
    begin
      path = path_for(key)
      return nil unless File.exists?(path)

      data = File.read(path)
      expiry, data = data.split("|", 2)
      expired_at = Time.parse(expiry)
      return nil if expired_at < Time.now
      return JSON.parse(data).symbolize_keys_recursive[:data]
    rescue Exception => e
      return nil
    end
  end

  def flush
    FileUtils.rm_rf File.join(@base_path, '.')
  end

  def delete(key)
    path = path_for(key)
    return nil unless File.exists?(path)

    FileUtils.rm_f File.join(path)
  end

  def write(key, data)
    path = path_for(key)

    FileUtils.mkdir_p path.dirname
    File.open(path.to_s, 'wb') do |file|
      begin
        file.write [Time.now + EXPIRY, {data: data}.to_json].join("|")
      rescue
        data = {body: data["body"].to_s.force_encoding("ISO-8859-1").encode("UTF-8"), headers: data["headers"], code: data["code"]}
        file.write [Time.now + EXPIRY, {data: data}.to_json].join("|")
      end
    end

    path
  end

  def fetch(key, &block)
    data = read(key)
    return data if data

    data = block.call
    write key, data

    return data
  end

end

