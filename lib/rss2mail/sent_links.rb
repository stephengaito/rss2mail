#--
###############################################################################
#                                                                             #
# sentLinks.rb is a component of rss2mail, the RSS to e-mail forwarder.       #
#                                                                             #
# Copyright (C) 2013 Stephen Gaito                                            #
#                                                                             #
# Authors:                                                                    #
#     Stephen Gaito <stephen@perceptisys.co.uk>                               #
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

module RSS2Mail

  module SentLists

    def self.sentListFileName(feeds_file)
      feeds_file.sub(/\.[Yy][Aa][Mm][Ll]$/,'.sentListYaml')
    end

    def self.mergeSentListInto(feeds, feeds_file, verbose = false)
      sentList = YAML.load_file(sentListFileName(feeds_file))
      
      feeds.each_pair { | feedName, feedDetails | 
        next unless sentList.has_key?(feedName)
        feedSentLists = sentList[feedName]
        feedDetails.each { | aFeed |
          next unless aFeed.has_key?(:url)
          url = aFeed[:url].to_sym
          next unless feedSentLists.has_key?(url)
          aFeed[:sent] = feedSentLists[url]
        }
      }

      feeds
    end

    def self.demergeSentListFrom(feeds, feeds_file, verbose = false)
      puts "demerging sent lists from #{feeds_file}" if verbose
      sentList = Hash.new()

      feeds.each_pair { | feedName, feedDetails |
        feedSentLists = sentList[feedName] = Hash.new()
        feedDetails.each { | aFeed |
          next unless aFeed.has_key?(:sent)
          next unless aFeed.has_key?(:url)
          url = aFeed[:url].to_sym
          feedSentList = aFeed.delete(:sent)
          if aFeed.has_key?(:sentListLimit) then
            limit = aFeed[:sentListLimit].to_i
            puts "Limiting sentList to [#{limit}] for #{url}" if verbose
            feedSentList = feedSentList.slice(-limit, limit)  if limit < feedSentList.size
          end
          feedSentLists[url] = feedSentList
        }
      }

      File.open(sentListFileName(feeds_file), 'w') { |f| 
        f.write(YAML.dump(sentList))
      }

      feeds
    end

  end

end
