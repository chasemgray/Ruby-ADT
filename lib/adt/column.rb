module ADT
	class ColumnLengthError < ADTError; end
	class ColumnNameError < ADTError; end

  TYPES = {4 => 'character', 10 => 'double', 11 => 'integer', 12 => 'short', 20 => 'cicharacter', 3 => 'date', 13 => 'time', 14 => 'timestamp', 15 => 'autoinc'}
  FLAGS = {'character' => 'A', 'double' => 'D', 'integer' => 'i', 'short' => 'S', 'cicharacter' => 'A', 'date' => '?', 'time' => '?', 'timestamp' => '?', 'autoinc' => 'I'}


	class Column
	  attr_reader :name, :type, :length
  
	  # Initialize a new ADT::Column
	  #
	  # @param [String] name
	  # @param [String] type
	  # @param [Fixnum] length
	  def initialize(name, type, length)
	    @name, @type, @length = strip_non_ascii_chars(name), type, length
    
	    raise ColumnLengthError, "field length must be greater than 0" unless length > 0
	    raise ColumnNameError, "column name cannot be empty" if @name.length == 0
	  end

    def data_type(id)
      TYPES[id]
    end

    def flag(type, length = 0)
      data_type = data_type(type)
      flag = FLAGS[data_type]
      if flag.eql? 'A'
        return flag + length.to_s
      end
      return flag
    end
 
	  # Decode a DateTime value
	  #
	  # @param [String] value
	  # @return [DateTime]
	  def decode_datetime(value)
	    days, milliseconds = value.unpack('l2')
	    seconds = milliseconds / 1000
	    DateTime.jd(days, seconds/3600, seconds/60 % 60, seconds % 60) rescue nil
	  end
  
	  # Schema definition
	  #
	  # @return [String]
	  def schema_definition
	    "\"#{name.underscore}\", #{schema_data_type}\n"
	  end
  
	  # Column type for schema definition
	  #
	  # @return [String]
	  def schema_data_type
	    case data_type(type)
	    when "character"
	      ":string, :limit => #{length}"
	    when "cicharacter"
	      ":string, :limit => #{length}"
	    when "double"
	      ":float"
	    when "date"
	      ":date"
	    when "time"
	      ":timestamp"
	    when "timestamp"
	      ":timestamp"
      when "integer"
        ":integer"
      when "autoinc"
        ":integer"
	    else
	      ":string, :limit => #{length}"
	    end
	  end
  
	  # Strip all non-ascii and non-printable characters
	  #
	  # @param [String] s
	  # @return [String]
	  def strip_non_ascii_chars(s)
	    # truncate the string at the first null character
	    s = s[0, s.index("\x00")] if s.index("\x00")
    
	    s.gsub(/[^\x20-\x7E]/,"")
	  end
	end
end