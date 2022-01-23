---
layout: post
title: Automatically detecting and replying to recruiter spam
permalink: detect-recruiter-spam/
tags:
  - career
  - machine-learning
  - python
---

 * toc
{:toc}

The code for this post is at my Github repository: [github.com/arxanas/detect-recruiter-spam](https://github.com/arxanas/detect-recruiter-spam). However, I have not included my pre-trained model, since it contains sensitive information derived from  my email inbox. If you would like to use my API endpoint, send me an email.

If you just want to see the results, skip to [Results](#results).

## Introduction

Many software engineers I know complain about the frequency of "recruiter spam" emails. These emails are unsolicited, obviously-generic emails sent in an attempt to push engineers through their hiring pipelines, regardless of whether they would be a good fit for the job in question.

It’s understandable. In the current climate (I live in the US), job-seeking is a numbers game. Job seekers blast countless job sites with their résumés, while recruiters browse through LinkedIn wielding a mouse in one hand and a templated introduction in the other.

So why engage with these recruiters? Well, as a college graduate, I interviewed at Microsoft, thinking that I would never accept a job offer from them. But the recruiter really astounded me with the whole experience, and Microsoft changed from being barely a contender to one of my top choices. Since then, I have a policy of at least giving companies a chance to impress me.

So I don’t want to miss out on a potential opportunity, but on the other hand, I don’t want to waste time on low-quality recruiter interactions. So I decided that further automated emailing must be the solution.

## Bayesian filtering

A Bayesian spam filter is a simple binary classification model, often used as a first project in a machine learning course. It accepts a document and returns whether it thinks that the document is spam or not. I used the [`scikit-learn`](https://scikit-learn.org/stable/) library to build my model.

### Approach

The idea is to encode each message as a vector of zeros and ones. To do this, we first accumulate all of the different words across all of the different messages (with some normalization applied, such as lowercasing, removing punctuation, lemmatizing, etc.). Then we assign each unique word a different index, starting from zero. For each unique word in a given message, we set the entry at that word’s index to `1` in its corresponding vector. `scikit-learn` includes the convenient [`CountVectorizer`](https://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.CountVectorizer.html) class for this purpose.

Then we just feed the result into a pre-made Bayesian classifier model. I used [`MultinomialNB`](https://scikit-learn.org/stable/modules/generated/sklearn.naive_bayes.MultinomialNB.html) from `scikit-learn`. (This model actually accepts a vector of not just zeros and ones, but word frequency counts.)

The code is relatively simple, available here: [https://github.com/arxanas/detect-recruiter-spam/blob/main/recruiterspam/train.py](https://github.com/arxanas/detect-recruiter-spam/blob/main/recruiterspam/train.py)

### Properties

A Bayesian filter is a decent general-purpose classifier for this use-case. However, it’s worth noting some of its limitations:

* It isn’t able to deal with words that didn’t appear in the training set.
* If the training set has few positive or negative examples, it may not be trained very accurately.
    * For example, if your training set has 0.01% spam messages, then a classifier which always outputs "not spam" will be accurate for the vast majority of the inputs, but such a model is useless.
    * According to the `scikit-learn` documentation, there are some tricks that can be done to improve the accuracy in these cases, such as by training classification against the complement of the desired output classes.

In real life, a false positive (detecting an email as spam when it’s not) is particularly bad if it results in the loss of important communication, while a false negative (failing to detect a spam email) is mostly an annoyance. Thus, a typical Bayesian classifier probably wants to optimize to reduce false positives.

In our case, I don’t mind if the classifier occasionally returns false positives, because the resulting emails won’t be deleted — the recipient will just receive an automated email, which they can ignore. Thus, we can afford to optimize the classifier towards decreasing false negatives.

## Training

To actually train the model, I went through all of my email and manually tagged recruiter spam emails as such. This wasn’t too bad, as I was able to filter out most of the automated email in my inbox pretty easily during manual annotation.

The repository includes two scripts to download your mailbox. One works by reading each message over IMAP, while the other works by reading a local `.mbox` file. (For Gmail, you can get an `.mbox` file by using the Google Takeout feature.)

My training set consisted of:

* 16752 messages,
* 182 of which were spam,
* resulting in an accuracy of 95.2%,
* and a false positive rate of 4.7%.

For an actual spam filter, these numbers would be abysmal, but they’re fine for my purposes.

## Deployment

The model is deployed as a REST API endpoint. I tried really hard to deploy the model to AWS Lambda, but despite my packaging everything up into a Docker container, I had inscrutable differences between my local testing environment and the cloud one, and I couldn't get it to work. In the end, I gave up and used a Heroku instance ($7 per month), which is significantly more expensive, but at least works without hassle.

To connect the model to my email account and have it be able to reply on my behalf, I first tried using services like Zapier and IFTTT. However, they didn’t have useful integrations at the free tier, and the paid tier would cost $25+ per month, which was more than I wanted to pay.

Instead, I used [CloudMailIn](https://www.cloudmailin.com/). They have a usable free tier, helpful documentation, and customer support even helped me with a coding issue I had during development.

I simply set up a Gmail filter to forward email to CloudMailIn, which forwarded it to the Heroku service. The service would then call back into CloudMailIn to send a reply email using my email address, if necessary.

## Automatic salary negotiation

Large companies have well-defined levels with associated compensation ranges. In my script, if I was able to determine the company that the recruiter represented, I cross-referenced the recruiter’s company with data from [Levels.fyi](https://www.levels.fyi/) and compared it to my current company’s level and salary, and used that information to propose a level to interview at. (I’ve been bitten a couple of times by not clarifying the salary ranges up-front with recruiters, so I figure it’s best to automate it.)

## Results

### Example

Here’s an example exchange with Amazon:

> Dear Waleed,
>
> I came across your LinkedIn profile and am so impressed with your skill set! I'm looking for great people with your background for our AZ, OR, TX, TN, NY, CA and Canada locations for SDEII (80% coding and 20% System design).
>
> IF YOU ARE CURRENTLY WORKING OR HAS APPLIED FOR ANY POSITION WITH AMAZON IN THE LAST 3 MONTHS. PLEASE LET ME KNOW
>
> If not, I was wondering if you would like to connect and discuss possibilities?
>
> Qualifications
>
> * 3+ years of non-internship professional software development experience
> * Programming experience with at least one modern language such as Java, C++, or C# including object-oriented design
> * 1+ years of experience contributing to the architecture and design (architecture, design patterns, reliability and scaling) of new and current systems.
> * Experience building complex software systems that have been successfully delivered to customers
> * Knowledge of professional software engineering practices and best practices for the full software development lifecycle, including coding standards, code reviews, source control management, build processes, testing, and operations
> * Ability to take a project from scoping requirements through actual launch of the project
> * Experience in communicating with users, other technical teams, and management to collect requirements, describe software product features, and technical designs.
>
> If interested, please reply back to me along with contact details and email.
>
> [Recruiter name]<br />
> Technical Recruiter at Amazon

And here’s the automated response:

> Hello,
>
> I am always open to the right opportunity, but since I receive so much email from recruiters, I don't have time to individually follow up on every message.
>
> To make things easier for us both, please include the following in your reply:
>
> * The location of the position.
> * Whether your company supports remote work.
> * The team which is hiring.
> * How my experience relates to the team in question.
> * When you are looking to fill the position.
>
> I enjoy competitive compensation at my current company, TWITTER. I've automatically looked up the compensation details for the company you appear to represent, AMAZON, and it seems like I would have to receive an offer at the below level to be compensated competitively.
>
> Company name: AMAZON
>
> Compensation rating: C
>
> Suggested level for competitive compensation: PRINCIPAL SDE/L7
>
> Can you confirm that you can offer the position at the above level?
>
> The following are the details of why your message was flagged as a recruiting message. If this email was sent in error, you can ignore it.
>
> Probability: >99%
>
> Top keywords: SCOPING, OBJECTORIENTED, CONTRIBUTING, LIFECYCLE, COMMUNICATING
>
> Best,
>
> Recruiter Reply Bot

The recruiter did not reply in this case (see [Bugs](#email-delivery)).


### Efficacy

The bot correctly detected 36 recruiter emails over a 3-month period, out of which 6 emails led to further conversation.

At the rate of $7.72 per month,

* That’s $0.64 per response,
* or $3.86 per thread which led to actual discussion.

That price could definitely be reduced (such as by using serverless computing), but considering that I stand to make tens of thousands dollars more per year if I actually do accept a new position, I don’t consider it a bad price to generate "real" leads with recruiters.

The bot also produced 12 false positive replies:

* 1 false positive to a "real" person who was trying to sell me SEO services.
* 4 false positives to a correspondent who writes their emails in Polish, due to a serious bug (see [Bugs](#non-existent-words)). I removed this person from the email forwarding filter after that, so the real incidence would have been higher.
* 4 false positives in response to Facebook Pay automated emails written in Polish, due to the same bug. There were many more automated emails written in Polish from the same service, so it’s not clear to me why only some of them triggered a reply.
* 2 false positives to LinkedIn email notifications, which would probably be difficult to accurately detect given its nature as a recruiting service.
* 1 false positive to an automated newsletter from a miscellaneous service.

There were 29 further false positive replies which were caused by silly bugs, such as replying to emails even when the prediction probability was 0%, which I didn’t include in the above list.

### Responses

* Response #1 (from a recruiter firm): They represented an early-stage startup in Canada. They gave a salary range, but I declined because they couldn’t meet my US-centric salary expectations.

* Response #2 (from a recruiter for finance): They responded with "Thank you for responding to my email, automated though it may be.", being the only person who acknowledged the automated nature of my response. They gave me useful information with the role and location, but only said that compensation "a minimum of 30% more than what you’re making now". I declined because I was interested in working in functional programming languages, rather than C++ and Python.

* Response #3 (from a recruiting firm): I asked for a salary range in advance, and they declined to give it (after a 10-email thread!), so we stopped communication.

* Response #4 (from an early-stage startup): I asked for a salary range in advance, and they declined to give it, so we stopped communication.

* Response #5 (from a late-stage startup): I actually proceeded to a phone call with the recruiter. They had an interesting team, but I declined to move forward with an interview, since it wouldn’t be a substantial compensation increase, and the equity portion would be illiquid, as the company was not public.

* Response #6 (from an early-stage startup): They just responded "Okay, thank you!" to my automated reply, which I assume means that they did not want to share salary information.

### Selected amusing keywords

Recruiters use a lot of common buzzwords in their emails, which is the premise for detecting those emails automatically. Here are some of the keywords which I found amusing. (Each of the following keywords [had to appear in more than one email in the training set](https://github.com/arxanas/detect-recruiter-spam/blob/829b2ed18394388fe977ce39f407107c88f16a66/recruiterspam/train.py#L141-L142) to be flagged.)

* `PROFITABLE`, `ACTIONABLE`, `MOBILIZE`, `RAPIDLY`, `COGNITIVE`
* `AMAZONIANS`, `INNOVATE`, `PURSUING`, `RAPIDLY`, `SKILLED`
* `ARLINGTON`, `MICROSERVICES`, `FINTECH`, `JERSEY`, `STRIVING`
* `PIQUED`, `FOREFRONT`, `COMPLIANT`, `RAPIDLY`, `HEALTHTECH`
* `ENG`, `COMPELLING`, `CERTAINTY`, `OWNING`, `TALENTED`
* `FINTECH`, `SOURCER`, `COLLABORATIVE`, `IMPRESSED`, `OUTDATED`
    * "Sourcer" is part of the sender’s signature, rather than the email body.
* `AUTONOMOUS`, `SOURCER`, `ACCELERATION`, `CRUISE`, `TALENTED`
* `RECONNECT`, `CAREERSGOOGLECOM`, `LATELY`, `IMAGINE`, `ACCOMMODATION`
    * Obviously, this one was from Google. The punctuation in the URL has been removed as part of preprocessing.
* `SCOPING`, `OBJECTORIENTED`, `CONTRIBUTING`, `LIFECYCLE`, `COMMUNICATING`
* `250K`, `FINTECH`, `HYPERGROWTH`, `LUCRATIVE`, `RAPIDLY`
    * Apparently $250k is a common number mentioned in recruiting emails?
* `SIGMA`, `AMIDST`, `CHEERS`, `SELECTIVE`, `SHAW`
    * "Sigma" refers to "Two Sigma" and "Shaw" refers to "DE Shaw", both finance firms.
* `AMIDST`, `SELECTIVE`, `SHAW`, `REVOLUTIONIZE`, `QUANTITATIVE`


## Bugs


### Non-existent words

Strangely, the filter triggers often on email which contain words that don’t appear in the training corpus. The `CountVectorizer` should have removed these words from the input vector, and if the vector were entirely empty in the end, then the output should have taken on the prior probability of ~1%, which is not enough to trigger a response.

For example, an email with the following keywords was triggered:

> Probability: >99%
>
> Top keywords: MIDZY, UKASZ, MINUT, DZISIEJSZE, PAR

None of these words appeared in the training set, so they should not have contributed to the classification.

T/L note: non-ASCII letters were removed as part of pre-processing. Here is the translation table for the above words:

* "MIDZY" = "między", meaning "during";
* "UKASZ" = "Łukasz", a given name;
* "MINUT" means "minute";
* "DZISIEJSZE" means "today’s";
* "PAR" = "parę", meaning "couple".

### Email delivery

When receiving an email from LinkedIn, it says at the bottom that I can reply to the email directly. However, it appears that all of the reply emails bounced with the error "550 5.7.1 sender not authorised to email this recipient". I assume that this is because I haven’t set up SPF on my domain. I could either set it up, or route my emails directly through Gmail.

Additionally, I never received a response from any Microsoft or Amazon recruiter, despite them making up the vast majority of incoming recruiter emails. The logs indicate that email delivery succeeded, but they’re using custom recruiting management solutions, so perhaps the email was rejected at some later step in the process.

Or alternatively, maybe they’ve decided not to waste their time with my automated emails, just like I decided not to waste my time with theirs?

{% include end_matter.md %}
