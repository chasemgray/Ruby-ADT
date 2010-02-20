
require 'date'

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


require 'adt/globals'
require 'adt/record'
require 'adt/column'
require 'adt/table'


