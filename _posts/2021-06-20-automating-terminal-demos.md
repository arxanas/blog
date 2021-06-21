---
layout: post
title: Automating terminal demos
permalink: automating-terminal-demos/
tags:
  - software-engineering
---

 * toc
{:toc}

## Problem

I needed to automate a terminal demo to post in another blog article. There are several solutions for automating terminal demos, but they have some problems for my use-case:

* I want my demos to be hands-off. Most solutions are meant for live demos, and have you type to advance the script.
* I want to be able to manually adjust timings. (Reviewers of my demos have commented that I tend to go too fast.)
* I need to support interactive programs like Vim.
* I need to export something which can be embedded in a webpage.

## Solution

I used [`expect`](https://en.wikipedia.org/wiki/Expect) in combination with [`asciinema rec`](https://asciinema.org/) to meet the above requirements. The trick is to run `spawn asciinema rec` inside the `expect` script.

I've written an example `expect` script below. Note that the script displays some junk while it's running --- it looks like the demo, but it isn't. However, at the beginning of the output, a message like this is displayed:

```
asciinema: recording asciicast to /var/folders/gn/gdp9z_g968b9nx7c9lvgy8y00000gp/T/tmpcpublyyb-ascii.cast
asciinema: press <ctrl-d> or type "exit" when you're done
```

You can then pass the above path to `asciinema play` or `asciinema upload` to access the actual demo.

Script:

```tcl
#!/usr/bin/env expect -f
set timeout 1
set send_human {0.1 0.3 1 0.05 1}
set CTRLC \003

proc expect_prompt {} {
    expect "$ "
}

proc run_command {cmd} {
    send -h "$cmd"
    sleep 3
    send "\r"
    expect -timeout 1
}

proc send_keystroke_to_interactive_process {key {addl_sleep 2}} {
    send "$key"
    expect -timeout 1
    sleep $addl_sleep
}

spawn asciinema rec
expect_prompt

run_command "echo Hello, world!"
run_command "vim foo.txt"

send_keystroke_to_interactive_process "i"
send -h "Example text"
send_keystroke_to_interactive_process "$CTRLC"
send -h ":wq\r"
expect_prompt

send "exit"
```
