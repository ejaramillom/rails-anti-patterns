# bad

class SongsController < ApplicationController
  before_filter :grab_album_from_album_id
  
  def index
    @songs = songs.all
      
    respond_to do |format|
      format.html
      format.xml { render :xml => @songs }
    end
  end

  def show
    @song = songs.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @song }
    end
  end
  
  def new
    @song = songs.new
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @song }
    end
  end
  
  def edit
    @song = songs.find(params[:id])
  end

  def create
    @song = songs.new(params[:song])
    
    respond_to do |format|
      if @song.save
        format.html do
          redirect_to(@song, :notice => 'Song was successfully created.')
        end
        format.xml do
          render :xml => @song, :status => :created, :location => @song
        end
      else
        format.html { render :action => "new" }
        format.xml do
          render :xml => @song.errors, :status => :unprocessable_entity
        end
      end
    end
  end
  # ...
end

# good (use responders until rails 5)

class SongsController < ApplicationController
  respond_to :html, :xml
  before_filter :grab_album_from_album_id
  
  def index
    @songs = songs.all
    respond_with(@songs)
  end
  
  def show
    @song = songs.find(params[:id])
    respond_with(@song)
  end
  
  def new
    @song = songs.new
    respond_with(@song)
  end
  
  def edit
    @song = songs.find(params[:id])
    respond_with(@song)
  end
  
  def create
    @song = songs.new(params[:song])
    
    if @song.save
      flash[:notice] = 'Song was successfully created.'
    end
    
    respond_with(@song)
  end
  
  def update
    @song = songs.find(params[:id])
    
    if @song.update_attributes(params[:song])
      flash[:notice] = 'Song was successfully updated.'
    end
    
    respond_with(@song)
  end
  
  def destroy
    @song = Song.find(params[:id])
    @song.destroy
    
    respond_with(@song)
  end
  
  private
  
  def songs
    @album ? @album.songs : Song
  end
  
  def grab_album_from_album_id
    @album = Album.find(params[:album_id]) if params[:album_id]
  end
end

# better (explicit rendering)

class SongsController < ApplicationController
  def new
    @song = Song.new
    
    render :new
  end

  def create
    @song = Song.new(song_params)
    
    if @song.save
      redirect_to @song, notice: 'Song was successfully created.'
    else
      render :new
    end
  end

  private

  def song_params
    params.require(:song).permit(:title, :artist, :album)
  end
end
