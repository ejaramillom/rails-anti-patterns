# bad (manage parsing from external APIs)

<html>
  <body>
  <p>Welcome to the Awesome Hosting Company, Inc. website.</p>
    <div class="sidebar">
      All systems are currently
      <span class="status">
        <imgsrc="/images/normal.png">normal
      </span>
    </div>
  </body>
</html>

require 'uri'
require 'open-uri'
        
url = 'http://theurlofthewebpage.com'
html = open(url).read
        
if html =~ /class="status"><img
  src="\/images\/.*\.png">(.*)<\/span/
  status = $1
end

# better (use a tool to understand data response)

require 'rubygems'
require 'nokogiri'
require 'open-uri'
  
url = 'http://theurlofthewebpage.com'
doc = Nokogiri::HTML(open(url))
status = doc.css('.status').first.content