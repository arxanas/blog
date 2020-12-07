---
layout: post
title: I used to run my own mail server
permalink: mail-server/
tags:
  - software-engineering
---

I used to run my own mail server on this domain. That's because I receive email at this domain, and being a student at the time, I didn't want to pay an additional cost for an email service on top of the domain and hosting costs.

It was surprisingly complex. After a lot of frustrating debugging, I installed and configured Postfix and Dovecot. Looking back at it now, maybe I can understand a little of the awful mail situation that the authors of [The UNIX-HATERS Handbook](https://web.mit.edu/~simsong/www/ugh.pdf) lamented.

I also had Logwatch configured on my server, which sends daily log digests to my personal Gmail address. One day, I got a much larger email than usual, with about 500 entries of this form:

```
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=100, msgid=<1916378978.228657.1422669964925.JavaMail.s605113@s605113nj3cu23.uspswy6.savv..., size=3846: 1 Time(s)
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=101, msgid=<1249814308.228946.1422670382174.JavaMail.s605113@s605113nj3cu23.uspswy6.savv..., size=5784: 1 Time(s)
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=102, msgid=<601365427.63734562.1422671000015.JavaMail.jobnotification@noreply.jobs2web.com>, size=3576: 1 Time(s)
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=103, msgid=<87573488.39381.1422671386061.JavaMail.rcc@127.0.0.1>, size=8427: 1 Time(s)
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=104, msgid=<1193028303.63734619.1422671449632.JavaMail.jobnotification@noreply.jobs2web...., size=8061: 1 Time(s)
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=105, msgid=<1643814520.773962.1422671831522.JavaMail.app@ltx1-app10243.prod>, size=28350: 1 Time(s)
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=106, msgid=<30128166.20150131023820.54cc401cc8ef84.75123093@mail149.wdc04.mandrillapp.com>, size=25278: 1 Time(s)
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=107, msgid=<d33d663bb8154e91ad366791d6415e4c@verona-exch-2.epic.com>, size=8389: 1 Time(s)
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=108, msgid=<201502030243.t132hp8Q025750@goon4.epic.com>, size=2416: 1 Time(s)
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=109, msgid=<20150203183535.BD0B2AF0001@prod-batch01.recsolu.com>, size=11568: 1 Time(s)
dovecot: imap(me@waleedkhan.name): expunge: box=INBOX, uid=110, msgid=<1968774189.2003704.1422991430758.JavaMail.app@lva1-app3310.prod>, size=27061: 1 Time(s)
```

I didn't really know what "expunge" means in technical terms, except that it sounds like deletion, and I certainly didn't know what triggered 500 of them. (I still don't.) When I feverishly logged into my email account, I found that a huge chunk of mail indeed seemed to be missing. I wasn't able to recover them from my server's disk. I thought I had backups, but I discovered that day that I had apparently failed to enable DigitalOcean's backup service for my server.

At the time, I was interviewing for internships. In fact, I lost the offer letter I had intended to accept, and had to ask the recruiter to re-send it. I imagine it wasn't a very professional look!

I tried to be a responsible system administrator, but clearly I didn't have the time or attention to do so effectively. Now I happily pay $5 a month for a professional service to manage my email --- reliably.
