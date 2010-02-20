module ADT
	class ColumnLengthError < ADTError; end
	class ColumnNameError < ADTError; end

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
  
	  # Cast value to native type
	  #
	  # @param [String] value
	  # @return [Fixnum, Float, Date, DateTime, Boolean, String]
	  def type_cast(value)

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
  
	  # Decode a boolean value
	  #
	  # @param [String] value
	  # @return [Boolean]
	  def boolean(value)
	    value.strip =~ /^(y|t)$/i ? true : false
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
	    case type
	    when "N"
	      decimal > 0 ? ":float" : ":integer"
	    when "I"
	      ":integer"
	    when "D"
	      ":date"
	    when "T"
	      ":datetime"
	    when "L"
	      ":boolean"
	    when "M"
	      ":text"
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