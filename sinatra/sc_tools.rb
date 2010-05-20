#!/opt/local/bin/ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require "#{File.dirname(__FILE__)}/reconcile"

# require 'whois'

layout 'layout'

### Public

get '/' do
  erb :index
end

# # whois
# get '/recon' do
#   erb :form
# end

# post '/recon' do
#   @files   = params[:file]
#   @results = "results defined"
# 
#   haml :recon_result
# end

# get '/recon' do
#   @mfile_names = []
#   @mfile_names = build_master_lists
#   erb :form
# end
# 
# post '/submit' do
#   
#   # puts "=" * 80
#   # puts params.inspect.to_s
#   unless (params['upload1'].nil?)
#     upload = params['upload1']
#     @url1 = upload_file(upload)
#   end
#   unless (params['upload2'].nil?)
#     upload = params['upload2']
#     @url2 = upload_file(upload)
#   end
#   
#   params.each do |key, value|
#     unless key.start_with?('upload')
#       unless value.empty?
#         @url2 = "http://localhost/sinatra/master_lists/"+params['url_e'] unless (key == "url_e" && value == "none")
#         instance_variable_set("@#{key}", value)
#       end
#     end
#   end
# 
#   if (@url1 && @url2)
#     result = RestClient.get URI.encode("http://localhost:3000/match?url1=#{@url1}&url2=#{@url2}")
#   elsif (@freetext1 && @freetext2)
#     result = RestClient.get URI.encode("http://localhost:3000/match?text1=#{@freetext1}&text2=#{@freetext2}")
#   elsif (@freetext1 && @url2)
#     result = RestClient.get URI.encode("http://localhost:3000/match?text1=#{@freetext1}&url2=#{@url2}")
#   end
#   possible_names = result.split("\n");
#   @arr = []
#   possible_names.each do |names|
#     name_bad, name_good = names.split(" ---> ")
#     @arr << {name_bad, name_good} 
#   end
#   erb :result
# end


# # traceroute
# get '/traceroute' do
#   haml :traceroute
# end
# 
# post '/traceroute' do
#   @host = params[:host]
# 
#   # For security reasons, remove all quote
#   # characters from the hostname
#   @host.gsub!(/"/,'')
#   
#   @results = `traceroute "#{@host}"`
# 
#   haml :traceroute
# end
