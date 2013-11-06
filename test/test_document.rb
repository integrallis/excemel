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

require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'simplecov'
SimpleCov.command_name 'Unit Tests'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'excemel'

class TestDocument < Test::Unit::TestCase
  def setup
    @xml = Excemel::Document.new :root => "root"
  end

  def test_create
    assert_not_nil @xml
    assert_equal %[<?xml version=\"1.0\"?>\n<root />\n], @xml.to_xml
  end

  def test_simple
    @xml.simple
    assert_equal %[<?xml version=\"1.0\"?>\n<root><simple /></root>\n], @xml.to_xml
  end

  def test_value
    @xml.value("hi")
    assert_equal %[<?xml version=\"1.0\"?>\n<root><value>hi</value></root>\n], @xml.to_xml
  end

  def test_nested
    @xml.outer { |x| x.inner("x") }
    assert_equal %[<?xml version=\"1.0\"?>\n<root><outer><inner>x</inner></outer></root>\n], @xml.to_xml
  end

  def test_attributes
    @xml.ref(:id => 12)
    assert_equal %[<?xml version=\"1.0\"?>\n<root><ref id=\"12\" /></root>\n], @xml.to_xml
  end

  def test_string_attributes_are_quoted_by_default
    @xml.ref(:id => "H&R")
    assert_equal %[<?xml version=\"1.0\"?>\n<root><ref id=\"H&amp;R\" /></root>\n], @xml.to_xml
  end

  def test_mixed_attribute_quoting_with_nested_builders
    @xml.ref(:id=>:"H&amp;R") { |x|
     x.element(:tag=>"Long&Short")
    }
    assert_equal "<?xml version=\"1.0\"?>\n<root><ref id=\"H&amp;amp;R\"><element tag=\"Long&amp;Short\" /></ref></root>\n", @xml.to_xml
  end

  def test_multiple_attributes
    @xml.ref(:id => 12, :name => "bill")
    assert_equal %[<?xml version=\"1.0\"?>\n<root><ref id=\"12\" name=\"bill\" /></root>\n], @xml.to_xml
  end

  def test_attributes_with_text
    @xml.a("link", :href=>"http://www.integrallis.com")
    assert_equal %{<?xml version=\"1.0\"?>\n<root><a href=\"http://www.integrallis.com\">link</a></root>\n}, @xml.to_xml
  end
  
  def test_complex
    @xml.body(:bg=>"#ffffff") { |x|
      x.title("T", :style=>"red")
    }
    assert_equal %{<?xml version=\"1.0\"?>\n<root><body bg=\"#ffffff\"><title style=\"red\">T</title></body></root>\n}, @xml.to_xml
  end

  def test_funky_symbol
    @xml.tag!("non-ruby-token", :id=>1) { |x| x.ok }
    assert_equal %{<?xml version=\"1.0\"?>\n<root><non-ruby-token id=\"1\"><ok /></non-ruby-token></root>\n}, @xml.to_xml
  end

  def test_tag_can_handle_private_method
    @xml.tag!("loop", :id=>1) { |x| x.ok }
    assert_equal %{<?xml version=\"1.0\"?>\n<root><loop id=\"1\"><ok /></loop></root>\n}, @xml.to_xml
  end

  def test_no_explicit_marker
    @xml.p { |x| x.b("HI") }
    assert_equal "<?xml version=\"1.0\"?>\n<root><p><b>HI</b></p></root>\n", @xml.to_xml
  end

  def test_reference_local_vars
    n = 3
    @xml.ol { |x| n.times { x.li(n) } }
    assert_equal "<?xml version=\"1.0\"?>\n<root><ol><li>3</li><li>3</li><li>3</li></ol></root>\n", @xml.to_xml
  end

  def test_reference_methods
    @xml.title { |x| x.a { x.b(name) } }
    assert_equal "<?xml version=\"1.0\"?>\n<root><title><a><b>bob</b></a></title></root>\n", @xml.to_xml
  end
  
  def test_append_text
    @xml.p { |x| x.br; x.text! "HI" }
    assert_equal "<?xml version=\"1.0\"?>\n<root><p><br />HI</p></root>\n", @xml.to_xml    
  end

  def test_capitalized_method
    @xml.P { |x| x.B("hi"); x.BR(); x.EM { x.text! "world" } }
    assert_equal "<?xml version=\"1.0\"?>\n<root><P><B>hi</B><BR /><EM>world</EM></P></root>\n", @xml.to_xml
  end

  def test_escaping
    @xml.div { |x| x.text! "<hi>"; x.em("H&R Block") }
    assert_equal %{<?xml version=\"1.0\"?>\n<root><div>&lt;hi&gt;<em>H&amp;R Block</em></div></root>\n}, @xml.to_xml
  end

  def test_return_value
    value = @xml.x("men")
    assert_equal @xml.to_xml, value.to_xml
  end

  def test_stacked_builders
    @xml.div { @xml.span { @xml.a("text", :href=>"ref") } }
    assert_equal "<?xml version=\"1.0\"?>\n<root><div><span><a href=\"ref\">text</a></span></div></root>\n", @xml.to_xml
  end
  
  def test_navigate_and_add_attributes
    xml = %[<doc><tag1><message>No</message></tag1><tag2><message>More</message></tag2></doc>]

    doc = Excemel::Document.new :xml => xml
    doc.attributes("message_body" => "you are here") if doc.target! "doc/tag1/message"
    assert_equal "<?xml version=\"1.0\"?>\n<doc><tag1><message message_body=\"you are here\">No</message></tag1><tag2><message>More</message></tag2></doc>\n", doc.to_xml
  end
  
  def test_target_doesnt_exist
    xml = %[<doc><tag1><message>No</message></tag1><tag2><message>More</message></tag2></doc>]
  
    doc = Excemel::Document.new :xml => xml
    
    assert_equal doc.target!("doc/tag3/message"), false
  end
  
  def test_remove_attributes
    @xml.div { @xml.span { @xml.a("text", :href=>"ref") } }

    @xml.attributes("href" => nil) if @xml.target! "//a"
    assert_equal "<?xml version=\"1.0\"?>\n<root><div><span><a>text</a></span></div></root>\n", @xml.to_xml
  end
  
  def test_comments
    @xml.head {                         
      @xml.title "History"     
    }                                                                 
    @xml.body {                                
      @xml.comment! " HI "                   
      @xml.h1 "Header"                        
      @xml.p "paragraph"                     
    }                                    
    assert_match /<!-- HI -->/, @xml.to_xml
  end
  
  def test_processing_instruction_to_xml
    @xml.processing_instruction!('test', 'test')
    assert_match /<\?test test\?>/, @xml.to_xml
  end
  
  def test_processing_instruction_fail_if_target_contains_colons
    assert_raise Java::NuXom::IllegalTargetException do
      @xml.processing_instruction!('test:test', 'test')
    end
  end
  
  def test_to_pretty_xml
    @xml.head {                         
      @xml.title "History"     
    }                                                                 
    @xml.body {                                
      @xml.comment! " HI "                   
      @xml.h1 "Header"                        
      @xml.p "paragraph"                     
    }                                    
    assert_equal "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<root>\r\n  <head>\r\n    <title>History</title>\r\n  </head>\r\n  <body>\r\n    <!-- HI -->\r\n    <h1>Header</h1>\r\n    <p>paragraph</p>\r\n  </body>\r\n</root>\r\n", @xml.to_pretty_xml
  end
  
  def test_doc_type_all_args
    @xml.doc_type! "MyName", "-//Me//some public ID", "http://www.w3.org/TR/some.dtd"
    assert_match /<!DOCTYPE MyName PUBLIC "-\/\/Me\/\/some public ID" "http:\/\/www.w3.org\/TR\/some.dtd">/, @xml.to_xml
  end
  
  def test_doc_type_only_public_id
    @xml.doc_type! "MyName", "-//Me//some public ID"
    assert_match /<!DOCTYPE MyName PUBLIC \"-\/\/Me\/\/some public ID\" \"\">/, @xml.to_xml
  end
  
  def test_doc_type_only_private_id
    @xml.doc_type! "MyName", nil, "http://www.w3.org/TR/some.dtd"
    assert_match /<!DOCTYPE MyName SYSTEM "http:\/\/www.w3.org\/TR\/some.dtd">/, @xml.to_xml
  end
  
  def test_xpath_query
    @xml.head {                         
      @xml.title "History"     
    }                                                                 
    @xml.body {                                
      @xml.comment! " HI "                   
      @xml.h1 "Header"                        
      @xml.p "paragraph"                     
    }                                    
    assert_equal "History", @xml.query("//title").first
  end
  
  def test_extract_test
    xml = %[<doc><word>I </word><word>am </word><word>the </word><word>decider</word></doc>]

    doc = Excemel::Document.new :xml => xml

    assert_equal 'I am the decider', doc.extract_text
  end
  
  def test_to_canonical_form
    xml = %[<?xml version="1.0" encoding="ISO-8859-1"?><foo>bar</foo>]
    doc = Excemel::Document.new :xml => xml
    assert_equal '<foo>bar</foo>', doc.to_canonical_form
  end
  
  def test_namespaces
    namespace = "http://www.w3.org/1998/Math/MathML"
    doc = Excemel::Document.new :root => "mathml:math", :namespace => namespace
    doc.tag! "mathml:mrow" do
      doc.tag! "mathml:mi", "f(1)"
      doc.tag! "mathml:mo", "="
      doc.tag! "mathml:mn", 1
    end
    
    expected = %[<mathml:math xmlns:mathml="http://www.w3.org/1998/Math/MathML"><mathml:mrow><mathml:mi>f(1)</mathml:mi><mathml:mo>=</mathml:mo><mathml:mn>1</mathml:mn></mathml:mrow></mathml:math>]

    assert_match /#{Regexp.quote(expected)}/, doc.to_xml
  end
  
  def test_nested_namespace
    namespace = "http://www.w3.org/1998/Math/MathML"
    doc = Excemel::Document.new :root => "d:student", :namespace => 'http://www.develop.com/student'
    doc.tag! 'd:id', '3235329'
    doc.tag! 's:name', {:namespace => 'urn:names-r-us'} do
      doc.text! 'Jeff Smith'
    end
    doc.tag! 'd:language', 'C#'
    doc.tag! 'd:rating', 35
    
    expected = %[<d:student xmlns:d="http://www.develop.com/student"><d:id>3235329</d:id><s:name xmlns:s="urn:names-r-us">Jeff Smith</s:name><d:language>C#</d:language><d:rating>35</d:rating></d:student>]

    # <d:student xmlns:d="http://www.develop.com/student">
    #   <d:id>3235329</d:id>
    #   <s:name xmlns:s="urn:names-r-us">Jeff Smith</s:name>
    #   <d:language>C#</d:language>
    #   <d:rating>35</d:rating>
    #  </d:student>
    
    assert_match /#{Regexp.quote(expected)}/, doc.to_xml
  end
  
  def test_build_from_file
    doc = Excemel::Document.new :file => "#{File.dirname(__FILE__)}/test_doc_1.xml"
    expected = %[<color_swatch image="burgundy_cardigan.jpg">Burgundy</color_swatch>]
    assert_match /#{Regexp.quote(expected)}/, doc.to_xml
  end
  
  def test_build_from_url
    doc = Excemel::Document.new :url => "http://news.bbc.co.uk/rss/newsonline_uk_edition/world/rss.xml"

    headlines = doc.query '//title'
    
    assert_equal true, headlines.size > 0
  end
  
  private 
  
  def name
    "bob"
  end
  
end

class TestAttributeEscaping < Test::Unit::TestCase

  def setup
    @xml = Excemel::Document.new :root => "root"
  end

  def test_element_gt
    @xml.title('1<2')
    assert_equal %[<?xml version=\"1.0\"?>\n<root><title>1&lt;2</title></root>\n], @xml.to_xml
  end

  def test_element_amp
    @xml.title('AT&T')
    assert_equal %[<?xml version=\"1.0\"?>\n<root><title>AT&amp;T</title></root>\n], @xml.to_xml
  end

  def test_element_amp2
    @xml.title('&amp;')
    assert_equal %[<?xml version=\"1.0\"?>\n<root><title>&amp;amp;</title></root>\n], @xml.to_xml
  end

  def test_attr_less
    @xml.a(:title => '2>1')
    assert_equal %[<?xml version=\"1.0\"?>\n<root><a title=\"2&gt;1\" /></root>\n], @xml.to_xml
  end

  def test_attr_amp
    @xml.a(:title => 'AT&T')
    assert_equal %[<?xml version=\"1.0\"?>\n<root><a title=\"AT&amp;T\" /></root>\n], @xml.to_xml
  end

  def test_attr_quot
    @xml.a(:title => '"x"')
    assert_equal %[<?xml version=\"1.0\"?>\n<root><a title=\"&quot;x&quot;\" /></root>\n], @xml.to_xml
  end

end
