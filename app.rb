require 'sinatra'
require './tfl'

get '/' do
  @line_statuses = Tfl.new.fetch

  haml :index, format: :html5
end
