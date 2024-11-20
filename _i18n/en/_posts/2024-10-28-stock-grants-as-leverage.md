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

## Executive summary

I haven't seen this written down: getting more RSUs is like borrowing money at a 0% interest rate, which is a great deal. <span class="note-tag note-warning">However:</span> It's probably unsuitable for people who have lower risk tolerances or are relying on stable cash flows.

{% noteblock note-error %}
<span class="note-tag note-error">Note:</span> I am not a financial advisor, and this does not constitute financial advice. In fact, I am not particularly knowledgeable about finance in the first place 🙃.
{% endnoteblock %}

## Background

In big tech, it's common to get an initial compensation package that includes a fixed number of [restricted stock units](https://en.wikipedia.org/wiki/Restricted_stock) (RSUs) which vests over time.

Supposing that you're negotiating a compensation package with a company, one question is: what's the ideal ratio of salary to RSUs?

This article is an exploration of straightforward idea which I haven't seen explicitly expressed anywhere: you could consider RSUs as a form of [financial leverage](https://en.wikipedia.org/wiki/Leverage_(finance)), in which you borrow money to make an investment.

{% noteblock note-info %}
<span class="note-tag">Furthermore:</span> Some big tech companies also issue "refresher" stock grants to current employees, either as part of normal performance review or on a case-by-case basis.
{% endnoteblock %}

{% noteblock note-warning %}
<span class="note-tag note-warning">Not including:</span> Companies that set a fixed *dollar* amount and pay you in an equivalent number of shares upon vesting, rather than setting a fixed number of shares up-front.
{% endnoteblock %}

{% noteblock note-warning %}
<span class="note-tag note-warning">Not including:</span> [Stock options](https://en.wikipedia.org/wiki/Employee_stock_option) rather than RSUs.
{% endnoteblock %}

{% aside Rationale for issuing stock grants %}

Why should a company issue RSUs as part of a compensation package rather than cash? Some reasons:

- [Deferred compensation](https://en.wikipedia.org/wiki/Deferred_compensation) acts as a retention mechanism for current employees.
  - True for both RSUs and other forms of deferred compensation.
- A company can create/issue new shares from "nothing" and set them aside for the purpose of compensating employees.
  - <span class="note-tag note-warning">If I understand correctly:</span> This dilutes existing shareholders by increasing the total number of shares in circulation, but requires shareholder approval to institute, so they know what they're getting into.
  - <span class="note-tag">Hopefully:</span> If the stock price appreciates, then the company can expend a smaller relative portion of its compensation pool.
  - <span class="note-tag">Essentially:</span> This compensation pool acts as an investment that the company is making in their own stock.
    - <span class="note-tag">Perhaps:</span> You could argue this is a form of leverage by the company itself?
    - <span class="note-tag">Namely:</span> The company is "borrowing" money from existing shareholders to pay employees at a future date, when the stock price has hopefully increased and they can profit from the relative difference.
- Expenditure of shares instead of cash is better for cash flows.
  - <span class="note-tag">At the very least:</span> It probably looks better for accounting purposes.
  - <span class="note-tag">Certainly:</span> It's pragmatic for non-public or otherwise illiquid companies, who may not even have access to the necessary cash.
  - <span class="note-tag">Therefore:</span> Presumably it remains pragmatic for publicly-traded companies as well?
    - <span class="note-tag">After all:</span> Payroll is a top expenditure for most companies.

{% endaside %}

## Assumptions

For simplicity, here's some assumptions:

- <span class="note-tag">Assuming that:</span> The company actually pays you the agreed-upon amounts at the agreed-upon times:
  - You're not laid off or fired.
  - The company doesn't go bankrupt.
- <span class="note-tag">Assuming that:</span> The amount of cash + RSUs you receive doesn't change over time:
  - You don't get a raise, promotion, or "refresher" stock grants.
  - You don't get a pay cut or demotion, and the company doesn't seize your RSUs.
    - <span class="note-tag">For example:</span> If the company gets acquired, then it might replace your RSUs with those of the acquiring company's stock, or perhaps just unvested cash installments.

## Models

### Modeling as leverage

Unlike salary, the invested RSUs have the chance to appreciate in value over time. That is, from a financial perspective, the following behaviors share some similarities:

- **Getting RSUs**: Being granted $100k of (future-vesting) RSUs upon joining the company.
- **Borrowing cash to buy RSUs**: Borrowing $100k at a 0% interest rate and investing it in $100k of RSUs upon joining the company.
  - <span class="note-tag">In general:</span> You have to pay back borrowed money. When we model it this way, the difference between RSUs and the equivalent salary would represent the *relative* profit or loss from this investment strategy, compared to the alternative of negotiating for more salary.
- **Getting a sign-on bonus to buy RSUs**: Receiving a $100k sign-on bonus upon joining the company, and immediately investing it in $100k of RSUs.
  - Getting the same amount of cash up-front instead of vesting over a period of time is generally better, but I usually can't convince companies to do this for me 😭. <span class="note-inline"><span class="note-tag">Excepting:</span> Negative interest rate and negative return rate environments.</span>

{% aside Tax implications %}

For completeness, I'll discuss the general US tax implications of the above, although they're not the main point. <span class="note-inline note-warning"><span class="note-tag note-warning">Note:</span> I am not a tax professional and this is not tax advice.</span>

- When receiving salaries and when RSUs *vest*, they're [taxed at income tax rates](https://en.wikipedia.org/wiki/Income_tax_in_the_United_States).
  - <span class="note-tag">Considered:</span> Generally unfavorable.
  - <span class="note-tag note-warning">Note:</span> It's a common misunderstanding that RSUs vesting in this way are subject to capital gains tax rates rather than income tax rates.
- When selling stock, the *difference* in price from the time you acquired them is [taxed at capital gains rates](https://en.wikipedia.org/wiki/Capital_gains_tax_in_the_United_States).
  - <span class="note-tag">Considered:</span> Generally favorable.
  - <span class="note-tag note-warning">Note:</span> "Acquisition" refers to either buying them or vesting them, but not the initial grant itself.
- When vesting and immediately selling RSUs, you may realize a small capital gain or loss due to market fluctuations between the vest and sell time.
  - <span class="note-tag">Considered</span> Generally neutral, if executed promptly so that the difference is small.
  - <span class="note-tag note-warning">However:</span> It may incidentally trigger [wash sale rules](https://en.wikipedia.org/wiki/Wash_sale), depending on your other trading activity.
    - <span class="note-tag">Considered:</span> Generally neutral.
    - <span class="note-tag">Also considered:</span> Generally <span class="note-tag note-error">annoying</span> when filing your taxes.
  - <span class="note-tag note-warning">Note:</span> Some states in the US may levy additional taxes on RSU grants.
    - <span class="note-tag">Particularly:</span> California and New York?
- When borrowing cash for investment, the cash itself is not taxable.
  - The interest paid to borrow money may be tax-deductible (the "Investment Interest Expense Deduction").
    - <span class="note-tag">Considered:</span> Generally favorable.
  - When selling the investments, the previous points apply.

{% endaside %}

I, for one, don't usually have the opportunity to borrow tons of money at 0% interest rates. Typically, that's considered a great deal! <span class="note-inline"><span class="note-tag">At least:</span> In the current US macroeconomic environment.</span>

#### Calculation

It's easy enough that it barely merits mentioning.

Supposing these rates of return:

- **Cash**: 0%, as discussed in [Assumptions](#assumptions).
  - <span class="note-tag">See also:</span> Since salary vests more often than stock, see [Modeling as futures contracts](#modeling-as-futures-contracts) to account for the [time value of money](https://en.wikipedia.org/wiki/Time_value_of_money).
- **Stock**: 5%, which is roughly the historical value for the US market rate of return.
  - <span class="note-tag note-warning">However:</span> It's very unlikely to be the rate of return for any individual stock. See [Modeling as options](#modeling-as-options) for a brief discussion of valuing volatility.

Then, if you can choose between:

- **Salary**: Earning $100k this year in salary.
- **RSUs**: Being granted $100k of RSUs that vests at the end of this year.

Then the expected value of the cash is $100k, while the expecte value of the RSUs is $105k, yielding a $5k relative profit, so you should choose the RSUs.

- <span class="note-tag">Furthermore:</span> If your RSUs vest over a longer period of time, you can extrapolate into the future and compound the expected rate of return, for a more substantial profit in subsequent years.
- <span class="note-tag">Obviously:</span> If your expected rate of return is negative for the stock in question, then you should try to minimize your exposure to it.

The interesting thing is that the "benchmark" is not the [risk-free interest rate](https://en.wikipedia.org/wiki/Risk-free_rate) or the [market rate of return](https://en.wikipedia.org/wiki/Alpha_(finance)), but the alternative up-front choice of receiving more salary in the future, which we often expect to be low.

#### Practical analysis

Main benefits:

- You can make an investment with "borrowed" money that you couldn't make with the same amount of future-earned salary.
- The benchmark is substantially more lax than for typical trading strategies, so you can profit more easily.
- You could argue that this serves as a [hedge](https://en.wikipedia.org/wiki/Hedge_(finance)) against a stagnating future salary.

Main risks:

- It is quite difficult for an untrained individual to make a reasonable valuation for a given stock.
  - <span class="note-tag">After all:</span> If they were trained to do so, perhaps they would be working in finance and not be compensated with RSUs anyways.
- Even if the fundamentals are assessed correctly, the stock price itself can be quite volatile.
  - This is primarily a problem for individuals who have fixed debt and need to raise certain amounts of cash periodically.

### Modeling as futures contracts

TODO: more similar to a forwards contract than a future, because we don't need to settle up the difference periodically

The other interesting financial aspect of RSU grants is that they represent [futures contracts](https://en.wikipedia.org/wiki/Futures_contract) on compensation in your up-front choice of cash or stock.

- <span class="note-tag">Presently:</span> At most companies in big tech, your regular paycheck is typically paid more frequently (perhaps biweekly) than your RSUs vest (perhaps quarterly).
  - But the differential is significantly less than the multi-year overall vesting period of RSUs.

### Modeling as options

TODO: delete this section

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
