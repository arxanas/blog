---
layout: post
title: Testing terminal user interface apps
permalink: testing-tui-apps/
tags:
  - software-engineering
  - software-verification
  - reprint
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td>Software engineers developing interactive terminal applications.</td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Work notes published internally.</li>
        <li>My experience developing several TUI applications.</li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td><ul>
        <li>Instructive.</li>
        <li>I have a lot of work notes that I'd like to publish more widely henceforth.</li>
      </ul></td>
    </tr>
  </table>
</div>

* toc
{:toc}

## Introduction

Terminal user interface (TUI) applications are

<div class="box narrow">an efficient way of surfacing data in a visual and interactive manner</div>
<div class="box narrow">while reusing significant portions of an existing program which normally prints to stdout/stderr.</div>

<p>However, bugs in TUI applications can quickly cause users to lose confidence in the visualization tools.

<span class="sidenote">This is a sidenote!</span></p>

## Primer on TTYs and PTYs

[A “TTY” is a “teletype” (or “teletypewriter”) and a “PTY” is a “pseudo-teletype” (or nowadays “pseudo-terminal”)](https://stackoverflow.com/questions/4426280/what-do-pty-and-tty-mean).

<div class="box narrow"><p>In the earliest days of Unix, users interfaced with the computer primarily via a TTY,</p>

  <div class="box narrow">but these days, the TTY is usually more of an abstraction over the terminal’s visual interface.</div>

  <p>See <a href="https://www.linusakesson.net/programming/tty/">The TTY demystified</a> for more details.</p>
</div>

The TTY abstraction is actually part of the operating system.

<div class="box narrow">The TTY devices available to programs can be found as the special files of the form <code>/dev/tty*</code>.</div>

<div class="box narrow">You can determine if a file descriptor refers to a TTY using the <a href="https://man7.org/linux/man-pages/man3/isatty.3.html"><code>isatty syscall</code></a>.

  <div class="box narrow">This function call is usually available in non-C languages, such as via Python’s <a href="https://docs.python.org/3/library/os.html?highlight=isatty#os.isatty"><code>os.isatty</code></a>.</div>

</div>

TTYs can be queried for information such as its dimensions via <a href="https://man7.org/linux/man-pages/man4/tty_ioctl.4.html"><code>ioctl</code></a>.

<div class="box narrow">It’s helpful to have a library to wrap querying and rendering to the TTY, or which offers a higher-level abstraction for the terminal UI.</div>

When running automated tests,

<div class="box">
  <p>a TTY is probably not available</p>

    <div class="box narrow">or if it is, it would be the TTY for the person who is running <code>pytest</code>, etc.</div>
    <div class="box narrow">which would not be good to use because other programs are already rendering to it.</div>

  <p>Instead, you could construct a PTY</p>

    <div class="box narrow"><a href="https://man7.org/linux/man-pages/man3/openpty.3.html"><code>with the opentty(3) syscall</code></a></div>
    <div class="box narrow">or with a higher-level library.</div>
</div>

### Escape codes

Communication with a TTY is strictly by sending and receiving bytes, so how does the program actually draw a terminal interface on the TTY? It does so by sending special escape codes, such as[ ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code). These are special sequences of bytes which can indicate things like “move the cursor to (X, Y)” or “enable bold and red coloring”.

The[ VT100](https://en.wikipedia.org/wiki/VT100) was a popular physical teletypewriter device which implemented the ANSI escape codes. You may sometimes see the ANSI escape codes referred to as VT100 escape codes.

### Terminal emulation

Since we don’t use VT100s anymore, we instead use _terminal emulators_: programs which implement the reading/writing of the TTY device and rendering on screen. The basic set of ANSI escape codes is handled by every serious terminal emulator program (Terminal.app, iTerm2, PuTTY, Alacritty, etc.). You might also say that these terminal emulators are “VT100”-compatible.

Some terminal emulators support features outside those in the ANSI escape code set. For example,[ iTerm2 can render inline pictures](https://iterm2.com/documentation-images.html) (as well as many other terminal emulators).

When we construct a PTY, we only get a bidirectional stream of bytes, not an actual picture of the screen. In automated testing, we therefore have to interpret all the escape codes and render the screen contents ourselves. To do so, we can use a terminal emulation library, such as[ pyte](https://pyte.readthedocs.io/en/latest/) for Python or[ portable-pty](https://crates.io/crates/portable-pty) for Rust. Typically, we would write a small “expect”-style framework on top of this to test the target application (see[ “Expect”-style testing](https://docs.google.com/document/d/1aitauk0xLBzI9LbbXZcczM1YluVMfY4xcanVEq9gmM0/edit#heading=h.8slxfli9jhcz)).

## Testing patterns

### Integration vs end-to-end

After having spent some time testing TUI apps, I find there are two general categories of testing:

- **Integration testing**:
  - Allows us to hook into the application event loop to inject synthetic events. Examples:
    - Execute a function and synchronously wait for it to complete.
    - Take a “screenshot” of the application at the current time.
    - Specify non-deterministic event data (such as an event that renders timing data).
  - It is highly desirable to structure such TUI apps as event-driven for testing purposes!
  - Input can be at the user level (e.g. simulate “down arrow keypress”) or at the application level (e.g. trigger “open menu X”).
    - With user-level input, the interface itself is tested more completely, but it can make it difficult to write tests which involve complicated maneuvers (e.g. “scroll down to the third item representing menu X and then press enter”), and such tests will be more brittle when the interface changes.
  - Can choose to omit or sanitize non-deterministic data from the interface if necessary (e.g. timing data).
  - Can mock out certain facilities as desired (e.g. do not trigger an actual build from the interface).
  - Allows us to redirect rendering to a “virtual canvas” instead of rendering directly to the TTY/PTY. This is not strictly necessary (see end-to-end testing approaches with a PTY) but can simplify the testing interface (no need to use a library/write complicated TTY logic; taking “screenshots” will likely be easier to implement).
- **End-to-end testing**:
  - Simulate a program under test using only normal user input methods, such as keystrokes.
  - Typically uses a PTY to simulate the interface. More discussion on TTY/PTY later.
    - Example: see[ script(1)](https://man7.org/linux/man-pages/man1/script.1.html) for a tool which simulates the terminal session and can play it back later.
  - May be difficult to prevent side-effectful operations from occurring (e.g. triggering a build from the interface).
  - May need to sanitize the screen contents to remove non-deterministic data (e.g. timing data).
  - Not possible to wait synchronously on internal operations, which requires some sort of external indication when an internal operation is complete, and tends to be flakier.

Generally speaking, integration testing will be more direct and less flaky, but end-to-end testing can be a good solution for very broad coverage of a program and to test programs which aren’t currently set up to support integration testing.

### Snapshot testing

- _NB: This style of testing is also called “golden” testing and “expect” testing, along with several other names that don’t come to mind right now._

This is a category of testing where the output from a function or program is gathered and compared to a known-good “snapshot” of that output. A “snapshot” can refer to simple textual data, structured data, or even actual snapshots of the UI of a program. Snapshot testing libraries typically come with a tool to quickly compare and update snapshot output.

- Example: the[ cargo-insta library for Rust](https://insta.rs/) implements snapshot testing.
- Example: the[ VCR.py library](https://vcrpy.readthedocs.io/en/latest/) implements snapshot testing for network requests specifically.
- Example: the[ Jest library for Javascript](https://jestjs.io/docs/snapshot-testing) implements snapshot testing.

There are several advantages to snapshot testing:

- Can be used in situations where there are multiple “correct” outputs, such as user interfaces.
- Good tooling will make it possible to quickly compare and update snapshot tests across all tests. This is important if a change to the UI affects most/all tests.
  - Good tooling will also make it possible to update multiple snapshot serial assertions in the _same_ test without failing on the first failure (which would require you to re-run the snapshot tool repeatedly until each successive snapshot is updated).
- Can be used to determine and capture the behavior of an existing system.
- Encourages program design such that components can be driven independently and their state can be dumped/examined in a meaningful way.

Snapshot testing is a better fit for testing TUIs than standard assertions, as much of the interface has functional requirements that aren’t easy to express with `assert` statements (or similar).

Some snapshot tools store the snapshots inline with the code, while others store them in separate files (or the tool may be configurable). I prefer to store my snapshots inline because I find it easier to reference them when writing or reviewing a test, but this obviously bloats the size of the test file significantly and could make it hard to navigate around the actual test code.

### “Expect”-style testing

“Expect”-style testing originally refers to the[ expect(1)](https://linux.die.net/man/1/expect) program:

> Expect is a program that "talks" to other interactive programs according to a script. Following the script, Expect knows what can be expected from a program and what the correct response should be. An interpreted language provides branching and high-level control structures to direct the dialogue. In addition, the user can take control and interact directly when desired, afterward returning control to the script.

Sometimes “expect”-style testing is used synonymously with “snapshot” testing, such as in[ Jest](https://jestjs.io/docs/snapshot-testing) or[ the expecttest Python library](https://pypi.org/project/expecttest/).

The basic structure of a program is to `send` some input, then use `expect` to wait for certain output. The `expect` may wait for a simple condition (e.g. wait until the string “Done” appears on the screen) or wait/assert the contents of the entire screen.

### End-to-end example

Here’s an example of what an expect-based test might look like for a tool which makes certain Git commits ([source](https://github.com/arxanas/git-branchless/blob/88d9be97535cb4534ccd7f5ff5436618611e1076/git-branchless-record/tests/test_record.rs#L57-L66), here is the definition of[ run_pty](https://github.com/arxanas/git-branchless/blob/88d9be97535cb4534ccd7f5ff5436618611e1076/git-branchless-testing/src/lib.rs#L816)):

```rust
    {
        run_in_pty(
            &git,
            "record",
            &["-i", "-m", "foo"],
            &[
                PtyAction::Write("f"), // expand files
                PtyAction::WaitUntilContains("contents1"),
                PtyAction::Write("q"),
            ],
        )?;
    }

    {
        // The above should not have committed anything.
        let (stdout, _stderr) = git.run(&["show"])?;
        insta::assert_snapshot!(stdout, @r###"
        commit 62fc20d2a290daea0d52bdc2ed2ad4be6491010e
        Author: Testy McTestface <test@example.com>
        Date:   Thu Oct 29 12:34:56 2020 -0100

            create test1.txt

        diff --git a/test1.txt b/test1.txt
        new file mode 100644
        index 0000000..7432a8f
        --- /dev/null
        +++ b/test1.txt
        @@ -0,0 +1 @@
        +test1 contents
        "###);
    }
```

In fact, the only two primitives for `PtyAction` are `Write` and `WaitUntilContains`. A third option could assert the contents of the entire screen. (Instead, a snapshot test of the output from `git show` is included.)

- _Tip: in your testing framework, implement a timeout for expectations and, when the timeout is exceeded, print what the test was expecting and what the screen contents actually were._

### Integration example

Here is an example of driving the internal state of a TUI program by passing a list of `Event`s in directly:

```rust
#[test]
fn test_toggle_all() -> eyre::Result<()> {
    let before = TestingScreenshot::default();
    let after = TestingScreenshot::default();
    let event_source = EventSource::testing(
        80,
        20,
        [
            Event::ExpandAll,
            before.event(),
            Event::ToggleAll,
            after.event(),
            Event::QuitAccept,
        ],
    );
    let state = example_contents();
    let recorder = Recorder::new(state, event_source);
    recorder.run()?;

    insta::assert_display_snapshot!(before, @r###"
    "[File] [Edit] [Select] [View]                                                   "
    "(~) foo/bar                                                                  (-)"
    "        ⋮                                                                       "
    "       18 this is some text                                                     "
    "       19 this is some text                                                     "
    "       20 this is some text                                                     "
    "  [~] Section 1/1                                                            [-]"
    "    [×] - before text 1                                                         "
    "    [×] - before text 2                                                         "
    "    [×] + after text 1                                                          "
    "    [ ] + after text 2                                                          "
    "       23 this is some trailing text                                            "
    "[×] baz                                                                      [-]"
    "        1 Some leading text 1                                                   "
    "        2 Some leading text 2                                                   "
    "  [×] Section 1/1                                                            [-]"
    "    [×] - before text 1                                                         "
    "    [×] - before text 2                                                         "
    "    [×] + after text 1                                                          "
    "    [×] + after text 2                                                          "
    "###);
    insta::assert_display_snapshot!(after, @r###"
    "[File] [Edit] [Select] [View]                                                   "
    "(~) foo/bar                                                                  (-)"
    "        ⋮                                                                       "
    "       18 this is some text                                                     "
    "       19 this is some text                                                     "
    "       20 this is some text                                                     "
    "  [~] Section 1/1                                                            [-]"
    "    [ ] - before text 1                                                         "
    "    [ ] - before text 2                                                         "
    "    [ ] + after text 1                                                          "
    "    [×] + after text 2                                                          "
    "       23 this is some trailing text                                            "
    "[ ] baz                                                                      [-]"
    "        1 Some leading text 1                                                   "
    "        2 Some leading text 2                                                   "
    "  [ ] Section 1/1                                                            [-]"
    "    [ ] - before text 1                                                         "
    "    [ ] - before text 2                                                         "
    "    [ ] + after text 1                                                          "
    "    [ ] + after text 2                                                          "
    "###);
    Ok(())
}
```

Notice how high-level events like “expand all” are passed to the TUI application. Implicitly, the TUI application is designed such that the “expand all” event will be fully processed and the interface will be re-rendered by the time we process the next event `after.event()` and capture the screenshot.

The entire terminal user interface, including components such as a menu bar at the top, is captured. (If the menu bar items change, then the snapshot tests will all need to be updated, which is why good tooling is so important.)

- _Tip: when comparing against a screen capture, include delimiters before and after the ends of lines (here we use the double quote character <code>"</code>) so that you can more easily compare leading and trailing whitespace, and so that editors don’t automatically strip whitespace or flag it as a warning._

{% include end_matter.md %}
