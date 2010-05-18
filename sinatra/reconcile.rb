#!/opt/local/bin/ruby

require 'rubygems'
require 'sinatra'
require 'haml'
require 'rest_client'


layout 'layout'

### Public
@taxon_finder_web_service_url = "http://localhost:4567"; 

get '/' do
  @mfile_names = []
  @mfile_names = build_master_lists
  # @mfile_names = [1,2,3]
  # print "Here we are, @mfile_names = %s" % @mfile_names.inspect.to_s
  erb :form
end

post '/submit' do
  puts "=" * 80
  # puts params.inspect.to_s
  # {"url1"=>"http://localhost/text_bad.txt", "url2"=>"", "url_e"=>"Nlist2.txt", "freetext1"=>"", "freetext2"=>"", "upload1"=>"", "upload2"=>"", "func"=>"submit"}
  # key = url1, value = http://localhost/text_bad.txt
  # key = url2, value = 
  # key = url_e, value = Nlist2.txt
  # key = freetext1, value = 
  # key = freetext2, value = 
  # key = upload1, value = 
  # key = upload2, value = 
  # key = func, value = submit
  
  params.each do |key, value|
    unless value.empty?
      instance_variable_set("@#{key}", value)
    end
  end
  # if (params["url1"] && params["url2"])
  #   content = "url";
  #   url1 = params["url1"]
  #   url2 = params["url2"]
  # end
  if (@url1 && @url2)
    result = RestClient.get "http://localhost:4567/match?url1=#{@url1}&url2=#{@url2}"
  end


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

def build_master_lists
  mfile_names = []
  dir_listing = `ls ../webservices/texts/master_lists/*`
  dir_listing.each do |mfile_name| 
    mfile_names << File.basename(mfile_name)
  end
  return mfile_names
end

# # My 'helpers'
# helpers do
# # Build the HTML code from an array of option for 'SELECT'.
#   def html_select(array)
#     option=Array.new()
#     array.each {|opt| option << "<OPTION>#{opt}</OPTION>"}
#     option
#   end
#   # The list of choices.
#   def select_options
#     @start_choice = html_select([ 1, 2, 3, 4])
#     @where_choice = html_select(%w[Here There Nowhere Somewhere])
#     @type_choice = html_select(%w[A B C D E F G])
#     # If nothing is displayed like : "", the last thing, here :
#     # '@type_choice', is displayed.
#     ""
#   end
# end

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
