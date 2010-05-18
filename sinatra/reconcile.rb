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
# "upload1"=>{:type=>"text/plain", :tempfile=>#<File:/var/folders/wq/wqTzo7SOHx4V9VsmKFOn5k+++TM/-Tmp-/RackMultipart20100518-8810-1l0kb7l-0>, :head=>"Content-Disposition: form-data; name=\"upload1\"; filename=\"text_bad.txt\"\r\nContent-Type: text/plain\r\n", :name=>"upload1", :filename=>"text_bad.txt"},

  # file_field = @params['form']['file'] rescue nil
  # file_field is a StringIO object
  # file_field = params["upload1"][:tempfile] rescue nil
  # puts file_field.path # 'text/csv'
  # puts file_field.full_original_filename
  # get_file(params['upload1'])
  # get_file(params['upload2'])
  # {"url1"=>"http://localhost/text_bad.txt", "url2"=>"", "url_e"=>"Nlist2.txt", "freetext1"=>"", "freetext2"=>"", "upload1"=>"", "upload2"=>"", "func"=>"submit"}
  # key = url1, value = http://localhost/text_bad.txt
  # key = url2, value = 
  # key = url_e, value = Nlist2.txt
  # key = freetext1, value = 
  # key = freetext2, value = 
  # key = upload1, value = 
  # key = upload2, value = 
  # key = func, value = submit
  # unless (params['upload1'].empty?)
    # save(params['upload1'])
  # end
  unless (params['upload1'].empty?)
    time_tmp = Time.now.to_f.to_s   
    filename = File.join("tmp/", time_tmp+params[:upload1][:filename])
    f = File.open(filename, 'wb') 
      f.write(params['upload1'][:tempfile].read)
    # end
    f.close
    @url1 = "http://localhost/sinatra/"+filename
    puts @url1
  end
  unless (params['upload2'].empty?)
    time_tmp = Time.now.to_f.to_s   
    filename = File.join("tmp/", time_tmp+params[:upload2][:filename])
    f = File.open(filename, 'wb') 
      f.write(params['upload2'][:tempfile].read)
    # end
    f.close
    @url2 = "http://localhost/sinatra/"+filename
    puts @url2
  end
  # unless (params['upload2'].empty?)
  #   time_tmp = Time.now.to_f.to_s   
  #   filename = File.join("tmp/", time_tmp+params[:upload2][:filename])
  #   f = File.open(filename, 'wb') do |file|
  #     file.write(params['upload1'][:tempfile].read)
  #   end
  #   f.close
  #   @url2 = filename
  # end
  # params.each do |key, value|
  #   unless (value.nil?) #value.empty? || 
  #     instance_variable_set("@#{key}", value)
  #   end
  #   unless (params['upload1'].empty?)
  #     key = "url1"
  #     value = params['upload1'][:tempfile].path
  #     instance_variable_set("@#{key}", value)
  #   end
  #   unless (params['upload2'].empty?)
  #     key = "url2"
  #     value = params['upload2'][:tempfile].path
  #     instance_variable_set("@#{key}", value)
  #   end
  #   print "@url1 = %s, value = %s\t@url2 = %s\n" % [@url1, value, @url2]
  # end
  # if (params["url1"] && params["url2"])
  #   content = "url";
  #   url1 = params["url1"]
  #   url2 = params["url2"]
  # end
  if (@url1 && @url2)
    result = RestClient.get "http://localhost:4567/match?url1=#{@url1}&url2=#{@url2}"
  end
  # if (@upload1 && @upload2)
  #   result = RestClient.get "http://localhost:4567/match?url1=#{@upload1}&url2=#{@upload2}"
  # end


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

def get_file(picture_field)
  # {"url1"=>"", "url2"=>"", "url_e"=>"none", "freetext1"=>"", "freetext2"=>"", "upload1"=>{:type=>"text/plain", :tempfile=>#<File:/var/folders/wq/wqTzo7SOHx4V9VsmKFOn5k+++TM/-Tmp-/RackMultipart20100518-8810-1l0kb7l-0>, :head=>"Content-Disposition: form-data; name=\"upload1\"; filename=\"text_bad.txt\"\r\nContent-Type: text/plain\r\n", :name=>"upload1", :filename=>"text_bad.txt"}, "upload2"=>{:type=>"text/plain", :tempfile=>#<File:/var/folders/wq/wqTzo7SOHx4V9VsmKFOn5k+++TM/-Tmp-/RackMultipart20100518-8810-92cm9n-0>, :head=>"Content-Disposition: form-data; name=\"upload2\"; filename=\"text_good.txt\"\r\nContent-Type: text/plain\r\n", :name=>"upload2", :filename=>"text_good.txt"}}
  
  @name = picture_field.respond_to?(:original_filename) ? base_part_of(picture_field.original_filename) : nil
  @content_type = picture_field.respond_to?(:content_type) ? picture_field.content_type.chomp : nil
  @data = picture_field.respond_to?(:read) ? picture_field.read : picture_field.to_s
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
