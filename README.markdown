# NOTICE
This is an early version and I don't expect it to work in all cases.

Currently, the biggest item that I am working on is getting dates extracted correctly.

If you have suggestions or an .adt file that has issues being read then let me know and I might be able to work on it.

# Ruby-ADT

Ruby ADT is a small fast library for reading Advantage Database Server database files (.ADT)

* Project page: <http://github.com/chasemgray/Ruby-ADT>
* Original post: <http://chase.ratchetsoftware.com/2010/02/reading-advantage-database-server-files-adt-in-ruby>
* Report bugs: <http://github.com/chasemgray/Ruby-ADT/issues>
* Questions: Email <mailto:chase@ratchetsoftware.com> and put ADT somewhere in the subject line

## Installation
  
    gem install ruby-adt
  
## Basic Usage

Load an ADT file:

    require 'rubygems'
    require 'adt'

    table = ADT::Table.new("test.adt")

Enumerate all records

    table.each do |record|
      puts record.name
      puts record.email
    end
    
Load a single record using <tt>record</tt> or <tt>find</tt>

    table.record(6)
    table.find(6)

Attributes can also be accessed through the attributes hash in original or
underscored form or as an accessor method using the underscored name.

    table.record(4).attributes["PhoneBook"]
    table.record(4).attributes["phone_book"]
    table.record(4).phone_book
  
Search for records using a simple hash format.  Multiple search criteria are
ANDed. Use the block form of find if the resulting recordset could be large
otherwise all records will be loaded into memory.
    
    # find all records with first_name equal to Keith
    table.find(:all, :first_name => 'Keith') do |record|
      puts record.last_name
    end
    
    # find all records with first_name equal to Keith and last_name equal
    # to Morrison
    table.find(:all, :first_name => 'Keith', :last_name => 'Morrison') do |record|
      puts record.last_name
    end
    
    # find the first record with first_name equal to Keith
    table.find :first, :first_name => 'Keith'
    
    # find record number 10
    table.find(10)
  
## Migrating to ActiveRecord

An example of migrating a DBF book table to ActiveRecord using a migration:

    require 'adt'

    class CreateBooks < ActiveRecord::Migration
      def self.up
        table = ADT::Table.new('db/adt/books.adt')
        eval(table.schema)

        table.each do |record|
          Book.create(record.attributes)
        end
      end

      def self.down
        drop_table :books
      end
    end
  
## Limitations and known bugs
  
* ADT is read-only
* External index files are not used

## Acknowledgements 


## License

(The MIT Licence)

Copyright (c) 2010-2010 Chase Gray <mailto:chase@ratchetsoftware.com>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
