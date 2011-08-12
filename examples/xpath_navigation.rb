$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
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
  
require 'excemel'

xml = %[<doc>
          <tag1>
            <message>No</message>
          </tag1>
          <tag2>
            <message>More</message>
          </tag2>
          <tag3>
            <message>Taxes</message>
          </tag3>
        </doc>]

doc = Excemel::Document.new :xml => xml

puts "<---- Pretty Printed XML ----->"
puts doc.to_pretty_xml

puts "\n<---- some XPath expressions ----->"
puts  "doc/tag1/message/text(): #{doc.query("doc/tag1/message/text()")}"
puts  "//message[text() = 'More']/text(): #{doc.query("//message[text() = 'More']/text()")}"

puts "\n<---- Navigate with XPath and insert comments ----->\n"
puts "<----- Navigate to 'doc/tag1/message' and add a comment ----->\n"
doc.comment! "you are here" if doc.target! "doc/tag1/message"

puts doc.to_pretty_xml

puts "\n<----- Navigate to 'doc' and add a comment ----->\n"
doc.comment! "now you are here" if doc.target! "/doc"

puts doc.to_pretty_xml
