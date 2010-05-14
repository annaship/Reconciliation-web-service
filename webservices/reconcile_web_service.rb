require 'rubygems'
require 'sinatra'
require File.dirname(__FILE__) + '/lib/recon_client'
# require File.dirname(__FILE__) + '/lib/neti_taxon_finder_client'
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'base64'
require 'builder'
require 'active_support'
require 'ruby-debug'

set :show_exceptions, false

# Array of allowed formats
@@valid_formats = %w[xml json]
@@valid_types = %w[text url encodedtext encodedurl]

#show user an info page if they hit the index
get '/' do
  "Taxon Name Finding API, documentation at http://code.google.com/p/taxon-name-processing"
end

def print_bytes(thestring)
  thestring.each_byte do |c|
      print "%s = %d\n" % [c.chr, c]
  end
end
  

get '/match' do
  # @@client = TaxonFinderClient.new 'localhost' 
  # @@client = NetiTaxonFinderClient.new 'localhost' 
  @@client = ReconicliationClient.new 'localhost' 
  puts "=" * 80
  # print "params = %s" % params.inspect
  # params = {"url1"=>"http://localhost/text_good.txt", "url2"=>"http://localhost/text_bad.txt"}

  format = @@valid_formats.include?(params[:format]) ? params[:format] : "xml"
  # puts format
  begin
    content1 = params[:text1] || params[:url1] || params[:encodedtext1] || params[:encodedurl1]
    content2 = params[:text2] || params[:url2] || params[:encodedtext2] || params[:encodedurl2]
    # print "1) content1 = %s, content2 = %s\n" % [content1.inspect, content2.inspect]
  rescue
    status 400
  end
  
  # print "2) content1 = %s, content2 = %s\n" % [content1.inspect, content2.inspect]
  # print "1: "
  # print_bytes(params[:text1])
  # print "2: "
  # print_bytes(content1)
  content1 = URI.unescape content1
  # print "3: "

  # print_bytes(content1)
  content2 = URI.unescape content2
  # print "3) content1 = %s, content2 = %s\n" % [content1.inspect, content2.inspect]
  # decode if it's encoded
  content1 = Base64::decode64 content1 if params[:encodedtext] || params[:encodedurl]
  content2 = Base64::decode64 content2 if params[:encodedtext] || params[:encodedurl]
  # print "4) content1 = %s, content2 = %s\n" % [content1.inspect, content2.inspect]
  # scrape if it's a url
  if params[:encodedurl1] || params[:url1]
    begin
      response1 = open(content1)
      pure_text1 = open(content1).read
    rescue
      status 400
    end
    content1 = pure_text1 if pure_text1
    # print "5) content1 = %s, content2 = %s\n" % [content1.inspect, content2.inspect]
    # use nokogiri only for HTML, because otherwise it stops on OCR errors
    # content = Nokogiri::HTML(response).content if pure_text.include?("<html>")    
    content1 = Nokogiri::HTML(response1).content1 if (pure_text1 && pure_text1.include?("<html>"))    
  end

  if params[:encodedurl2] || params[:url2]
    begin
      response2 = open(content2)
      pure_text2 = open(content2).read
    rescue
      status 400
    end
    content2 = pure_text2 if pure_text2
    # print "5) content1 = %s, content2 = %s\n" % [content1.inspect, content2.inspect]
    # use nokogiri only for HTML, because otherwise it stops on OCR errors
    # content = Nokogiri::HTML(response).content if pure_text.include?("<html>")    
    content2 = Nokogiri::HTML(response2).content2 if (pure_text2 && pure_text2.include?("<html>"))    
  end

  # print "content1 = %s, content2 = %s\n" % [content1.inspect, content2.inspect]
  
  # print "6) content1 = %s, content2 = %s\n" % [content1.inspect, content2.inspect]
  content = content1 + "&&&EOF&&&" + content2     
  
  # content1.each_byte do |c|
  #     print "%s = %d\n" % [c.chr, c]
  # end
 
  
  # names1 = @@client.match(content1)
  # names2 = @@client.match(content2)
  # print "names1 = %s, names2 = %s\n" % [names1.inspect, names2.inspect]
  names = @@client.match(content)
  # 
  if format == 'json'
    content_type 'application/json', :charset => 'utf-8'
    return Hash.from_xml("#{to_xml(names)}").to_json
  end
  
  # content_type 'text/xml', :charset => 'utf-8'
  # to_xml(names)
  content_type 'text/HTML', :charset => 'utf-8'
  "<html><head></head><body>"+names+"</body>"
end

def to_xml(names)
  xml = Builder::XmlMarkup.new
  xml.instruct!
  xml.response do
    xml.names("xmlns:dwc" => "http://rs.tdwg.org/dwc/terms/") do
      names.each do |name|
        xml.name do
          xml.verbatim name.verbatim
          xml.dwc(:scientificName, name.scientific)
          xml.offsets do
            xml.offset(:start => name.start_pos, :end => name.end_pos)
          end
        end
      end    
    end
  end
end
