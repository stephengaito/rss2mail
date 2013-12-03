#--
###############################################################################
#                                                                             #
# feed_smtp is a component of rss2mail, the RSS to e-mail forwarder.          #
#                                                                             #
# Copyright (C) 2007-2013 Stephen Gaito                                       #
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

# see: http://ruby-doc.org/stdlib-2.0/libdoc/net/smtp/rdoc/Net/SMTP.html
# see: http://notepad.onghu.com/2007/3/26/sending-email-with-ruby

require 'rss2mail/feed'
require 'net/smtp'
require 'date'
require 'securerandom'

module RSS2Mail

  class FeedSMTP < Feed

    MAIL = "not used"

    def build_message(type_header, to, title, subject, body)
      msgstr = <<END_OF_MESSAGE
From: rss2mail@#{HOST}
To: #{to.join(', ')}
Subject: [#{title}] #{subject}
Date: #{DateTime.now.strftime("%a, %d %b %Y %H:%M:%S %z")}
Message-Id: #{SecureRandom.uuid}
#{type_header}

#{body}
END_OF_MESSAGE
      msgstr
    end

    def send_mail(type_header, to, title, subject, body)
      return if debug

      Net::SMTP.start('localhost', 25) { |smtp|
        smtp.send_message(build_message(type_header, *to, title, subject, body), 
                          "rss2mail@#{HOST}", *to)
      }

      yield if block_given?
    rescue Errno::EPIPE, IOError => err
      error err, 'while sending mail using SMTP', cmd
    end

  end

end

