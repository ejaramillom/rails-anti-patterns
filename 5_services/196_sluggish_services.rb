# bad (default timeouts in requests)

# A big concern in interacting with remote services is how they might affect application performance. If a network connection is slow or has issues, or even if the remote service itself is slow or is currently having issues, the performance of an application may be severely affected.

# better (set timeouts)

request = Net::HTTP::Post.new(url.path)
request.set_form_data({'xml' => xml})
http = Net::HTTP.new(url.host, url.port).start
http.read_timeout = 3
response = http.request(req)

# best (move to background jobs)

class SendOrderJob < Struct.new(:message, :action_links)
  def perform(order)
    OrderSender.send_order(order)
  end
end

def create
  Delayed::Job.enqueue SendOrderJob.new(order)
end
