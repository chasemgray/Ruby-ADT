module ADT
  class ADTError < StandardError; end
  
  TYPES = {4 => 'character', 10 => 'double', 11 => 'integer', 12 => 'short', 20 => 'cicharacter', 3 => 'date', 13 => 'time', 14 => 'timestamp', 15 => 'autoinc'}
  FLAGS = {'character' => 'A', 'double' => 'F', 'integer' => 'i', 'short' => 'S', 'cicharacter' => 'A', 'date' => '?', 'time' => '?', 'timestamp' => '?', 'autoinc' => 'I'}
  
  def type(id)
    TYPES[id]
  end

  def flag(type, length = 0)
    flag = FLAGS[type]
    if flag.eql? 'character' or flag.eql? 'cicharacter'
      return flag + length.to_s
    end
    return flag
  end
  
  MS_PER_SECOND = 1000
  MS_PER_MINUTE = MS_PER_SECOND * 60
  MS_PER_HOUR = MS_PER_MINUTE * 60
  
  HEADER_LENGTH = 400

  COLUMN_LENGTH = 200
end