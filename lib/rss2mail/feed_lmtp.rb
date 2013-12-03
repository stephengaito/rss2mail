#--
###############################################################################
#                                                                             #
# feed_lmtp is a component of rss2mail, the RSS to e-mail forwarder.          #
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

# see: http://en.wikipedia.org/wiki/Local_Mail_Transfer_Protocol

require 'rss2mail/feed_smtp'
require 'net/smtp'

# This is a very simple overlay of LMTP on top of Ruby's existing SMTP.
#
# This WILL NOT work for messages being sent to more than one recipient 
# on the local machine.  But for our purposes, this is more than 
# sufficient.

module Net
  class LMTP < SMTP

    # Send LMTP's LHLO command instead of SMTP's HELO command
    def helo(domain)
      getok("LHLO #{domain}")
    end

    # Send LMTP's LHLO command instead of ESMTP's EHLO command
    def ehlo(domain)
      getok("LHLO #{domain}")
    end
  end
end

module RSS2Mail

  class FeedLMTP < FeedSMTP

    def send_mail(type_header, to, title, subject, body)
      return if debug

      to.each { | aRecipient |
        Net::LMTP.start('localhost', 24) { |lmtp|
          lmtp.send_message(build_message(type_header, [aRecipient], title, subject, body), 
                            "rss2mail@#{HOST}", aRecipient)
        }
      }

      yield if block_given?
    rescue Errno::EPIPE, IOError => err
      error err, 'while sending mail using LMTP', cmd
    end

  end

end

