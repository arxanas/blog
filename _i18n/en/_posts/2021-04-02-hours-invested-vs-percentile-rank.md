---
layout: post
title: "Anecdata: hours invested vs percentile rank"
permalink: hours-invested-vs-percentile-rank/
tags:
  - chess
  - learning
  - gaming
  - smash-bros
---

The "10,000-hour rule" is the idea suggested in Malcolm Gladwell's book [*Outliers*](https://en.wikipedia.org/wiki/Outliers_(book)) that you need about 10,000 hours of practice to become an expert in a given field. The specifics are disputed (both in terms of the absolute amount of time, and how much of skill is explained by practice time), but it's a simple way to evaluate one's progress towards experthood.

I switched from competitive chess to competitive videogaming. It's interesting to compare the amount of time invested in each and examine how skillful I became in their respective competitive scenes as a result.

{% include toc.md %}

## Switching away from chess

For the last few years, I have been aiming at becoming a world-class player in my choice of game. Of course, whether I will achieve that goal is a different matter!

I started investing in competitive chess in January 2014, while studying at university, around the time [Magnus Carlsen](https://en.wikipedia.org/wiki/Magnus_Carlsen) won the world championship and consequently sparked a renewed interest in chess for many.

I graduated from university in April 2016, took up a full-time job, and played continuously until March 2019. I decided to quit in favor of playing the fighting game [*Super Smash Bros. Ultimate*](https://en.wikipedia.org/wiki/Super_Smash_Bros._Ultimate) competitively. It was released in December 2018, just a few months prior.

I decided to switch for two main reasons:

* The competition in chess is much fiercer. The game has been popular for hundreds of years, and the learning tools and resources have developed much more than for the *Smash Bros.* franchise, whose first entrant was released in 1999.
* I generally enjoy playing *Smash* more than chess, which means that I naturally invest more practice time into it.

Since I invested a significant amount of time in chess before dropping it, I want to look back at the data in this article and decide it was justified from a strictly numerical point of view. This might also impart some useful lessons for my other hobbies (currently piano and learning Polish).

## Data

You can skip this section to go to [Analysis](#analysis) if the details of the data don't interest you.

### Chess

As a kid, I knew the rules and played in a handful of scholastic tournaments of laughable strength. For my chess blitz rating, I started at an estimated **22nd percentile** and spent **1068 hours practicing** to proceed to the **77th percentile**.  Blitz strength may not be a good measure of skill, so see the analysis later.

#### Background: practicing chess

Chess practice is primarily broken into time spent playing games and time spent studying. Studying is further divided into many areas:

* *Tactics training*: The majority of training time is spent here. There are many automated tools to improve tactical skill, since it can be evaluated entirely by computer.
* *Strategic training*: This is harder to train. Usually, one learns by reading about abstract principles in books, analyzing games, or receiving professional instruction.
* *Endgame training*: At the endgame of chess, there are few pieces remaining on the board, and a mix of endgame-specific tactical and strategic principles need to be studied.
* *Opening training*: Usually, it's recommended for beginners not to focus on this, as the advantages are marginal compared to time spent on other areas of the game.
* Analyzing one's own games.
* Analyzing top players' games.

#### Percentile calculation

I estimated the percentile for my blitz strength. In a blitz game, each side has under ten minutes (or equivalent, due to chess clock rules) to make all their moves.

I started a blitz rating of 850 at Chess.com. I wasn't able to access the estimated percentile on Chess.com, so I added 300 rating points to roughly convert it to a Lichess rating, and used their leaderboards. I switched to primarly playing on Lichess for most games, where I ended with a blitz rating of 1801, which is the 77th percentile according to the Lichess leaderboards.

#### Practice time breakdown

* [ChessTempo](https://chesstempo.com/) tactics training: 746.5 hours.
* [Lichess](https://lichess.org/) game time: 275 hours (1753 games).
* [Chess.com](https://chess.com/) game time: estimated 47 hours (300 games).
  * I couldn't find this information on Chess.com easily. I took the average time per game from Lichess (275 hours / 1753 games) and multiplied it by my total number of games on Chess.com (300 games).
* Lichess percentile: 77% blitz (from the [blitz leaderboard](https://lichess.org/stat/rating/distribution/blitz)), 80% rapid (from the [rapid leaderboard](https://lichess.org/stat/rating/distribution/rapid)).
  * Chess.com also has percentile information, but it's not available to me unless I've played a game recently.
* A small amount of time (<20 hours) reading a couple of chess books.
* A small amount of time (<20 hours) playing at the local chess club. (The events take place in a windowless basement for up to 12 hours at a time, so I only went a couple of times.)

I took the lower bound of 746 + 275 + 47 = 1068 hours.

### Smash

I played *Super Smash Bros. Brawl* as a kid, but only very casually. I've also had a variety of other dexterity-focused video games and hobbies.

I started at the **4th percentile** and spent an estimated **1204** hours to reach the **99th percentile** of online players.

#### Background: practicing Smash

There is a "training mode" in *Smash Ultimate*, which allows you to test out moves and combos against CPU opponents or real training partners. People use training mode to do drills, which are necessary to execute the fine-grained movements required by the game.

The training mode is somewhat deficient compared to other fighting games when it comes to practicing combos rather than doing drills. While you're executing a combo, the opponent may be able to input certain moves to escape, which the CPU will not do. If you don't have a training partner, there are some software mods and hardware devices which can simulate these inputs. I didn't have access to a training partner, and I didn't use one of these automated solutions.

I watched a few training videos on YouTube for general *Smash* skills and specific to my character. I even [created a training tool](/smash-training-retrospective/) for myself to practice drills. This is an example of where I think the training tools are not well-developed in Smash compared to chess, and having access to a new tool could in principle accelerate the growth of new entrants.

Other than training mode, players play games, either in-person or online. They can also analyze them later, although the built-in tools for doing so are not convenient to use. I spent a significant amount of time in training mode, but I mostly played games.

#### Percentile calculation

The *Smash* online gameplay uses an inverted ranking system, in which your ranking is the number of players that you're better than. It's probably backed by an traditional rating system. Annoyingly, this means that your ranking will change over time without any meaningful differences in your skill.

When a player reaches a percentile certain threshold, they're admitted into "Elite Smash". User-reported numbers have allowed people to reverse-engineer the total number of ranked players at any given time. In my experience, the estimate is fairly accurate (say, within 25,000).

Unfortunately, I don't remember the exact player count when I started. Some trawling through historical Reddit threads suggests it was at least 3,000,000 players. I remember being below 100,000 rank when I started, so that optimistically puts me at the 4th percentile.

#### Practice time breakdown

The Nintendo Switch records in-game time for the games you play. According to the Nintendo Switch's in-game play time, I spent approximately 1204 hours to reach the 99.0th percentile. Some of that time was spent in loading screens or playing casually with friends.

## Analysis

### Summary

The data is summarized below:

| Game | Start percentile | Hours spent | End percentile |
|:--|--:|--:|--:|
| Chess | 22% | 1068 | 77% |
| *Smash Ultimate* | 4% | 1204 | 99% |

Based on just the numbers, it looks like practicing *Smash Ultimate* is a significantly better use of my time!

### Caveats

#### Blitz chess

I primarily played "blitz" chess. In a blitz game, each side has under ten minutes (or equivalent, due to chess clock rules) to make all their moves. The conventional wisdom is that one should focus on standard chess to improve their general skills, and blitz chess to improve their blitz skills.

I also played "rapid" chess games (which range between ten and thirty minutes). These games are much closer to the kind of games played in tournaments, but arguably still not slow enough. Interestingly, my rapid ratings were almost exactly the same as my blitz ratings:

* Chess.com: blitz 1644, rapid 1645
* Lichess: blitz 1801, rapid 1804

One could reasonably argue that I made much less progress in chess than in *Smash* because I didn't play enough slow chess. I'm not necessarily convinced by this conclusion:

* Playing blitz games rather than slow games means more games with shorter feedback loops. Why should that be a bad thing? I think the determination of quality of this practice time is how much I thought about the game while playing it, rather than how long the game happened to be. Personally, I played blitz chess deliberately, focusing on finding a strong move, rather than running down the clock or playing on instinct.
* 746 hours / 1068 hours = 69% of my practice time was spent on tactics training. Does that mean that the other 31% of time was so poorly spent that it explains the 22-point percentile difference between chess and *Smash*?

I have not formally researched this topic to see if the question has been answered in the literature.

#### Online Smash

The online experience for chess is as good or better than over-the-board experience. It's generally easier to see all the pieces and move them around. Most chess sites implement a "pre-move" system, which is convenient, and makes it possible to play games at a speed which aren't realistic over-the board.

On the other hand, the online experience for *Smash Ultimate* is not very good. In an in-person game, there are six frames (0.1 seconds) of input delay between pressing a button and having it happen. The online gameplay automatically enforces a minimum of five extra frames of delay, almost doubling the input delay compared to an in-person game, regardless of the actual geographic latency between players.

Furthermore, the netcode for *Smash Ultimate* uses a primarily "delay-based" mechanism, where all messages have to be acknowledged by all parties before gameplay can proceed. The current state-of-the-art for online fighting games is "rollback-based", where each party can speculatively execute actions on behalf of the other party, and fix the game state only if the prediction was wrong.

As a result of these factors, *Smash Ultimate* has more latency than you would expect from a different fighting game, to the point where the metagame changes significantly online, and players generally can't play optimally. Online *Smash Ultimate* tournaments are not regarded seriously in the competitive scene, compared to in-person tournaments.

#### Differing player pools

*Smash Bros.* has always been marketed by Nintendo as a primarily casual game, whereas chess may be considered to have a more serious player-base. So reaching the 99th percentile in online *Smash* play is not as meaningful as reaching the 99th percentile in online chess play.

In-person tournaments have a more serious self-selected pool of players. Since I quit my local chess club, and since COVID-19 shut down in-person *Smash* tournaments, it's hard for me to get a sense of how I compare in the competitive scene. My guess is that I'm below the 50th percentile among in-person tournament players for both games.

## Conclusions

### Is *Smash* a better use of my time?

Certainly. Regardless of the absolute amount of time spent or the percentiles achieved, I managed to spend about the same amount of practice time in chess over five years as I did in *Smash* over two years. This indicates that I naturally enjoy it a lot more, and I will probably be better at it as a result.

### Can I reach expert strength in *Smash*?

If we assume that it takes 10,000 hours of practice, then maybe. At the rate of 1200 practice hours over two years, one would expect that I could reach the 10,000 hour mark in about 6.3 years from now.

A particular concern for competitive videogaming is that one can expect response times to [start declining at the age of 24](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0094215). I am 24 at the time of this writing, so I would be 30 years of age by the time I reached 10,000 hours, which will put me at a natural disadvantage compared to younger players. It might not be an insurmountable obstacle --- it's not as if 30-year-olds are known for their infamously-poor response times.

One case-study is the *Super Smash Bros. Melee* player [Zain](https://www.ssbwiki.com/Smasher:Zain), who started playing competitively in 2014, and started producing top results within five years. It's an encouraging result in terms of the absolute timeline. On the other hand, it's possible that he simply practices around 3.5x as much as me (that is, 2000 hours a year, rather than 1200 hours in two years).

Since *Smash* is not as well developed as chess, it might be that I could reach an expert level in less time than the 10,000 hours. Or it simply might not require 10,000 hours.

### Are there any lessons for my other hobbies?

My piano-playing ability is quite poor at the moment. I would estimate I've spent around 300 total practice hours on it, since it took it up in November 2019. Unfortunately, I took no objective measurements.

Unlike competitive videogaming, where one is matched to an opponent of similar strength, a piano player typically compares themselves to the best players in the field. It's sometimes demoralizing to compare my performances of the same pieces with theirs. But it's a relief to see that no matter how I feel now, I can expect to see significant improvements in ability as I reach even the 1000-hour mark.

{% include end_matter.md %}
