# Using [SMTP](http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) to deliver rss2mail email

## Requirements

1. While you do not use it, a "mail" program MUST be installed. If you do 
not have any mail programs, then simply type "ln -s /bin/false 
/bin/mail" as root.

1. You MUST have a properly configured 
[SMTP](http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) 
process listening to port 25 on localhost.

## Use case

My particular use case was to use [dovecot](http://www.dovecot.org/)'s 
[LMTP](http://en.wikipedia.org/wiki/Local_Mail_Transfer_Protocol) 
server.

Since [LMTP](http://en.wikipedia.org/wiki/Local_Mail_Transfer_Protocol) 
is based upon 
[SMTP](http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) I 
added 
[SMTP](http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) to 
rss2mail as the FeedSMTP subclass of Feed.  I then added the FeedLMTP 
class as a further subclass of FeedSMTP.

**NOTE:** I have not directly tested rss2mail using an 
[SMTP](http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol)
server.  I **am** using it with an 
[LMTP](http://en.wikipedia.org/wiki/Local_Mail_Transfer_Protocol) 
server. See [usingLMTP](usingLMTP.md).

## Invoking rss2mail

Type:

>  rss2mail --smtp --directory /home/www/rssFeeds hourly

or more simply:

>  rss2mail -s -d /home/www/rssFeeds hourly

Change the location of your feeds directory to suit your needs. The 
target you give rss2mail ("hourly") must be in one or more of your feed 
descriptions contaided in your feeds directory.
