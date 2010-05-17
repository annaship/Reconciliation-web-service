#!/opt/local/bin/ruby

require 'rubygems'
require 'sinatra'
require 'haml'

layout 'layout'

### Public

get '/' do
  erb :form
end

post '/submit' do
  puts params.inspect.to_s
  # {"url1"=>"http://localhost/text_bad.txt", "url2"=>"http://localhost/text_good.txt", "freetext1"=>"", "freetext2"=>"", "upload1"=>"", "upload2"=>"", "func"=>"submit"}
  
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
