#!/opt/local/bin/ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'rest_client'
require File.dirname(__FILE__) + '/../webservices/lib/neti_taxon_finder_client1'
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'base64'
require 'builder'
require 'active_support'
require 'ruby-debug'

layout 'layout'

### Public

get '/' do
  # puts "Hello there!"
  erb :index
end

get '/neti_tf' do
  erb :tf_form
end

# post '/tf_result' do
#   puts "=" * 80
#   puts params.inspect
# 
#   unless (params['upload'].nil?)
#     upload = params['upload']
#     @url = upload_file(upload)
#   end
# 
#   params.each do |key, value|
#     unless key.start_with?('upload')
#       unless value.empty?
#         # @url = "http://localhost/sinatra/master_lists/"+params['url_e'] unless (key == "url_e" && value == "none")
#         instance_variable_set("@#{key}", value)
#       end
#     end
#   end
#   
#   if @url
#     
#     result = RestClient.get URI.encode("http://localhost:4567/find?url=http://localhost/text_good.txt")
#     # result = RestClient.get URI.encode("http://localhost:4567/find?url=#{@url}")
#   elsif @freetext
#     result = RestClient.get URI.encode("http://localhost:4567/find?text=#{@freetext}")
#   # elsif (@freetext && @url2)
#   #   result = RestClient.get URI.encode("http://localhost:4567/find?text=#{@freetext}{@url2}")
#   end
#   possible_names = []
#   result.each do |name|
#     puts name.from_xml
#     
#   end
#   
#   @tf_arr = [1, 2]
#   # //parse the xml response and move it to an array
#   #     $possible_names = array();
#   #     foreach ($xml->names->name as $name) 
#   #     {
#   #       $namespaces = $name->getNameSpaces(true);
#   #       $dwc = $name->children($namespaces['dwc']);
#   #       $verbatim = (string)$name->verbatim;
#   #       $scientific = (string)$dwc->scientificName;
#   #       $possible_names[$verbatim] = $scientific;
#   #     }
#   
#   
#   # print "@tf_arr = %s\n" % @tf_arr.inspect 
#   # @tf_arr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><names xmlns:dwc=\"http://rs.tdwg.org/dwc/terms/\"><name><verbatim>Abra</verbatim><dwc:scientificName>Abra</dwc:scientificName><offsets><offset start=\"0\" end=\"3\"/></offsets></name><name><verbatim>Abra abra</verbatim><dwc:scientificName>Abra abra</dwc:scientificName><offsets><offset start=\"4\" end=\"12\"/></offsets></name><name><verbatim>Abra aequalis</verbatim><dwc:scientificName>Abra aequalis</dwc:scientificName><offsets><offset start=\"13\" end=\"25\"/></offsets></name><name><verbatim>Abra affinis</verbatim><dwc:scientificName>Abra affinis</dwc:scientificName><offsets><offset start=\"26\" end=\"37\"/></offsets></name><name><verbatim>Atys sandersoni</verbatim><dwc:scientificName>Atys sandersoni</dwc:scientificName><offsets><offset start=\"38\" end=\"52\"/></offsets></name></names></response>"
#   
#   erb :tf_result
# end
# -------------

post '/find' do
  puts "Ura, here"
end

# Array of allowed formats
@@valid_formats = %w[xml json]
@@valid_types = %w[text url encodedtext encodedurl]


 get '/find' do
  puts "-" * 80
  puts params.inspect
  # {"upload"=>"", "text"=>"", "url"=>"http://localhost/text_good11.txt"}
  
  @@client = NetiTaxonFinderClient.new 'localhost' 
  format = @@valid_formats.include?(params[:format]) ? params[:format] : "xml"
  begin
    print "params[url] = %s\n" % params["url"]
    print "params[:url] = %s\n" % params[:url]
    content = params[:text] || params[:url] || params[:encodedtext] || params[:encodedurl]
    content = params[:url]
    
    print "content1 = %s\n" % content
  rescue
    status 400
  end
  content = URI.unescape content
  print "content2 = %s\n" % content
  # decode if it's encoded
  content = Base64::decode64 content if params[:encodedtext] || params[:encodedurl]
  print "content3 = %s\n" % content
  # scrape if it's a url
  if params[:encodedurl] || params[:url]
    begin
      response = open(content)
      print "response = %s\n" % response
      pure_text = open(content).read
      print "pure_text = %s\n" % pure_text
    rescue
      status 400
    end
    content = pure_text if pure_text
    print "content4 = %s\n" % content
    # use nokogiri only for HTML, because otherwise it stops on OCR errors
    # content = Nokogiri::HTML(response).content if pure_text.include?("<html>")    
    content = Nokogiri::HTML(response).content if (pure_text && pure_text.include?("<html>"))    
    print "content5 = %s\n" % content
  end
  names = @@client.find(content)
  print "names = "+names.inspect.to_s
  @tf_arr = names

  if format == 'json'
    content_type 'application/json', :charset => 'utf-8'
    return Hash.from_xml("#{to_xml(names)}").to_json
  end
  content_type 'text/xml', :charset => 'utf-8'
  to_xml(names)

  erb :tf_result
  puts "-" * 80
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


# -------------
# reconciliation
get '/recon' do
  @mfile_names = []
  @mfile_names = build_master_lists
  erb :form
end

post '/submit' do
  # puts "=" * 80
  # puts params.inspect.to_s
  unless (params['upload1'].nil?)
    upload = params['upload1']
    @url1 = upload_file(upload)
  end
  unless (params['upload2'].nil?)
    upload = params['upload2']
    @url2 = upload_file(upload)
  end
  
  params.each do |key, value|
    unless key.start_with?('upload')
      unless value.empty?
        @url2 = "http://localhost/sinatra/master_lists/"+params['url_e'] unless (key == "url_e" && value == "none")
        instance_variable_set("@#{key}", value)
      end
    end
  end

  if (@url1 && @url2)
    result = RestClient.get URI.encode("http://localhost:3000/match?url1=#{@url1}&url2=#{@url2}")
  elsif (@freetext1 && @freetext2)
    result = RestClient.get URI.encode("http://localhost:3000/match?text1=#{@freetext1}&text2=#{@freetext2}")
  elsif (@freetext1 && @url2)
    result = RestClient.get URI.encode("http://localhost:3000/match?text1=#{@freetext1}&url2=#{@url2}")
  end
  possible_names = result.split("\n");
	@arr = []
	possible_names.each do |names|
	  name_bad, name_good = names.split(" ---> ")
    @arr << {name_bad, name_good} 
  end
  
  # # clean up tmp if exist
  # `rm #{File.dirname(__FILE__)}/tmp/*`
  erb :result
end

def build_master_lists
  mfile_names = []
  dir_listing = `ls #{File.dirname(__FILE__)}/../webservices/texts/master_lists/*`
  dir_listing.each do |mfile_name| 
    mfile_names << File.basename(mfile_name)
  end
  return mfile_names
end

def upload_file(upload)
    time_tmp = Time.now.to_f.to_s   
    filename = File.join("#{File.dirname(__FILE__)}/tmp/", time_tmp+upload[:filename])
    f = File.open(filename, 'wb') 
    f.write(upload[:tempfile].read)
    f.close
    url = "http://localhost/sinatra/"+filename
    return url
end
