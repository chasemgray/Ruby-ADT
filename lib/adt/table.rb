module ADT
 
  # ADT::Table is the primary interface to a single ADT file and provides
  # methods for enumerating and searching the records.
  class Table
    attr_reader :column_count # The total number of columns
    attr_reader :columns # An array of DBF::Column
    attr_reader :options # The options hash used to initialize the table
    attr_reader :data # ADT file handle
    attr_reader :record_count # Total number of records
    
    # Opens a ADT:Table
    # Example:
    # table = ADT::Table.new 'data.adt'
    #
    # @param [String] path Path to the adt file
    def initialize(path)
      @data = File.open(path, 'rb')
      reload!
    end
    
    # Closes the table 
    def close
      @data.close
    end
    
    # Reloads the database
    def reload!
      @records = nil
      get_header_info
      get_column_descriptors
    end
  
    
    # Retrieve a Column by name
    #
    # @param [String, Symbol] column_name
    # @return [ADT::Column]
    def column(column_name)
      @columns.detect {|f| f.name == column_name.to_s}
    end
    
    # Calls block once for each record in the table. The record may be nil
    # if the record has been marked as deleted.
    #
    # @yield [nil, ADT::Record]
    def each
      0.upto(@record_count - 1) do |n|
        seek_to_record(n)
        yield ADT::Record.new(self)
      end
    end
    
    # Retrieve a record by index number
    #
    # @param [Fixnum] index
    # @return [ADT::Record]
    def record(index)
      seek_to_record(index)
      ADT::Record.new(self)
    end
    
    alias_method :row, :record
    
    
    # Generate an ActiveRecord::Schema
    #
    # xBase data types are converted to generic types as follows:
    # - Number columns with no decimals are converted to :integer
    # - Number columns with decimals are converted to :float
    # - Date columns are converted to :datetime
    # - Logical columns are converted to :boolean
    # - Memo columns are converted to :text
    # - Character columns are converted to :string and the :limit option is set
    # to the length of the character column
    #
    # Example:
    # create_table "mydata" do |t|
    # t.column :name, :string, :limit => 30
    # t.column :last_update, :datetime
    # t.column :is_active, :boolean
    # t.column :age, :integer
    # t.column :notes, :text
    # end
    #
    # @param [optional String] path
    # @return [String]
    def schema(path = nil)
      s = "ActiveRecord::Schema.define do\n"
      s << " create_table \"#{File.basename(@data.path, ".*")}\" do |t|\n"
      columns.each do |column|
        s << " t.column #{column.schema_definition}"
      end
      s << " end\nend"
      
      if path
        File.open(path, 'w') {|f| f.puts(s)}
      end
        
      s
    end
    
    def to_a
      records = []
      each {|record| records << record if record}
      records
    end
    
    # Dumps all records to a CSV file. If no filename is given then CSV is
    # output to STDOUT.
    #
    # @param [optional String] path Defaults to basename of adt file
    def to_csv(path = nil)
      path = File.basename(@data.path, '.adt') + '.csv' if path.nil?
      FCSV.open(path, 'w', :force_quotes => true) do |csv|
        each do |record|
          csv << record.to_a
        end
      end
    end
    
    # Find records using a simple ActiveRecord-like syntax.
    #
    # Examples:
    # table = ADT::Table.new 'mydata.adt'
    #
    # # Find record number 5
    # table.find(5)
    #
    # # Find all records for Chase Gray
    # table.find :all, :first_name => "Chase", :last_name => "Gray"
    #
    # # Find first record
    # table.find :first, :first_name => "Chase"
    #
    # The <b>command</b> may be a record index, :all, or :first.
    # <b>options</b> is optional and, if specified, should be a hash where the keys correspond
    # to column names in the database. The values will be matched exactly with the value
    # in the database. If you specify more than one key, all values must match in order
    # for the record to be returned. The equivalent SQL would be "WHERE key1 = 'value1'
    # AND key2 = 'value2'".
    #
    # @param [Fixnum, Symbol] command
    # @param [optional, Hash] options Hash of search parameters
    # @yield [optional, ADT::Record]
    def find(command, options = {}, &block)
      case command
      when Fixnum
        record(command)
      when Array
        command.map {|i| record(i)}
      when :all
        find_all(options, &block)
      when :first
        find_first(options)
      end
    end
    
    private
    
    # Find all matching
    #
    # @param [Hash] options
    # @yield [optional ADT::Record]
    # @return [Array]
    def find_all(options, &block)
      results = []
      each do |record|
        if all_values_match?(record, options)
          if block_given?
            yield(record)
          else
            results << record
          end
        end
      end
      results
    end
    
    # Find first matching
    #
    # @param [Hash] options
    # @return [ADT::Record, nil]
    def find_first(options)
      each do |record|
        return record if all_values_match?(record, options)
      end
      nil
    end
    
    # Do all search parameters match?
    #
    # @param [ADT::Record] record
    # @param [Hash] options
    # @return [Boolean]
    def all_values_match?(record, options)
      options.all? {|key, value| record.attributes[key.to_s.underscore] == value}
    end
    
    
    # Replace the file extension
    #
    # @param [String] path
    # @param [String] extension
    # @return [String]
    def replace_extname(path, extension)
      path.sub(/#{File.extname(path)[1..-1]}$/, extension)
    end

    
    # Determine record count, record_count, and record length
    def get_header_info
      @data.rewind
    
      #column_count_offset = 33, record_count_offset = 24, record_length_offset = 36
      @record_count, @data_offset, @record_length = data.read(HEADER_LENGTH).unpack("@24 I x4 I I")
      @column_count = (@data_offset-400)/200
    end
    
    
    # Retrieves column information from the database
    def get_column_descriptors
      #skip past header to get to column information
      @data.seek(HEADER_LENGTH)
      
      # column names are the first 128 bytes and column info takes up the last 72 bytes.  
      # byte 130 contains a 16-bit column type
      # byte 136 contains a 16-bit length field
      @columns = []
      @column_count.times do
        name, type, length = @data.read(200).unpack('A128 x S x4 S')
        if length > 0
          @columns << Column.new(name.strip, type, length)
        end
      end
      # Reset the column count in case any were skipped
      @column_count = @columns.size
      
      @columns
    end
    
    
    # Seek to a byte offset in the record data
    #
    # @params [Fixnum] offset
    def seek(offset)
      @data.seek(@data_offset + offset)
    end
  
    # Seek to a record
    #
    # @param [Fixnum] index
    def seek_to_record(index)
      seek(index * @record_length)
    end
    
  end
  
end