class Fauxsql::Options < Hash
  def [](key)
    super(key) || {}
  end
end