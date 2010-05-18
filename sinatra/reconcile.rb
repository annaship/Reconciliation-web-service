#!/opt/local/bin/ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'rest_client'


layout 'layout'

### Public
@taxon_finder_web_service_url = "http://localhost:4567"; 

get '/' do
  erb :form
end

post '/submit' do
  puts "=" * 80
  if (params["url1"] && params["url2"])
    content = "url";
    url1 = params["url1"]
    url2 = params["url2"]
  end
  result = RestClient.get "http://localhost:4567/match?url1=#{url1}&url2=#{url2}"
  possible_names = result.split("\n");
	@arr = []
	possible_names.each do |names|
	  name_bad, name_good = names.split(" ---> ")
    # print "name_bad = %s\n" % name_bad
    # print "name_good = %s\n" % name_good
    @arr << {name_bad, name_good} 
  end
  # print "@arr = %s\n" % @arr.inspect.to_s
  # {"url1"=>"http://localhost/text_bad.txt", "url2"=>"http://localhost/text_good.txt", "freetext1"=>"", "freetext2"=>"", "upload1"=>"", "upload2"=>"", "func"=>"submit"}
  # erb(:result, :locals => possible_names)
  erb :result
end


# get '/recon' do
#   haml :recon
# end
# 
# post '/recon' do
#   @files   = params[:file]
#   @results = "results defined"
# 
#   haml :recon_result
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

# __END__
# @@ layout
# %html
#   %head
#     %title Scientific Names Tools
#   %body
#     #header
#       %h1 Scientific Names Tools
#     #content
#       =yield
#   %footer
#     %a(href='/') Back to index
# 
# @@ index
# %p
#   Welcome to Scientific Names Tools.  Below is a list
#   of the tools available.
# %ul
#   %li
#     %h3
#       %a(href='/neti_tf') Neti Neti Taxon Finder
#   %li
#     %h3
#       %a(href='/recon') Scientific Names Reconciliation
#       
# @@ recon
# %h1 Upload
# %form{:action=>"/recon", :method=>"post", :enctype=>"multipart/form-data"}
#   %input{:type=>"file",   :name=>"file"}
#   %input{:type=>"submit", :value=>"Upload"}'
# - if defined?(@results)
#   %pre= @results
#   
# @@ recon_result
# %p Ura!
