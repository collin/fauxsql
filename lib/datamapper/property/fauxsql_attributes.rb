module DataMapper
  class Property
    class FauxsqlAttributes < Text
      
      def dump(value)
        return value if value.nil?
        [Marshal.dump(value)].pack("m")
      end
      
      def load(value)
        case value
          when ::String
            Marshal.load(value.unpack("m").first)
          when ::Object
            value
          end
      end
    end
  end
end
