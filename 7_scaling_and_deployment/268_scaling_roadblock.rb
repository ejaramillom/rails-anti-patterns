# bad (store images in local server

has_attached_file :image, :styles => { :medium :thumb => "290x290>", => "64x64#" }

# good (send images to cloud servers)

has_attached_file :image, 
                  :styles => { :medium => "290x290>", :thumb => "64x64#" },
                  :storage => :s3,
                  :s3_credentials => "#{Rails.root}/config/s3.yml",
                  :path => ":class/:id/:style/:basename.:extension",
                  :bucket => "post-attachment-images-#{Rails.env}"