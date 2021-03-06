# encoding: utf-8

#--
###############################################################################
#                                                                             #
# A component of rss2mail, the RSS to e-mail forwarder.                       #
#                                                                             #
# Copyright (C) 2007-2013 Jens Wille                                          #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@gmail.com>                                       #
#                                                                             #
# rss2mail is free software; you can redistribute it and/or modify it under   #
# the terms of the GNU Affero General Public License as published by the Free #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# rss2mail is distributed in the hope that it will be useful, but WITHOUT ANY #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for     #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with rss2mail. If not, see <http://www.gnu.org/licenses/>.            #
#                                                                             #
###############################################################################
#++

require 'yaml'
require 'sinatra'
require 'rss2mail/util'

use Rack::Auth::Basic do |user, pass|
  @auth ||= begin
    file = File.join(settings.root, 'auth.yaml')
    File.readable?(file) ? YAML.load_file(file) : {}
  end

  @auth[user] == pass
end

helpers ERB::Util

get '/' do
  prepare

  if @feed_url = RSS2Mail::Util.discover_feed(@url = params[:url])
    @title = Nokogiri.HTML(open(@feed_url)).at_css('title').content rescue nil
  end

  erb :index
end

post '/' do
  prepare

  @feed_url = params[:feed_url] or error(400)

  @target = params[:target]
  @target = @targets.find { |t| t.to_s == @target } || :daily

  @title, @to = params[:title] || '', params[:to]
  @title = @feed_url[/[^\/]+\z/][/[\w.]+/] if @title.empty?

  unless (feeds = @feeds[@target]).find { |f| f[:url] == @feed_url }
    feeds << { :url => @feed_url, :title => @title, :to => @to }
    File.open(@feeds_file, 'w') { |f| YAML.dump(@feeds, f) }
  end

  erb :index
end

def prepare
  user = request.env['REMOTE_USER'] or error(400)

  @feeds_file = File.join(settings.root, 'feeds.d', "#{user}.yaml")
  @feeds      = File.readable?(@feeds_file) ? YAML.load_file(@feeds_file) : {}
  @targets    = @feeds.keys.sort_by { |t, _| t.to_s }
end

__END__
@@index
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
    "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
  <meta http-equiv="content-type" content="application/xhtml+xml; charset=utf-8" />
  <title><%=h settings.title || 'rss2mail' %></title>
<% if settings.style %>
  <link rel="stylesheet" type="text/css" href="<%=h settings.style %>" />
<% end %>
  <style type="text/css">a.skip { text-decoration: line-through; }</style>
</head>
<body>
  <h1>rss2mail - send rss feeds as e-mail</h1>

  <h2>subscribe</h2>

  <form method="post">
    <input type="text" id="feed_url" name="feed_url" value="<%= @feed_url || @url %>" size="54" />
  <% if @url.nil? || @url.empty? %>
    <label for="feed_url">»url«</label>
  <% else %>
    [<a href="<%= @url %>">link</a><% if @feed_url %> | <a href="<%= @feed_url %>">feed</a><% end %>]
  <% end %>
    <br />
    <input type="text" id="title" name="title" value="<%=h @title %>" size="54" />
    <label for="title">»title«</label>
    <br />
    <input type="text" id="to" name="to" value="<%=h @to %>" size="54" />
    <label for="to">»to«</label>
    <br />
    <select id="target" name="target">
    <% for target in @targets %>
      <option<%= target == @target ? ' selected="selected"' : '' %>><%=h target %></option>
    <% end %>
    </select>
    <br />
    <input type="submit" value="subscribe!" style="margin-top: 0.6em; font-weight: bold" />
  </form>

  <h2>subscriptions</h2>

  <ul>
  <% for target in @targets %>
    <li>
      <strong><%=h target %></strong> (<%= @feeds[target].size %>)

      <ul>
      <% for feed in @feeds[target].sort_by { |f| f[:title].downcase } %>
        <li>
          <a href="<%= feed[:url] %>" class="<%= 'skip' if feed[:skip] %>"><%=h feed[:title] %></a>
          <small>(<%=h Array(feed[:to]).join(', ') %>)</small>
        </li>
      <% end %>
      </ul>
    </li>
  <% end %>
  </ul>

  <p><em>
    powered by <a href="http://blackwinter.github.com/rss2mail">RSS2Mail</a>
    and <a href="http://sinatrarb.com">Sinatra</a> -- v<%=h RSS2Mail::VERSION %>
  </em></p>
</body>
</html>
