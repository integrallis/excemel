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

xml = %[
       <library>
         <shelf>
           <name>top shelf</name>
           <book>
             <title>Cat in the Hat</title>
             <author>Dr. Seuss</author>
           </book>
         </shelf>
         <shelf>
           <name>middle shelf</name>
           <book>
             <title>How to use the XMLSlurper</title>
             <author>Joe Niche</author>
           </book>
            <book>
              <title>Excemel for Geniuses</title>
              <author>Brian Sam-Bodden</author>
            </book>
         </shelf>
         <shelf>
           <name>bottom shelf</name>
           <book>
             <title>XmlSlurper for Dummies</title>
             <author>Jane Niche</author>
           </book>
         </shelf>
       </library>
       ]

doc = Excemel::Document.new :xml => xml

doc.find(:all => "library.shelf", :where => "book.author = 'Brian Sam-Bodden'").each do |shelf|
  puts "{shelf.name} shelf has a Brian Sam-Bodden book"
end