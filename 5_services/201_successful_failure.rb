# Parsing the response to determine failure is less than ideal because it is more work and is potentially more error prone than if the client could essentially just check a flag to see if the response was successful.

# In a truly RESTful API, clients would never have to rely on parsing the response body to determine success or failure. HTTP, upon which the REST concept is based, provides a built-in mechanism for this, one that essentially provides that flag for the client to check: HTTP status codes.

# bad (return errors as XML, use HTTP codes)

def create
  @song = songs.new(params[:song])
  
  respond_to do |format|
    if @song.save
      format.xml { render :xml => @song, :location => @song }
    else
      format.xml { render :xml => @song.errors }
    end
  end
end

# better (use HTTP status codes)

def create
  @song = songs.new(params[:song])
  
  respond_to do |format|
    if @song.save
      format.xml { render :xml => @song, :status => :created, :location => @song }
    else
      format.xml { render :xml => @song.errors, :status => :unprocessable_entity }
    end
  end
end
