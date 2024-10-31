---
layout: post
title: "Stock grants as leveraged compensation"
permalink: stock-grants-as-leverage/
tags:
  - finance
  - software-engineering
---

TODO: revise below
<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td>Software engineers in big tech who get stock grants that vest over time.</td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Straightforward financial math.</li>
        <li>Experience negotiating for big tech compensation packages.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td>Observant.</td>
    </tr>
  </table>
</div>

* toc
{:toc}

## TODO: title

In big tech, it's common to get an initial compensation package that includes a fixed number of [restricted stock units](https://en.wikipedia.org/wiki/Restricted_stock) (RSUs) which vests over time.

<p class="note-block">
<span class="note-tag">Furthermore:</span>
Some big tech companies also issue "refresher" grants to current employees, either as part of normal performance review or on a case-by-case basis.
</p>

<p class="note-block note-warning">
<span class="note-tag note-warning">Not including:</span> Companies that set a fixed <em>dollar</em> amount and pay you in an equivalent number of shares upon vesting, rather than setting a fixed number of shares up-front.
</p>

<p class="note-block note-warning">
<span class="note-tag note-warning">Not including:</span> <a href="https://en.wikipedia.org/wiki/Employee_stock_option">Stock options</a> rather than RSUs.
</p>

{% aside Rationale %}

Why should a company issue RSUs as part of a compensation package rather than cash? Some reasons:

- [Deferred compensation](https://en.wikipedia.org/wiki/Deferred_compensation) acts as a retention mechanism for current employees.
  - True for both RSUs and other forms of deferred compensation.
- A company can create/issue new shares from "nothing" and set them aside for the purpose of compensating employees.
  - <span class="note-tag">If I understand correctly:</span> This dilutes existing shareholders by increasing the total number of shares in circulation, but requires their approval to institute.
  - If the stock price appreciates, then they can expend a smaller relative portion of their compensation pool.
  - Essentially, the compensation pool acts as an investment that the company is making in their own stock.
    - Perhaps you could argue this is a form of leverage by the company itself?
    - The company is "borrowing" money from existing shareholders to pay employees at a future date, when the stock price has hopefully increased.
- Expenditure of shares instead of cash is better for cash flows.
  - <span class="note-tag">At the very least:</span> It probably looks better for accounting purposes.
  - It's certainly pragmatic for non-public or otherwise illiquid companies, who may not even have access to the necessary cash.
  - Presumably it remains pragmatic for publicly-traded companies as well.
    - Payroll is a top expenditure for most companies.

{% endaside %}

One question is: what's the ideal ratio of salary to RSUs in such a compensation package? We can model the RSUs in various ways.

## Modeling as leverage

From a financial perspective, the following are similar:

<table class="note-table">
<thead>
<tr>
<td><div class="note-table-header">Getting cash</div></td>
<td><div class="note-table-header">&ldquo;Borrowing&rdquo; cash for RSU&thinsp;s</div></td>
</tr>
</thead>

<tbody>
<tr>
<td>
Being granted $100k in RSUs as part of an initial compensation package.
</td>

<td>
Borrowing $100k at a 0% interest rate and investing it in the company's stock upon joining.
<ul>
<li><span class="note-tag">Then:</span> Divesting over time as the RSUs vest.</li>
</ul>
</td>
</tr>
</tbody>
</table>

Borrowing tons of money at 0% interest is a good deal! <span class="note-inline"><span class="note-tag">At least:</span> In the current US macroeconomic environment, anyways.</span>

The decision table is straightforward based on your belief of the future stock price:

<table class="note-table">
<thead>
<tr>
<td><div class="note-table-header">Stock price will increase</div></td>
<td><div class="note-table-header">Stock price will decrease</div></td>
</tr>
</thead>

<tbody>
<tr>
<td>Ask for <em>all</em> of your compensation to be in RSUs.</td>
<td>Ask for <em>none</em> of your compensation to be in RSUs.</td>
</tr>
</tbody>
</table>

- <span class="note-tag">Assuming that:</span> The company actually pays you the agreed-upon amounts at the agreed-upon times:
  - You're not laid off or fired.
  - The company doesn't go bankrupt.
- <span class="note-tag">Assuming that:</span> The amount of cash + RSUs you receive doesn't change over time:
  - You don't get a raise, promotion, or refreshers.
  - You don't get a pay cut or demotion, and the company doesn't seize your RSUs.
    - <span class="note-tag">For example:</span> If the company gets acquired, then it might replace your RSUs with those of the acquiring company's stock, or perhaps just unvested cash installments.

The question becomes "which company is ideal to invest in" rather than "what ratio of salary to RSUs is ideal".

If we assume that stock prices remain constant, or produce an estimate of the stock price's growth rate, then we can calculate the expected value of the RSUs straightforwardly and compare.

## Modeling as options

There might be a more precise interpretation as a financial instrument.

- <span class="note-tag">In particular:</span> It's possible to leave a company at any given time and forfeit unvested RSUs, and join a company and get a fresh RSU grant at the employee's market value.
  - If the job market were perfectly liquid, then perhaps employees would do this...
  - whenever the stock's market price lowers below the original grant price,
    - as they could leave and rejoin the same company to recover their employee market value,
  - or generally any time that their employee market value is less than indicated by their unvested RSUs.
- The ability to "forfeit" RSUs vesting on a future date is somewhat similar a [European-style option](https://www.investopedia.com/terms/e/europeanoption.asp) with $0 strike price.
  - <span class="note-tag">With the additional constraint:</span> You can only hold one company's options at a time.
  - But you can sell them back to the company (for $0, by leaving your job) and buy a different company's options.

{% include end_matter.md %}
