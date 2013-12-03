= Using [LMTP](http://en.wikipedia.org/wiki/Local_Mail_Transfer_Protocol) to deliver rss2mail email

== Requirements

1. While you do not use it, a "mail" program MUST be installed. If you do 
not have any mail programs, then simply type "ln -s /bin/false 
/bin/mail" as root.

1. You MUST have a properly configured 
[LMTP](http://en.wikipedia.org/wiki/Local_Mail_Transfer_Protocol) 
process listening to port 24 on localhost.

== Use case

My particular use case was to feed rss/atom feeds through 
[POPFile](http://getpopfile.org/) for naive Bayesian classification.

To do this I had [dovecot](http://www.dovecot.org/), 
[fetchmail](http://fetchmail.berlios.de/), and 
[POPFile](http://getpopfile.org/) running inside an 
[LXC](http://en.wikipedia.org/wiki/LXC) on my server.

I had [dovecot](http://www.dovecot.org/) configured to recieve local 
email via 
[LMTP](http://en.wikipedia.org/wiki/Local_Mail_Transfer_Protocol).

I did not have any other 
[MTA](http://en.wikipedia.org/wiki/Message_transfer_agent) (such as 
Postfix or Sendmail). Nor did I have a 
[MUA](http://en.wikipedia.org/wiki/Mail_user_agent) (such as mail or 
mutt).

== Invoking rss2mail 

Type:

  rss2mail --lmtp --directory /home/www/rssFeeds hourly

or more simply:

  rss2mail -l -d /home/www/rssFeeds hourly

Change the location of your feeds directory to suit your needs.  The 
target you give rss2mail ("hourly") must be in one or more of your feed 
descriptions contaided in your feeds directory.

