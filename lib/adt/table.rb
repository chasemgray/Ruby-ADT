
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