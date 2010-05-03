class Fauxsql::Attributes < Hash
  def eql?(other)
    return false
  end
end