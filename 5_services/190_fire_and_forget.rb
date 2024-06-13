# When dealing with external services, there are three main response strategies: 
# • Check the response, catching any and all errors, and gracefully handle each potential case.
# • Check the response for simple success or failure and don’t gracefully handle anything else.
# • Don’t check the response at all; either assume that the request always succeeds or simply don’t care if it fails.

# The third strategy, which we call “fire and forget,” may be valid in rare circumstances, but in most cases, it’s insufficient.

# bad (handle nothing)

def post_to_facebook_feed(message, action_links)
  facebook_session.user.publish_to(facebook_session.user, :message => message, :action_links => action_links)
end

# rescuing all errors is a very bad practice to get into; frankly, you should never do it.

# good (handle a bunch of errors)

def post_to_facebook_feed(message, action_links)
  facebook_session.user.publish_to(facebook_session.user,
                                    :message => message,
                                    :action_links => action_links)
  rescue *FACEBOOK_ERRORS => facebook_error
  HoptoadNotifier.notify facebook_error
end

# The FACEBOOK_ERRORS constant contains the following exceptions:

FACEBOOK_ERRORS = [Facebooker::NonSessionUser,
                    Facebooker::Session::SessionExpired,
                    Facebooker::Session::UnknownError,
                    Facebooker::Session::ServiceUnavailable,
                    Facebooker::Session::MaxRequestsDepleted,
                    Facebooker::Session::HostNotAllowed,
                    Facebooker::Session::MissingOrInvalidParameter,
                    Facebooker::Session::InvalidAPIKey,
                    Facebooker::Session::CallOutOfOrder,
                    Facebooker::Session::IncorrectSignature,
                    Facebooker::Session::SignatureTooOld,
                    Facebooker::Session::TooManyUserCalls,
                    Facebooker::Session::TooManyUserActionCalls,
                    Facebooker::Session::InvalidFeedTitleLink,
                    Facebooker::Session::InvalidFeedTitleLength,
                    Facebooker::Session::InvalidFeedTitleName,
                    Facebooker::Session::BlankFeedTitle,
                    Facebooker::Session::FeedBodyLengthTooLong]

# other example (don't rescue with rescue => event and no error class)

HTTP_ERRORS = [Timeout::Error,
                Errno::EINVAL,
                Errno::ECONNRESET,
                EOFError,
                Net::HTTPBadResponse,
                Net::HTTPHeaderSyntaxError,
                Net::ProtocolError]

You would then use the following:

begin
  req = Net::HTTP::Post.new(url.path)
  req.set_form_data({'xml' => xml})
  http = Net::HTTP.new(url.host, url.port).start
  response = http.request(req)
rescue *HTTP_ERRORS => e
  HoptoadNotifier.notify e
end

# Note that you shouldn’t rescue all errors with rescue => e, and there is a gotcha if you try to. Timeout::Error doesn’t descend from StandardError, and rescue with no exception classes specified rescues only exceptions that descend from StandardError. Therefore, timeouts aren’t caught, and they result in total failure.

config.action_mailer.raise_delivery_errors = false

# With this setting, no errors can be raised, including those for both connection errors and bad email addresses.