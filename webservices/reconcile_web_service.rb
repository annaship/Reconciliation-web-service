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

get '/match' do
  # @@client = TaxonFinderClient.new 'localhost' 
  # @@client = NetiTaxonFinderClient.new 'localhost' 
  @@client = ReconicliationClient.new 'localhost' 
  format = @@valid_formats.include?(params[:format]) ? params[:format] : "xml"

  begin
    content1 = params[:text1] || params[:url1] || params[:encodedtext1] || params[:encodedurl1]
    content2 = params[:text2] || params[:url2] || params[:encodedtext2] || params[:encodedurl2]
  rescue
    status 400
  end
  
  content1 = URI.unescape content1
  content2 = URI.unescape content2
  # decode if it's encoded
  content1 = Base64::decode64 content1 if params[:encodedtext] || params[:encodedurl]
  content2 = Base64::decode64 content2 if params[:encodedtext] || params[:encodedurl]
  
  # scrape if it's a url
  if params[:encodedurl1] || params[:url1]
    begin
      response1  = open(content1)
      pure_text1 = open(content1).read
    rescue
      status 400
    end
    content1 = pure_text1 if pure_text1
    # use nokogiri only for HTML, because otherwise it stops on OCR errors
    # content = Nokogiri::HTML(response).content if pure_text.include?("<html>")    
    content1 = Nokogiri::HTML(response1).content1 if (pure_text1 && pure_text1.include?("<html>"))    
  end

  if params[:encodedurl2] || params[:url2]
    begin
      response2  = open(content2)
      pure_text2 = open(content2).read
    rescue
      status 400
    end
    content2 = pure_text2 if pure_text2
    # use nokogiri only for HTML, because otherwise it stops on OCR errors
    # content = Nokogiri::HTML(response).content if pure_text.include?("<html>")    
    content2 = Nokogiri::HTML(response2).content2 if (pure_text2 && pure_text2.include?("<html>"))    
  end

  content = content1 + "&&&EOF&&&" + content2     
  
  names = @@client.match(content)

  if format == 'json'
    content_type 'application/json', :charset => 'utf-8'
    return Hash.from_xml("#{to_xml(names)}").to_json
  end
  
  # content_type 'text/xml', :charset => 'utf-8'
  # to_xml(names)
  content_type 'text/HTML', :charset => 'utf-8'
  "<html><head></head><body>"+names+"</body></html>"
end
