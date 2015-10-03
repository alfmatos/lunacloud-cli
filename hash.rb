# https://gist.github.com/dimus/335286
require 'rubygems'
require 'nokogiri'
# USAGE: Hash.from_xml(YOUR_XML_STRING)

# http://stackoverflow.com/questions/5622435/how-do-i-convert-a-ruby-class-name-to-a-underscore-delimited-symbol
class String
  def underscore
    word = self.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end

class Hash
  class << self
    def from_xml(xml_io)
      begin
        result = Nokogiri::XML(xml_io)
        return { result.root.name.underscore.to_sym => xml_node_to_hash(result.root)}
      rescue Exception => e
        puts e
      end
    end

    def xml_node_to_hash(node)
      # If we are at the root of the document, start the hash 
      if node.element?
        result_hash = {}
        if node.attributes != {}
          attributes = {}
          node.attributes.keys.each do |key|
            attributes[node.attributes[key].name.underscore.to_sym] = node.attributes[key].value
          end
        end
        if node.children.size > 0
          node.children.each do |child|
            result = xml_node_to_hash(child)

            if child.name == "text"
              unless child.next_sibling || child.previous_sibling
                return result unless attributes
                result_hash[child.name.underscore.to_sym] = result
              end
            elsif result_hash[child.name.underscore.to_sym]

              if result_hash[child.name.underscore.to_sym].is_a?(Object::Array)
                 result_hash[child.name.underscore.to_sym] << result
              else
                 result_hash[child.name.underscore.to_sym] = [result_hash[child.name.underscore.to_sym]] << result
              end
            else
              result_hash[child.name.underscore.to_sym] = result
            end
          end
          if attributes
             #add code to remove non-data attributes e.g. xml schema, namespace here
             #if there is a collision then node content supersets attributes
             result_hash = attributes.merge(result_hash)
          end
          return result_hash
        else
          return attributes
        end
      else
        return node.content.to_s
      end
    end
  end
end