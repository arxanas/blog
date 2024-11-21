---
layout: post
title: Why LINQ syntax differs from SQL, list comprehensions, etc.
permalink: data-comprehension-syntaxes/
tags:
  - programming-languages
---

## Data comprehension syntaxes

The order of clauses in SQL is as follows:

```sql
SELECT expression
FROM data_source
WHERE condition
```

Python features a similar syntax in its list comprehensions. (In this article I
don't discuss syntax like Haskell's list comprehensions or Scala's
for-comprehensions.)

```python
expression
for item in data_source
if condition
```

You can see that these two are roughly parallel. The order of clauses is: the
expression, the data source, and then the filtering condition.

But the LINQ syntax in C# orders these clauses differently:

```cs
from data_source
where condition
select expression
```

Why is it different from the established standard? It turns out it's a
deliberate design decision by the C# team.

{% include toc.md %}

## It's a better mental model

One reason I've heard given by C# team members is that the SQL syntax doesn't
make very much sense. It might be intuitive from a natural-language standpoint,
but it fails to accurately model how we can think about the data processing.

When doing the database scan, of course we have to first identify where we are
getting data from. Then we have to scan each row and determine if it meets the
condition, and then we add some expression in terms of the row to the set of
results that we are going to return.

{% aside Not exactly %}
In practice this isn't quite accurate for SQL. We can use the result of our
expression in our filtering condition:

```sql
SELECT foo + 1 AS bar
FROM my_table
WHERE bar > 10 -- This uses the expression `bar` we computed.
```

But we can't do this in Python:

```python
foo + 1  # Can't name this expression for use in the filter...
for foo in my_table
if foo + 1 > 10  # ...so we have to recompute it.
```
{% endaside %}

It's arguably intuitive to go from more general (the entire aggregate data
source) to more specific (the exact transformations on the specific data we want
from the data source). This is reflected in how one would write out these loops
by hand:

```python
for foo in data_source:
    if foo + 1 > 10:
        yield foo
```

## It's better for tooling

One problem with the SQL syntax is that when you've written this:

```sql
SELECT f
```

you have a hard time of autocompleting the word starting with "f". It could be a
column name from any table in the database!

C# doesn't have this problem because you only write the filter and expression
after you've written the data source:

```cs
from data_source
where f // easily autocompleted

from data_source
where foo + 1 > 10
select f // likewise
```

The usefulness of autocomplete in exploratory programming shouldn't be
understated; this alone is a compelling reason to use a different order for
these clauses.

{% include end_matter.md %}
