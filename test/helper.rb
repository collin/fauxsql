require 'rubygems'
require 'test/unit'
require 'shoulda'

require 'datamapper'
DataMapper.setup(:default, "sqlite3://:memory:")

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'fauxsql'

class Test::Unit::TestCase
  def checkpoint!
    if @faux
      @faux.save
      @faux.reload
    end
    
    if @other
      @other.save
      @other.reload
    end
  end
end
