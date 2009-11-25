#!/usr/bin/env ruby
 
#--
# Copyright &169;2001-2008 Integrallis Software, LLC. 
# All Rights Reserved.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
  
require 'excemel/excemel'

address_book_xml = %[
<address_book>
  <person first='John' last='Doe'>
    <address city='New York' street='118 St.' number='344' state='NY'/>
  </person>
  <person first='Brian' last='Sam-Bodden'>
    <address city='Scottsdale' street='Full of Cacti' number='8675309' state='AZ'/>
  </person>
  <person first='Brian' last='Sletten'>
    <address city='Washington D.C.' street='Briarshire' number='123' state='DC'/>
  </person>
</address_book>
]

address_book = Excemel::Document.new :xml => address_book_xml

puts "<---- Pretty Printed XML ----->"
puts address_book.to_pretty_xml

puts "\n<---- The cities where the Brians live ----->"
address_book.query("//person[@first='Brian']/address/@city").each do |city|
  puts "City: #{city}"
end
