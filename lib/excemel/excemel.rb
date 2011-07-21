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
 
require 'rubygems' 
require 'blankslate' 
require 'java'
require 'module/lang'
require 'module/xom'

module Excemel
  
  class Document < BlankSlate
    
    # Create an Excemel Document
    # The method expects a hash that contain the possible elements
    # :root => value : The name of the root or top-most element of the document
    # :xml => value : A string containing an XML document 
    # :url => value : A URL pointing to an XML document
    # :file => filename : A filename pointing to an XML file
    # :validate => true|false : whether to validate the document being read from
    #              an XML string, URL or file
    # :resolve_includes => true|false replaces xi:include elements by the content they refer to
    # :namespace => provides a namespace prefix to the elements
    def initialize(options)
      # extract options
      validate = options[:validate] ? options[:validate] : false
      root = options[:root]
      xml = options[:xml]
      url = options[:url]
      file = options[:file]
      namespace = options[:namespace]
      resolve_includes = options[:resolve_includes] ? options[:resolve_includes] : false
      
      if root
        unless namespace
          @root = XOM::Element.new "#{root}"
        else
          @root = XOM::Element.new "#{root}", namespace
          prefix = root.to_s.split(":").first if root.include? ":"
          (@namespaces ||= {})[prefix] = namespace if prefix
        end
        
        @doc = XOM::Document.new @root
      else
        builder = XOM::Builder.new validate 
      end
      
      if xml
        @doc = builder.build(xml, nil)
      elsif url
        @doc = builder.build url
      elsif file
        java_file = Lang::File.new file        
        @doc = builder.build java_file       
      end
      
      if resolve_includes
        @doc = XOM::XIncluder.resolve(@doc)
      end
      
      @root = @doc.get_root_element unless @root
      @target = @root
    end
    
    # Dynamic Proxy behavior
    # Add XML elements (tags) based on the name of the method called on the 
    # Document instance, blocks passed get processed recursively
    def method_missing(sym, *args, &block)
      if sym.to_s != 'class' && sym.to_s != 'to_s' && sym.to_s != 'inspect' # WTF? If I don't do this I
        text = nil                                 # end up with extraneous tags        
        attrs = nil                                # in the resulting document!!
        namespace = nil
        sym = "#{sym}:#{args.shift}" if args.first.kind_of?(Symbol)
        prefix = sym.to_s.split(":").first if sym.to_s.include? ":"
        args.each do |arg|
          case arg
          when Hash
            if arg.has_key? :namespace
              namespace = arg[:namespace]
              prefix = sym.to_s.split(":").first
            else
              attrs ||= {}
              attrs.merge!(arg)
            end
          else
            text ||= ''
            text << arg.to_s
          end
        end
        
        # try to get the namespace from the saved namespaces
        if prefix != nil && namespace.nil? && @namespaces != nil
          namespace = "#{@namespaces[prefix]}"
        end
        
        unless namespace
          tag = XOM::Element.new sym.to_s
        else
          tag = XOM::Element.new sym.to_s, namespace
        end 
        
        _add_attributes(tag, attrs)
        
        if block
          _nested_structures(block, tag)
        elsif !text.nil?              
          tag.append_child text
        end
        
        @target.append_child tag
      end
      
      self
    end
    
    # Returns the XML document as a single line, e.g. no formatting
    def to_xml
      @doc.to_xml
    end 
 
    # Appends a comment node at the current position in the document
    def comment!(string)
      comment = XOM::Comment.new string
      @target.append_child(comment)
      self
    end
    
    # Appends a text node at the current position in the document
    def text!(string)
      text = XOM::Text.new string
      @target.append_child(text)
      self
    end
    
    # Appends a processing instruction at the current position in the document
    def processing_instruction!(target, data)
      pi = XOM::ProcessingInstruction.new(target, data)
      @target.append_child(pi)
      self
    end
    
    # Attempts to reposition the document pointer based on the first match of 
    # and XQuery expression. Return true is the pointer was successfully moved
    # and false otherwise
    def target!(xpath_query)
      nodes = @doc.query xpath_query
      (0..nodes.size-1).each do |i| 
        node = nodes.get(i)
        if node.class == XOM::Element
          @target = node
          return true
        end        
      end
      return false
    end
    
    # Create a tag named +sym+.  Other than the first argument which
    # is the tag name, the arguments are the same as the tags
    # implemented via <tt>method_missing</tt>.
    # XOM will throw an exception if you pass something with a prefix but no
    # associated namespace
    def tag!(sym, *args, &block)
      method_missing(sym.to_sym, *args, &block)
      self
    end
    
    # Returns a pretty-formatted document with the given indent, max line length
    # and encoding. The preserve_base_uri determines whether preserves the 
    # original base URIs by inserting extra xml:base attributes.
    def to_pretty_xml(indent=2, line_length=0, encoding='utf-8', preserve_base_uri=true)
      baos = Lang::ByteArrayOutputStream.new      
      serializer = XOM::Serializer.new(baos, encoding)
      serializer.indent = indent 
      serializer.max_length = line_length
      serializer.write @doc 
      baos.to_string
    end
    
    # Appends an XML document type declaration at the current position in the 
    # document
    def doc_type!(root_element_name, public_id='', system_id='')
      doctype = XOM::DocType(root_element_name, public_id, system_id)
      @doc.insert_child(doctype, 0)
      self
    end
    
    # Returns the value of the first child element with the specified name in 
    # no namespace. If there is no such element, it returns nill.
    def find_first_tag_by_name(tag_name)
      element = @root.get_first_child_element tag_name
      element ? element.get_value : nil
    end
    
    # Returns the values of the nodes selected by the XPath expression in the 
    # context of this node in document order as defined by XSLT. This XPath 
    # expression must not contain any namespace prefixes.
    def query(xpath_query)
      nodes = @doc.query xpath_query      
      result = Array.new
      (0..nodes.size-1).each do |i| result << nodes.get(i).get_value end
      result
    end
    
    # See Jim Weirich's comment on builder (plus all the test frameworks seem
    # to call nil? on objects being tested
    def nil?
      false
    end
    
    # Returns the value of the document as defined by XPath 1.0. This is the 
    # same as the value of the root element, which is the complete PCDATA 
    # content of the root element, without any tags, comments, or processing 
    # instructions after all entity and character references have been resolved.
    def extract_text
      @doc.get_value
    end
    
    # Returns XML in the format specified by the Canonica XML Version 1.0 
    # (w3.org/TR/2001/REC-xml-c14n-20010315 or Exclusive XML) 
    # Canonicalization Version 1.0 (w3.org/TR/2002/REC-xml-exc-c14n-20020718/)
    def to_canonical_form
      baos = Lang::ByteArrayOutputStream.new
      outputter = XOM::Canonicalizer.new baos
      outputter.write(@doc)
      baos.to_string
    end
    
    # Adds attributes to the current target element (pointer to an element in the document 
    # by default the root of the document)
    def attributes(attrs)
      _add_attributes(@target, attrs)
    end
    
    private
    
    # Adds attributes to the given Element (tag) as define by the parameter 
    # target
    def _add_attributes(target, attrs)
      if attrs    
        attrs.each do |key, value|
          attribute = XOM::Attribute.new(key.to_s, value.to_s)
          target.add_attribute(attribute)
        end
      end
    end  

    # Recursively processed blocks passed to document in the context of a method
    # call
    def _nested_structures(block, new_target)
      old_target = @target
      @target = new_target
      block.call(self)
    ensure
      @target = old_target
    end    
    
  end 
  
end
