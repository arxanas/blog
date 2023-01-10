---
layout: post
title: "My steno system"
permalink: my-steno-system/
tags:
  - stenography
---

  * toc
{:toc}

## Introduction

The machine stenography system generally in use in the US is based off of [Ward
Ireland's original stenographic
theory](https://en.wikipedia.org/wiki/Stenotype#Chords). Each stenographer
customizes their own system. In my case, I learned the [Plover
theory](https://www.gitbook.com/book/morinted/plover-theory/details) and
customized it from there to produce my own personal theory. This post details
the changes I've made to the Plover theory to suit my own use; it may be useful
to other stenographers looking for additions to their theory.

Generally I use a theory heavy on tucking and briefs. I try to make sure that my
rules are consistent. Common words that are not consistent with my rules are
usually relegated to less convenient strokes, such as `WAO*EF` = "we've" and
"WA*EF" = "weave", or `KOU` = "could you" and `KO*U` = "cow".

## Basic phonology

### `-Z` for plurals and the present tense

Always use `-Z` and never `-S` to pluralize words, or to turn them into the
present tense. With the default dictionary, I've found that I can't reliably
tuck `-S` into words to add the -s ending; for example, "days" versus
"daze" or "gross" versus "grows" cause issues frequently.

The exception is for words that end with `-T`. In those cases, I still use `-S`
to pluralize them, since `-TZ` is impossible to stroke in some cases, and `-TS`
is unlikely to conflict with other words.

For words ending in `-aze` I sometimes use the `AEZ` ending, which allows me to
use `A*EZ` for the `-azy` variant. For example, `LAEZ` = "laze" and `LA*EZ` =
"lazy" or `HAEZ` = "haze" and `HA*EZ` = "hazy".

Implementing this change in the default dictionary takes a decent amount of
effort, but I've found the addition in consistency has made it well worth it.

I typically use `-SZ` for the plural of words ending in the -s sound, such as
"races", and don't use `-FZ` for that purpose.

### `*S` for the final 'z' sound

Some word pairs require disambiguation between the -s and -z variants, which I
didn't find adequately addressed in default dictionary. This also helps with
pluralizing words that end with the 'z' sound. Some examples:

* race, races, raise, raises, raze, razes, rays
* cease, sees, seas, seize
* rice, rices, rise, rises, ryes
* rose, roses, rows
* sighs, size

I use `*S` for the -s variants and `-Z` for the plural variants, keeping in mind
steno order for the plural versions:

* `RAIS` = "race", `RAISZ` = "races", `RA*IS` = "raise", `RA*ISZ` = "raises",
  `RAEZ` = "raze" (as per the previous section), `RAEZ/-Z` = "razes", `RAIZ` =
  "rays"
* `SAOES` = "cease", `SAOEZ` = "sees", `SAEZ` = "seas", `SAO*ES` = "seize"
* `RAOIS` = "rice", `RAOISZ` = "rices", `RAO*IS` = "rise", `RAO*ISZ` = "rises",
  `RAOIZ` = "ryes"
* `RO*ES` = "rose", `RO*ESZ` = "roses", `ROEZ` = "rows"
* `SAOIZ` = "sighs", `SAO*IS` = "size"

### `*F` for the 'v' sound

I always use `*F` for the 'v' sound to avoid having to figure out when `-F`
works, and when I need to use `*F` to disambiguate it.

### `N*` for kn-

Disambiguating "knows" from "nose" from "nos" or "new" versus "knew" is a pain,
and I don't like how the default Plover dictionary uses `O` for one and `OE` for
other, because I would prefer to use the long vowel sound explicitly, as per the
next section. Instead, I use `N*` to indicate that there's a silent letter:

* `NOE` = "no", `N*OE` = "know"
* `NIT` = "nit", `N*IT` = "knit"
* `NAO*IF` = "knife", `NAO*IFS` = "knifes", `NAO*IFZ` = "knives"

### Prefer explicit long vowels: `AI` over `A`, `AOE` over `E`

The Plover theory sometimes uses lone vowels over long vowels. I usually prefer
to use the long vowels, even though they require more keys.

Some examples:

* `HAOE` = "he", `SHAOE` = "she", and `WAOE` = "we"
  * Note that `HAOE*L` = "he'll" and `HAOEL` = "heel", according to the
    apostrophe rule below.
  * Note that `WAOE*F` = "we've" according to the apostrophe rule, and
    consequently `WAOEF` = "weave". This isn't ideal, but I don't write "weave"
    very often.
* `SAIF` = "safe" and `SA*IF` = "save" (instead of `SAIF` = "safe" and `SAF` =
  "save")
* `WA*IF` = "wave" (instead of `WAF` = "wave" or `WA*F` = "wave")
  * Since "wave" is used much more frequently than "waive", I've relegated
    `WAIF` = "waive".
  * I've removed "waif" from my dictionary since I've never used it. [Reckless? Maybe.](http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=222111&type=card)
*

One exception is for prefix strokes: I still use `RE-` = "{re^}" and `PRO-` =
"{pro^}", for example. This helps to disambiguate between the prefix and the
full form, such as `PRO-` = "{pro^}" versus `PROE` = "pro", and I also don't
want to go change all the existing entries in the dictionary.

### Prefer `-BGS` for 'x' and `*BGS` for 'kshun' in the event of conflicts

For word pairs like "reflex" and "reflection"or "fax" and "faction", I
disambiguate them using `-BGS` and `*BGS` correspondingly; for example,
`RE/FLEBGS` = "reflex" and `RE/FL*BGS` = "reflection". When there is no
conflict, I write `-BGS` for "kshun".

Since I pluralize all my words with `-Z`, I don't have conflicts for word pairs
like "traction" and "tracks" or "suction" and "sucks", since I write
`TRABGS` = "traction" and `TRABGZ` = "tracks".

## Tucking

I usually *tuck* letters into my words to add affixes when it's possible to do
so in one stroke. Plover will handle most of these affixes use the orthographic
rules, which means that I don't have to have a special entry for the affixed
form. For example, you can add `-G` to `TPAO` = "foo" and get "fooing", even
though "fooing" isn't an explicit word in the dictionary.

I tuck these whenever possible:

* `-G` = "{^ing}".
* `-D` = "{^ed}". This includes in words that end with `-T`, such as `PLANTD` =
  "planted". It took a while to get used to writing `-TD` but it's second nature
  now. I don't usually use the so-called "Philly shift", in which I shift over
  my right hand, to write out words ending in `-SD` (such as `SPO*ESD` =
  "supposed") in one stroke.
* I use `-Z` to add -s and -es, as discussed in depth previously.
* `-L` or `L-` for -al, -ly or -ally. This is not an orthographic rule in the
  Plover dictionary, which means that I have to add it for each individual word.
  It largely depends on which one feels more comfortable to determine which I
  add to a word. Examples:
    * `BAIFK` = "basic", `BLAIFK` = "basically"
    * `FUNGS` = "function", `FUNLGS` = "functional", `FLUNLGS` = "functionally"
    * `F*UL` = "fundamental" (brief), `FL*UL` = "fundamentally"
    * `SKES` = "success", `SKEFL` = "successful", `SKLEFL` = "successfully"

## Additional phonology

### `SN-` for ins-, inst-

There are a few examples in the default Plover dictionary already, but it's not
a consistent theme. Some examples:

* `SNERT` = "insert", `SNERGS` = "insertion"
* `SNANT` = "instant", `SNANS` = "instance", `SNANGS` = "instantiation"
  (programming term), `SNAINS` = "instantaneous", `SNAINLS` = "instantaneously"
* `SNRUMT` = "instrument", `SNRUL` = "instrumental"
* `SNRUKT` = "instruct", `SNRUGS` = "instruction"

### `WR-` for rev-

`WR-` isn't used for many words ordinarily, so it's a good candidate for use in
briefing. Some examples:

* `WRAO*IS` = "revise", `WRIGS` = "revision"
  * Note that I use `*S` for the trailing 'z' sound.
* `WRERT` = "revert", `WRERS` = "reverse", `WRERGS` = "reversion"
* `WRAOU` = "review"

### `SK*` for ex-, exc-

The default dictionary uses `KP-` for some uses of ex-, but I didn't like that
it conflicted, such as "exact" versus "compact".

The other commonly-used prefix is `SKP-` for ex-. I was a bit worried about
whether it would conflict with my brief system, since `SKP-` is the
phrase-beginner for "and". I don't know if it does conflict, but `SK*` works for
me, so I haven't tried it the other way.

For `ext-` endings, I use `STK*`.

Some examples:

* `SKA*FRPL` = "example"
* `SK*AKT` = "exact"
  * I actually still use `ELG` = "exactly", but `SKL*AKT` = "exactly" would be
    reasonable too.
* `SK*ES` = "excess", `SK*EF` = "excessive", `SK*EFL` = "excessively"
* `SK*EPT` = "except", `SK*EPGS` = "exception"
* `SKP*EKT` = "expect", `SKP*EBGS` = "expectation"
* `SKLAO*UD` = "exclude", `SKLAO*UGS` = "exclusion", `SKLAO*UF` = "exclusive"
* `SKPR*ES` = "express", `SKPR*EGS` = "expression", `SKPR*EBL` = "expressible",
  `SKPR*EF` = "expressive", `SKPR*EFT` = "expressivity", `SKPR*EFNS` =
  "expressiveness"
  * All of these terms come up frequently when discussing programming languages.
* `SKPO*ENT` = "exponent", `SKPO*ENLT`/`SKP*ENL` = "exponential",
  `SKPLO*ENLT`/`SKPL*ENL` = "exponentially"
  * You could say it's exponentially easier than writing out "exponentially" in
    five strokes!
* `STK*ENT` = "extent", `STK*END` = `extend`, `STK*EF` = "extensive", `STK*EFL`
  = "extensively", `STK*ENL` = "extensible", `STK*ENLT` = "extensibility"

### `KP-` for acc-

To distinguish ex- from acc-, I use KP- for the latter instead.

* `KPEPT` = "accept"
* `KPENT` = "accent"
* `KPEBL` = "accessible", `KPEBLT` = "accessibility"

### `SPW-` for int-, ent-, inc-, enc-

Magnum uses `SPW` for int- and ent-. It also uses it for ind- and end-; however,
I use it for inc- and enc- instead. I haven't found any significant conflicts
(the worst being "entrust" versus "encrust"). Some examples:

* `SPW-` = "int" (programming term: abbreviation of "integer"), `SPWERJ` =
  "integer"
* `SPWUPGS` = "interruption"
* `SPWRAL` = "integral", `SPWRAIT` = "integrate", `SPWRAIGS` = "integration"
  * This one is a bit of a stretch but I haven't found any conflicts.
* `SPWERT` = "interpret", `SPWRERT` = "interpreter", `SPWERPGS` =
  "interpretation"
  * In "interpreter", I tuck an `R-` in for the -er ending. This entry could
    also be `SPWRET`/`SPWRERT`/`SPWRAIGS` without issue, I think.
* `SPWLEKT` = "intellect"
* `SPWRAIMT` = "entertainment"
  * There is also the word "entrainment", but I've never used it.
* `SPWREMT` = "increment", `SPWREL` = "incremental", `SPWLEL` = "incrementally"
* `SPWLEMT` = "inclement"
* `SPWRIPTD` = "encrypted"
* `SPWLO*ES` = "enclose", `SPWLO*URS` = "enclosure"
  * Note that I use `*S` for the trailing 'z' sound.

### `KPW-` for imp-, emp- imb-, emb-

Some examples:

* `KPWLEMT` = "implement", `KPWLEMGS` = "implementation"
* `KPWAIR` = "impair", `KPWAIRMT` = "impairment"
* `KPWOI` = "employ", `KPWO*I` = "employee", `KPWOIMT` = "employment"
* `KPWAOU` = "imbue"
* `KPWARS` = "embarrass", `KPWARMT` = "embarrassment"
  * Ordinarily I would use `AI` for the long 'a' sound, but then "embarrassment"
    would conflict with "impairment". I had already learned `EM/BARS` =
    "embarrass" from the default dictionary, so `KPWARS` stuck.
* `KPWED` = "embed"
* `KPWLEM` = "emblem"

### `STW-` for inv-, env-, inf-, enf-

Some examples:

* `STWERT` = "invert", `STWERGS` = "inversion"
* `STWAOIT` = "invite", `STWI/TAIGS` = "invitation"
  * Note that "invitation" has to avoid conflicting with `STWIGS` = "envision"
    and `STWAIGS` = "invasion".
* `STW-` = "env" (programming term: abbreviation of "environment"), `STWAOIRMT`
  = "environment", `STWAOIRL` = "environmental"
* `STWAIRNT` = "invariant", `STWAIRNS` = "invariance" (programming term)
* `STWORS` = "enforce", `STWORMT` = "enforcement", `STWO*RMT` = "informant"

### `-FR` for the 'm' sound

There are a few sounds like -mp ("clamp", "dump", etc.) or -mb ("bomb", "climb")
which don't have direct equivalents in the Plover theory. Usually `*M` or `-M`
are written instead. However, this prevents attaching additional letters,
specifically `-L`, to the stroke. In these cases, I use `-FR`:

* `KLAFRP` = "clamp"
* `SIFRPL` = "simple"
* `BOFRB` = "bomb"
* `RUFRBL` = "rumble"

### `-F` for various -ive endings

This convention exists to some degree in the default Plover dictionary, so I've
extended it.

* `SKES` = "success", `SKEF` = "successive"
* `SPWRAKT` = "interact", `SPWRAF` = "interactive"
* `STK*END` = "extend", `STK*EF` = "extensive"

### `*IK` for -ic

In line with my suffixes-use-asterisks rule below, and to avoid conflict with
`IK` = "I can" in my brief system, I use `*IK` instead:

* `MAJ/*IK` = "magic"
* `LOJ/*IK` = "logic"

### `AUB` for ob-

Similar to `AUP` for up-, I use `AUB` for words starting with `ob-`:

* `AUB/STRUKT` = "obstruct", `AUB/STRUBGS` = "obstruction"
* `AUB/LAOEK` = "oblique"
* `AUB/LONG` = "oblong"
* `AUB/TRAOUD` = "obtrude", `AUB/TRAOUF` = "obtrusive"

### `-EFK` for -estic and `-IFK` for -istic

For words that end in -stic, I usually manage to skip using `ST-K` = "{^istic}"
or `*IK` = "{^ic}" by adding `-EFK` or `-IFK` to the last syllable. For example

* `MA/JEFK` = "majestic"
* `OPT/MIFK` = "optimistic", `PES/MIFK` = "pessimistic"

## Orthography

### Use asterisks for apostrophes in contractions

I always add `*` to strokes for words that have apostrophes. For example:

* `LETS` = "lets", `L*ETS` = "let's"
* `DO*ENT` = "don't"
* `D*INT` = "didn't"
* `THA*L` = "that'll"
  * Note that `THAL` = "that will".
* `WAO*EF` = "we've"
* `HAOE*L` = "he'll"
  * Note that `HAOEL` = "heel".

This interacts well with my brief system, described later.

### Duplicate strokes to expand abbreviations

For abbreviations and acronyms, I write the stroke once to indicate the
abbreviated form, and then again to indicate the full form. For example, `U*S` =
"US" and `U*S/U*S` = "United States" or `GATD` = "GADT" and `GATD/GATD` =
"generalized algebraic data type".

### Single-stroke proper nouns use asterisks

Usually, proper nouns use asterisks, such as `JO*N` = "John". When this can't be
done, I duplicate the stroke, such as `MAT/MAT` = "Matt" (since `MA*T` =
"math"). Usually neither of these are necessary for proper nouns that are more
than one stroke, such as `KA*T/RIN` = "Catherine".

### Short vowels for foreign names and loan-words

Foreign words don't usually follow the phonological patterns of English, so it
can be hard to remember what rules I apply for briefing them.

In addition to any briefed forms, I introduce a canonical form that follows the
orthography of the original word so that I always know one valid way to spell
it. Usually each of these syllables is consonant-vowel when possible, or
consonant-vowel-consonant otherwise. For example:

* `HI/KA/RU NA/KA/MU/RA` = "Hikaru Nakamura"
* `GAR/RI KAS/PA/RO*F` = "Garry Kasparov" (rather than `KAS/PAR/O*F` = "Kasparov")
* `KI/MO/NO` = "kimono"
* `SU/SHI` = "sushi"
* `PAT/S*ER` = "patzer" (rather than `PA*TS/*ER` = "patzer")

### Asterisks for suffixes and compound words

I always like to use an asterisk whenever I'm attaching a segment to what is
already a valid word, in order to avoid word boundary issues. For example:

* `WA*I` = "{^way}", such as in `HAOI/WA*I` = "highway"
* `TAO*IM` = "{^time}", such as in `RAEL/TAO*IM` = "realtime"
* `TRAID/MA*RK` = "trademark"

For suffixes, I prefer not to include a hyphen in the definition (that is,
prefer "{^time}" over "{^-time}"), and either add a hyphen when I need it, or
special-case certain words that expect the hyphen.

## Briefing

In general, I never use a stroke as a brief when that stroke itself represents a
word, no matter how uncommon. For example, the Plover default dictionary defines
a few briefs:

* `NUM` = "number", `NU*M` = "numb"
* `FIG` = "figure", `F*IG` = "fig"
* `MED` = "medicine", `M*ED` = "med"
* `MIN` = "minute", `M*IN` = "min"

I don't like to do this. My philosophy is: if it's a brief, and has to be
memorized anyways, then we might as well pick a non-conflicting stroke for it.
This way you don't have to worry about whether an asterisk has to be added for
the word you want to type because it's a brief for another word.

My strokes for the above are:

* `NURM` = "number", `NUM` = "num", `N*UM` or `NUMB` = "numb"
* `FIRG` = "figure", `FIG` = "fig"
* `M*ED`, `MED/SIN`, or `MED/S*IN` = "medicine", `MED` = "med"
* `M*INT` = "minute", `MIN` = "min"

This is my order of preference for these common briefing patterns, with the
first entries being more desirable:

* Pick a sound and add an asterisk to it, ensuring that it doesn't conflict with
  anything.
* Remove the vowel from the brief.
* Pick a sound without an asterisk.

If I were to do it over, I would probably add asterisks to the above strokes as
well (e.g. `N*URM` = "number").

## My brief system

I have one large brief system that I use to abbreviate phrases. This system only
works for the subjects "I" and "you", which means that it's most appropriate for
holding conversations with other people, or transcribing conversations between
people. Fortunately, in English, "you" can also be a third-person pronoun in the
same way as "one", which makes the brief system more widely applicable.

### Installation

This brief system is implemented as a "Python dictionary". This allows the
dictionary definition to be implemented as code, which means that it can
automatically generate every combination of prefixes and suffixes and so on. You
need Plover 4.0 with its plugin manager and [the Python dictionary
plugin](https://pypi.org/project/plover-python-dictionary/) to use it.

To install this system, first install the Python dictionary plugin above, then
[download the source code
here](https://gist.github.com/arxanas/ab337490bf204ed81b5e9d7d3417fa8a) (you can
do this by clicking "Download ZIP" and decompressing the ZIP file). Then go into
Plover's main view and click the add-dictionary button and select the
`multiword_briefs.py` file that you downloaded/extracted previously.

### The subjects

Easy:

* `I` = "I"
* `U` = "you"

You can also omit the subject altogether if you don't need one, such as for a
short phrase like "that haven't".

### The right-hand phrase enders

These can be combined with a subject to produce a two-word phrase. For example,
`UF` = "you have", or "IKT" = "I can't".

* `*D` = "{^'d'}"
* `*L` = "{^'ll'}"
* `*M` = "{^'m}" (only for "I")
* `*R` = "{^'re}" (only for no subject or "you")
* `-B` = "be"
* `-K` = "can"
* `-KD` = "could"
* `*KT` = "couldn't"
* `*NT` = "didn't"
* `-NT` = "don't"
* `*FN` = "even"
* `*FR` = "ever"
* `-RBGT` = "get"
* `*RBGT` = "got" ("get" and "got" are a bit arbitrary. I originally used just
  `-GT` and `*G`, but this conflicted with words where you tucked `-G`, such as
 `SHOUGT` = "should you get"/"shouting". So I added some other letters to make
 it not conflict.)
* `-D` = "had"
* `-F` = "have"
* `-FT` = "have the"
* `-FNT` = "haven't"
* `-J` = "know" (mostly arbitrary, there was some brief in the Plover dictionary
  that use it, so I kept it)
* `*J` = "knew"
* `*PBL` = "mean"
* `-PLT` = "might"
* `*PBD` = "need"
* `-PBL` = "only"
* `*RL` = "really"
* `-RBD` = "should"
* `*RBT` = "shouldn't"
* `-PBG` = "think"
* `-RPBD` = "understand"
* `*RPBD` = "understood"
* `-PT` = "want"
* `-FS` = "was" (only for no subject or "I")
* `*FBT` = "wasn't" (only for no subject or "I")
* `-RP` = "were"
* `*RPT` = "weren't"
* `-L` = "will"
* `-FBT` = "won't"
* `-LD` = "would"
* `*LT` = "wouldn't"

### The left-hand phrase beginners

These start phrases, and can be combined with a subject or right-hand phrase
ender. There's a lot of overlap in these entries, such as `STWHAO` = "so that
you don't" being a combination of `SW-` = "so", `TH-` = "that", and `AO` = "you
don't", but it's regular and predictable.

* `SKP-` = "and" (standard Plover theory)
* `SKPO-` = "and I don't"
* `SKPAO-` = "and you don't"
* `STKP-` = "and if"
* `STKPO-` = "and if I don't"
* `STKPAO-` = "and if you don't"
* `K-` = "can"
* `KO-` = "could"
* `TK-` = "did"
* `TKO-` = "do"
* `SR-` = "have"
* `KWRO` = "I don't"
* `KWRAO` = "you don't"
* `STP` = "if" (just `TP-` conflicts with things, such as `FUR` = "fur" versus
  "if you are")
* `STPO` = "if I don't"
* `STPAO` = "if you don't"
* `STHA` = "is that"
* `SWHA` = "is what"
* `STHO` = "is that I don't"
* `STHAO` = "is that you don't"
* `SHO` = "should"
* `SW` = "so"
* `SWO` = "so I don't"
* `SWAO` = "so you don't"
* `STPW` = "so if"
* `STPWO` = "so if I don't"
* `STPWAO` = "so if you don't"
* `STWHA` = "so that"
* `STWHO` = "so that I don't"
* `STWHAO` = "so that you don't"
* `SWHA` = "so what"
* `THA` = "that"
* `THAO` = "that you don't"
* `THO` = "that I don't"
* `WHA` = "what"
* `WHO` = "what I don't"
* `WHAO` = "what you don't"
* `WO` = "would"

### Putting it together

Combining these phrase-beginners and phrase-enders allows me to write common but
reasonably-long phrases in one stroke:

* `STHOPT` = "is that I don't want" (such as in "the reason I didn't do that is
  that I don't want X to happen...")
* `STWHAOF` = "so that you don't have" (such as in "the reason I did that is so
  that you don't have to do X...").

At the same time, it can be used for much smaller phrases:

* `THALD` = "that would"
* `THAIRBD` = "that I should"
* `UKD` = "you could"

My brief system was accumulated over time, so if you decide to use a similar
system, it might be best to build up the phrase beginners and phrase enders as
you find you need them, rather than try to learn them all at once.

{% include end_matter.md %}
