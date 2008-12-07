require 'rubygems'
require 'sequel'
require 'logger'
require 'json'
require 'sinatra'

configure :development, :production do
  DB = Sequel.connect "sqlite://db/#{Sinatra.env}.db"
  DB.logger = Logger.new(STDOUT, 0)
end

configure :test do
  DB = Sequel.sqlite
end

error do
  e = request.env['sinatra.error']
  puts e.to_s
  puts e.backtrace.join("\n")
  "Application error"
end

Dir['lib/*.rb'].each {|file| require file}

get '/import' do
  erb :import
end

post '/import' do
  @inserted_count = Transaction.import_data(params[:account_history])
  erb :added
end

get '/graph' do
  @dates = Transaction.select(:reported_on).uniq.map{|t| t.reported_on.strftime("%Y-%m") }.uniq
  erb :graph
end

get '/graph.json' do
  graph = Graph.new(*params[:date].split("-"))
  graph.to_json
end

post '/tag_from_pos' do
  graph = Graph.new(*params[:date].split("-"))
  x, y = params[:x].to_f / 2.0, params[:y].to_f
  graph.tag_from_pos(x, y)
end

post '/transactions' do
  graph = Graph.new(*params[:date].split("-"))
  @transactions = graph.transactions(params[:tag])
  erb :transactions, :layout => false
end

get '/data' do
  @current_page = (params[:page] && params[:page].to_i)  || 1
  @transactions = Transaction.order(:reported_on, :id).paginate(@current_page, Transaction::page_size)
  erb :data
end

post '/tags' do
  @current_tag = Transaction[params[:id]].tag
  @tags = Transaction.tags
  erb :tags, :layout => false
end

put '/transactions/:id' do
  Transaction[params[:id]].update(:tag => params[:tag])
  params[:tag]
end
