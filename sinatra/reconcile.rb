#!/opt/local/bin/ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'rest_client'

layout 'layout'

### Public

get '/' do
  erb :index
end

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
    # print "filename = %s\n" % filename
    # print "url = %s\n" % url
    return url
end
