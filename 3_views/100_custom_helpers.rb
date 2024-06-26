# bad (if clauses in views)

<div class="feed">
  <% if @project %>
    <%= link_to "Subscribe to #{@project.name} alerts.",
        project_alerts_url(@project, :format => :rss),
        :class => "feed_link" %>
  <% else %>
    <%= link_to "Subscribe to these alerts.",
        alerts_url(format => :rss),
        :class => "feed_link" %>
  <% end %>
</div>>

# better (move logic to helper)

def rss_link(project = nil)
  link_to "Subscribe to these #{project.name if project} alerts.",
    alerts_rss_url(project),
    :class => "feed_link"
end

def alerts_rss_url(project = nil)
  if project
    project_alerts_url(project, :format => :rss)
  else
    alerts_url(:rss)
  end
end

<div class="feed">
  <%= rss_link(@project) %>
</div>>

# best (include div tag in the helper method

def rss_link(project = nil)
  content_tag :div, :class => "feed" do
    link_to "Subscribe to these #{project.name if project} alerts.",
      alerts_rss_url(project),
      :class => "feed_link"
  end
end

# or similarly

def rss_link(project = nil)
  content_tag :div, :class => "feed" do
    content_tag :a,
      "Subscribe to these #{project.name if project} alerts.",
      :href => alerts_rss_url(project),
      :class => "feed_link"
end
  