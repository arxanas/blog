---
layout: post
title: 'Login.gov neutered the security of 2FA'
permalink: login-gov-2fa/
hidden: true
tags:
  - security
hn: https://news.ycombinator.com/item?id=21785524
---

### Update

This is fortunately not true, [as the folks on Hacker News informed me](https://news.ycombinator.com/item?id=21785524). I misunderstood what the dialog was
trying to tell me.

A personal key appears to be used only for *recovering a password*, not for
regular 2FA login. The wording is strange because it's not replacing a 2FA
method with another 2FA method for regular authentication, but instead updating
the method used for recovering a password.

I almost certainly got the personal key and threw it away, which is what I
normally do.

From a UI perspective, it would be nice if it mentioned that an authentication
app was already in use. Ironically, having already secured my account caused me
to think that I was making it less secure.

### Original post

Today, I was trying to authenticate to a government website via
[login.gov](https://login.gov), which is a centralized service for logging into
US government websites.

Naturally, logging into government services is a matter of utmost security. As a
result, login.gov features [two-factor authentication (2FA)][2fa]. This lets you
use a second factor for logins, such as a code-generating device that you have.
I had previously set up a code-generation app on my phone to increase the
security of my account.

  [2fa]: https://en.wikipedia.org/wiki/Multi-factor_authentication

I got this message today indicating that I could no longer use this app:

{% image login-gov-2fa-new-options.png
         "Required upgrade to a new 2FA option. They are: 1) SMS, 2) physical
         security key, 3) government security key, 4) none of the above and
         they'll give you 10 codes."
         "Required upgrade to a new 2FA option." %}

What a disappointment! I don't have a dedicated physical security key or
government security key, and I certainly don't want to keep track of physical
codes. The only option for me is SMS... which is phone-based, and the very thing
they're claiming is bad.

[SMS has problems][sms-2fa] as an authentication factor. The main one is that
many services let you gain access to your account using *only* the SMS option,
which means your account really has an extra single-factor authentication method
attached to it, instead of a single dual-factor authentication method.

  [sms-2fa]: https://www.pindrop.com/blog/nist-explains-proposed-ban-on-sms-for-2fa/

But let's suppose that login.gov isn't vulnerable to this. [It's still fairly
easy to hijack SMS messages via social engineering][sms-hijack]. Besides that, a
dedicated attacker could also attempt to physically intercept SMS messages with
special hardware.

  [sms-hijack]: https://www.jwz.org/blog/2018/07/two-factor-auth-and-sms-hijacking/

My phone was a great authentication mechanism. To access the authentication app,
you have to physically have the phone, then enter my 10-digit phone passcode
(not reused anywhere else) to log in, then scan my fingerprint to access my
authentication app. That's three factors right there: [something I have,
something I know, and something I am][3fa]. Beyond that, you also need to know
my login.gov password (also not reused anywhere else).

  [3fa]: https://blog.gemalto.com/security/2011/09/05/three-factor-authentication-something-you-know-something-you-have-something-you-are/

The SMS-based approach is an unfortunate step backwards for security when it's
most important.
