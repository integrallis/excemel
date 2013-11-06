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
      resolve_includes = _extract_options(options, :resolve_includes, true)
      
      _build_document(options)
            
      @doc = XOM::XIncluder.resolve(@doc) if resolve_includes  
      @target = @root
    end
    
    # Dynamic Proxy behavior
    # Add XML elements (tags) based on the name of the method called on the 
    # Document instance, blocks passed get processed recursively
    def method_missing(sym, *args, &block)
      unless %w(class to_s inspect).include?(sym.to_s)                                      
        sym = _extract_sym(args, sym)
        attrs, namespace, prefix, text = _process_args(args, sym)
        tag = _build_tag(sym, namespace)   
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
      doctype = XOM::DocType.new(root_element_name, public_id, system_id)
      @doc.insert_child(doctype, 0)
      self
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
    # target, passing an attribute with a value of nil, removes the attribute if
    # it exists
    def _add_attributes(target, attrs)
      if attrs    
        attrs.each do |key, value|
          unless value.nil?
            attribute = XOM::Attribute.new(key.to_s, value.to_s)
            target.add_attribute(attribute)
          else
            attribute = target.get_attribute(key.to_s)
            target.remove_attribute(attribute) if attribute
          end
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
    
    def _build_tag(sym, namespace = nil)
      if namespace && !namespace.empty?
        tag = XOM::Element.new sym.to_s, namespace
      else
        tag = XOM::Element.new sym.to_s
      end
      tag
    end
    
    def _get_namespace(prefix)
      @namespaces ? "#{@namespaces[prefix]}" : nil
    end
    
    def _extract_sym(args, sym)
      args.first.kind_of?(Symbol) ? "#{sym}:#{args.shift}" : sym
    end
    
    def _extract_prefix(sym)
      sym.to_s.include?(':') ? sym.to_s.split(":").first : nil 
    end
    
    def _process_args(args, sym)
      attrs, namespace, text = nil
      prefix = _extract_prefix(sym)
      args.each do |arg|
        case arg
        when Hash
          if arg.has_key? :namespace
            namespace = arg[:namespace]
            prefix = sym.to_s.split(":").first
            (@namespaces ||= {})[prefix] = namespace if prefix
          else
            attrs ||= {}
            attrs.merge!(arg)
          end
        else
          text ||= ''
          text << arg.to_s
        end
      end
      namespace = _get_namespace(prefix) if prefix
      [attrs, namespace, prefix, text]
    end
    
    def _extract_options(options, sym, boolean = false)
      boolean ? (options[sym] ? options[sym] : false) : options[sym]
    end
    
    def _generate_doc_from_source(options, builder)
      doc = nil
      xml = _extract_options(options, :xml)
      url = _extract_options(options, :url)
      file = _extract_options(options, :file)
      
      if xml
        doc = builder.build(xml, nil)
      elsif url
        doc = builder.build url
      elsif file
        java_file = Java::JavaIo::File.new file        
        doc = builder.build java_file       
      end
      
      doc
    end
    
    def _build_document(options)
      root = _extract_options(options, :root)
      namespace = _extract_options(options, :namespace)
      validate = _extract_options(options, :validate, true)
      
      if root
        _build_document_from_root(root, namespace)
      else
        @doc = _generate_doc_from_source(options, XOM::Builder.new(validate))
        @root = @doc.get_root_element
      end
    end
    
    def _build_document_from_root(root, namespace)
      @root = _build_tag(root, namespace) 
      if namespace
        prefix = root.to_s.split(":").first if root.include? ":"
        (@namespaces ||= {})[prefix] = namespace if prefix
      end
      @doc = XOM::Document.new @root
    end
    
  end 
  
end
