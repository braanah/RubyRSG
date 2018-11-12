require 'sinatra'
require 'slim'
require './rsg'

configure do
  mime_type :css, 'text/css'
end

get '/' do
  slim :main
end

# get('/styles.css') { scss :styles }
#

grammars = ["Bionic-Woman-episode", "Bond-movie", "Civ-paper", "CS-assignment-handout","CS-nightmare","Dear-John-letter","Extension-request","Friday-13th-movie","Haiku","How-they-met-story","Kant","Math-expression","Poem","Programming-bug","Wired-sound-bite","Microsoft-press-release"]

get '/:grammar' do
  @grammar = params[:grammar]
  if grammars.include?(params[:grammar])
    # @grammar = params[:grammar]
    @sentence = rsg(@grammar)
    slim :main
  else
    slim :not_found
  end

end

# not_found do
#   status 404
#   slim :not_found
# end
__END__
