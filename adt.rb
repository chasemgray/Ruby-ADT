require 'rubygems'
require 'bit-struct'

class Array
  def every(count)
    chunks = []
    each_with_index do |item, index|
      chunks << [] if index % count == 0
      chunks.last << item
    end
    chunks
  end
  alias / every
end

HEADER_LENGTH = 400

NUM_COLUMNS_OFFSET = 33

NUM_ROWS_OFFSET = 24

COLUMN_NAME_LENGTH = 128

COLUMN_INFO_LENGTH = 72

COLUMN_LENGTH = 200



module ADT
  attr_reader :num_columns, :num_rows, :columns, :rows

  class ADTError < StandardError; end
  
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
  
  
  class Data
    TYPES = {4 => 'character', 10 => 'double', 11 => 'integer', 12 => 'short', 20 => 'cicharacter', 3 => 'date', 13 => 'time', 14 => 'timestamp', 15 => 'autoinc'}
    FLAGS = {'character' => 'A', 'double' => 'F', 'integer' => 'i', 'short' => 'S', 'cicharacter' => 'A', 'date' => '?', 'time' => '?', 'timestamp' => '?', 'autoinc' => 'I'}
    def self.type(id)
      TYPES[id]
    end

    def self.flag(type, length = 0)
      flag = FLAGS[type]
      if flag.eql? 'character' or flag.eql? 'cicharacter'
        return flag + length.to_s
      end
      return flag
    end
  end
  
  class Table
    def initialize(filename)
      @data = open('test.adt').read()
    
      @num_columns = data.unpack("@#{NUM_COLUMNS_OFFSET}S").first.to_i

      @num_rows = data.unpack("@#{NUM_ROWS_OFFSET}S").first.to_i
    
      column_format = "@#{HEADER_LENGTH}"
      num_columns.times do 
         column_format << "A#{COLUMN_NAME_LENGTH}xSxxxxSA#{COLUMN_INFO_LENGTH-9}"
      end
    
      @columns = data.unpack(column_format).every(4).collect do |item|
         {:name => item[0].strip, :type => Data.type(item[1]), :length => item[2].to_i}
      end
    
      row_format = "@#{HEADER_LENGTH+num_columns*COLUMN_LENGTH}"
      columns.each do |column|
         row_format << ""
      end


      @rows = data.unpack(column_format).every(4).collect do |item|
         {:name => item[0].strip, :type => data_types[item[1]], :length => item[2].to_i}
      end
    
    end
  
  
    def schema 
    
    end
  end

end

