# RESTful representation of any problem

# bad (passing album id and capturing the value as params, we don't want the user to choose an album to save the song)

class Album < ActiveRecord::Base
  has_many :songs
end

class Song < ActiveRecord::Base
  belongs_to :album
end

<h2> <%= @album.title %> </h2>
<p> By: <%= @album.artist %> </p>
<ul>
  <% @album.songs.each do |song| %>
    <li><%= link_to song.title, song %></li>
  <% end %>
</ul>
<%= link_to "Add song", new_song_url(:album_id => @album.id) %>>

class SongsController < ApplicationController
  def new
    @song = Song.new(:album_id => params[:album_id]) # bad thing having the album id to create the song

<%= form_for(@song) do |f| %>
<%= f.hidden_field :album_id %>>

# While this works, it’s not ideal. Passing the parent ID around like a hot potato is a definite code smell

# good (Make Use of Nested Resources)

MyApp::Application.routes.draw do
  resources :albums do
    resources :songs
  end
end

$ rake routes | grep song
...
                  GET  /albums/:album_id/songs(.:format)  
  album_songs     POST /albums/:album_id/songs(.:format)  
  new_album_song  GET /albums/:album_id/songs/new(.:format)
                  GET /albums/:album_id/songs/:id(.:format)
                  PUT /albums/:album_id/songs/:id(.:format)  
  album_song      DELETE /albums/:album_id/songs/:id(.:format) 
  edit_album_song GET /albums/:album_id/songs/:id/edit(.:format)
...

class SongsController < ApplicationController
  before_filter :grab_album_from_album_id
  
  def index
    @songs = @album.songs.all
  end
  
  def show
    @song = @album.songs.find(params[:id])
  end
  
  def new
    @song = @album.songs.new
  end
  
  def edit
    @song = @album.songs.find(params[:id])
  end
  
  def create
    @song = @album.songs.new(params[:song])
      if @song.save
        redirect_to([@album, @song], :notice => 'Song was successfully created.')
      else
        render :action => "new"
      end
  end
  
  def update
    @song = @album.songs.find(params[:id])
    
    if @song.update_attributes(params[:song])
      redirect_to([@album, @song], :notice => 'Song was successfully updated.')
    else
      render :action => "edit"
    end
  end
  
  def destroy
    Song.find(params[:id]).destroy
    redirect_to(album_songs_url(@album))
  end
  
  private
  
  def grab_album_from_album_id
    @album = Album.find(params[:album_id])
  end
end

<%= form_for([@album, @song]) do |f| %>
...
<% end %>>

<h1>Editing song</h1>
<%= render 'form' %>
<%= link_to 'Show', [@album, @song] %> |
<%= link_to 'Back', @album %>