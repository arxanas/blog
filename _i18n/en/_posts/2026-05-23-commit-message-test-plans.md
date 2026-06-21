---
layout: post
title: Commit message test plans
permalink: commit-message-test-plans/
tags:
  - software-engineering
  - software-verification
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Software engineers who already write test plans in commit messages or code review descriptions.</li>
        <li>People working with patch stacks or stacked diffs.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td>Private correspondence re Julio Merino's post <a href="https://blogsystem5.substack.com/p/markdown-based-test-suite">A markdown-based test suite</a>.</td>
    </tr>
    <tr>
      <td>Mood</td>
      <td>Practical.</td>
    </tr>
  </table>
</div>

* toc
{:toc}

Julio Merino recently published [_A markdown-based test suite_](https://blogsystem5.substack.com/p/markdown-based-test-suite), about using Markdown itself as a lightweight test format.

That reminded me of a related workflow I've been using for a while with [`scrut`](https://facebookincubator.github.io/scrut/): I put executable test plans directly in commit messages.

## Why

- Makes the commit message's test plan executable instead of purely descriptive.
  - Great for test-driven development, to ensure that my validation plan actually detects the underlying issue.
  - Great for knowledge sharing and onboarding teammates.
- Supports re-validating entire [commit stacks](https://www.stacking.dev/) via [`git test`][git-test].
  - Often useful when rebasing on top of upstream changes.
  - On failure, it makes it quick and easy to bisect the first broken commit.
- Supports ad-hoc and differential testing, where there is no tested correct output, and we just want to document changes.

[git-test]: https://github.com/arxanas/git-branchless/wiki/Command:-git-test

## How

Inside my commit messages, I add `scrut` code blocks with test commands to run. [Example](https://github.com/arxanas/git-branchless/commit/624edd2004015198edec6fbffbc92d3c4ce27aaf):


    fix(tests): fix tests on macOS with Git v2.37

    ...

    Test Plan
    ---------

    ```scrut
    $ cargo nextest run --workspace --no-fail-fast -- 'submodule'
    ```

I use a [small script called `git-test-message`](#script) to read the commit message and run the `scrut` tests in the repository working tree:

For individual runs, I invoke it like this:

```console
$ git test-message
🔎 Found 1 test document(s)

Result: 1 document(s) with 1 testcase(s): 1 succeeded, 0 failed and 0 skipped
```

With [`git test`][git-test], I've configured it as my default test command, which runs it on the entire stack:

```console
$ git config 'branchless.test.alias.default'
git test-message @

$ git test run
✓ Passed (cached): 624edd2 fix(tests): fix tests on macOS with Git v2.37
Ran command on 1 commit: git test-message @
1 passed, 0 failed, 0 skipped
```

### Patterns

By default, `scrut` asserts that the command exits successfully and that `stdout` matches. For some tools, especially `bazel`, `stdout` is not interesting or is non-deterministic, so I often redirect it to `stderr` so that it's not asserted, but is still logged on failure:

```scrut
$ bazel test //foo >&2
```

For ad-hoc validation, when there's no test case to cover a specific situation, I often pipe to `grep` or use `scrut`'s [output expectations](https://facebookincubator.github.io/scrut/docs/tutorial/output-expectations/):

```scrut
$ bazel run //foo | grep bar
some line with bar
```

For differential testing, I might record the new behavior, check out the previous commit, record the old behavior, and diff the two:

```scrut
$ bazel run //foo >after && git checkout HEAD~ && bazel run //bar >before && diff before after
...diff output here...
[1]
```

The `[1]` means that exit code `1` is expected from `diff`.

### Script

Here's my `git-test-message` script:

```bash
#!/bin/bash
set -euo pipefail

mise exec 'cargo:scrut' -- scrut test \
  --work-directory="${PWD}" \
  --match-markdown='*' \
  <(git show --no-patch --format='%B' "${1:-HEAD}")
```

Notes:

- My script uses [`mise`](https://mise.jdx.dev/) to just-in-time provision the `scrut` binary.
- By default, `scrut` works in a temporary directory. I oftentimes run commands that need th repo state, so I added `--work-directory=${PWD}`.
- By default, `scrut` only runs on Markdown input files. I specified `--match-markdown='*'` to match the [process substitution](https://tldp.org/LDP/abs/html/process-sub.html) filename (which usually ends up being a path like `/dev/fd/63`).
- `scrut` has features to auto-update the snapshot tests, but I haven't integrated that (since they'd have to be written back to the Git commit message).

{% include end_matter.md %}
