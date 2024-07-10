# bad (store images in local server )

has_attached_file :image, :styles => { :medium :thumb => "290x290>", => "64x64#" }

# good (send images to cloud servers)

has_attached_file :image, 
                  :styles => { :medium => "290x290>", :thumb => "64x64#" },
                  :storage => :s3,
                  :s3_credentials => "#{Rails.root}/config/s3.yml",
                  :path => ":class/:id/:style/:basename.:extension",
                  :bucket => "post-attachment-images-#{Rails.env}"

#  Maximum occupancy 

# Most Linux-based filesystems have a limit of 32,000 files within each directory. With the Paperclip path definition in the preceding section (and the default, which is ":rails_root/public/:attachment/:id/:style/:basename.:extension"), you will run into this limit when you hit 32,000 attachments. This number may seem like far far away, but when you hit that limit, moving around and migrating 32,000 images won’t be fun.

# Fortunately, Paperclip has a built-in configuration option for dealing with this problem. Paperclip provides a path interpolation of :id_partition. This option changes where Paperclip stores the uploaded files; instead of storing all attachments in one directory, it splits up the id into a directory structure, ensuring that there are a limited number of files within each directory. For example, instead of storing the attachments for the post with id 1003 in /public/images/1003, it will store the attachments in /public/images/1/0/0/3.

# Head in the clouds 

# Some scaling features are clearly not worth worrying about early on, and some should be added to each application from the beginning.

# Take dataset sharding, as an example. Sharding is the concept of breaking certain datasets into different sections and hosting each section on its own server to decrease the size of each server’s dataset and load. The engineering effort needed to implement sharding from the start is far too high to justify in most cases. In addition, few real-world applications actually ever need to shard, no matter how much they must scale. 

# It’s simply not the right answer for every scaling problem, and therefore it’s not something a responsible developer would add from the start.

# Slice and dice

# Cloud deployment is easier today than ever before. With services such as Engine Yard (http://engineyard.com), Heroku (http://heroku.com), and Google App Engine (http://code.google.com/appengine/), you no longer need to maintain your own cluster configurations or keep track of and manage your own instances and provisioning and deployment involves one click (or command). In addition, the costs for an actual cluster in the cloud are comparable with what you might pay for a typical single server in a data center.

# Yes, you can deploy to just one instance or server, but by deploying your applications to a clustered environment from the start, even if you only use one server there, you are sure to maintain ultimate flexibility in scalability and deployment. And the amount of effort and cost will be similar to what you’d spend on a more traditional server infrastructure.