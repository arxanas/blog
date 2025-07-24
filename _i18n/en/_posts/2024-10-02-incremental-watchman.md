---
layout: post
title: "Incremental processing with Watchman — don't daemonize that build!"
permalink: incremental-watchman/
tags:
  - build-systems
  - reprint
  - software-engineering
---

<div class="publication-notes">
  <table>
    <tr>
      <td>Intended audience</td>
      <td><ul>
        <li>Build system developers and enthusiasts</li>
        <li>Developers of tooling that doesn't fit into the build system</li>
      </ul></td>
    </tr>
    <tr>
      <td>Origin</td>
      <td><ul>
        <li>Lessons synthesized from 8-year career in incremental computation and build systems</li>
        <li>Originally presented at <a href="https://groups.io/g/Seattle-Build-Enthusiasts/topic/seattle_build_enthusiast/108248211">Seattle Build Enthusiasts Meetup (Fall 2024)</a></li>
      </ul></td>
    </tr>
    <tr>
      <td>Mood</td>
      <td><ul>
        <li>Instructive</li>
        <li>Passionate that people should avoid my mistakes</li>
      </ul></td>
    </tr>
  </table>
</div>

{% include toc.md %}

## Slides

This talk was given at the [Seattle Build Enthusiasts Fall 2024 meetup](https://groups.io/g/Seattle-Build-Enthusiasts/topic/seattle_build_enthusiast/108248211) (<time datetime="2024-10-02">2024-10-02</time>).

- Deleted slides with extra information are available at the end.
- Direct Google Slides link: <https://docs.google.com/presentation/d/1geE7rGTCpIk5UTjH-sw9aL_Zszi1ncCRnFi55t0CDlk/>

<div class="iframe-container">
<iframe src="https://docs.google.com/presentation/d/e/2PACX-1vRSwp0EbldxIkD72bzEoKDHzLzah95w2ABa1doSwqeKTMneSz1_O1DqNNb7qJCi4xXbPdp1A7Blk5PV/embed?start=false&loop=false&delayms=3000" frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>
</div>

## Speaker notes

I've transcribed the speaker notes below, which correspond to the intended transcript.

---

(1) Hi everyone, thanks for attending. My name is Waleed Khan and today I'll talking about building incremental systems on top of the Watchman file-watching service.

(2) If you want to follow along with the slides at your own pace, you should take this opportunity to open them up now. You can visit my website waleedkhan.name and you can navigate to the blog post with these slides.

(2) A little about me: I used to work at Meta on the Hack programming language, and Twitter on their Scala build tooling, as well as source control. Most recently, I've been working at Hudson River Trading on their C++ and Python build system.

(2) My career has been spent shortening the developer feedback loop, largely by implementing custom incremental build systems. Watchman is an open-source file-watching tool that can be used as a high-level primitive for those kinds of incremental systems. In this talk, I'd like to share some design ideas for implementing similar incremental build systems.

(3) There's two parts to this talk.

(3) In the first part, I'll talk about the justification for Watchman, the problems it solves, and the abstractions it offers.

(3) In the second part, I'll just be listing several helpful tips and pieces of advice for implementing systems on top of Watchman.

(4) Let's give an example of what kind of problems might be solved by Watchman.

(5) I mentioned I've spent a lot of time working on custom incremental build tooling. When would you need that? I'll give a few examples that I've personally used Watchman for in order to implement custom incremental build systems.

(5) One example is file syncing. A lot of companies have been embracing "remote development" workflows, by which I mean your code is sent from your local machine to be compiled and run on a remote machine somewhere else. Many companies have invented solutions to sync your local source code to the remote machine as part of the development process. File syncing may be outside the scope of your build system, or it may just not be integrated yet.

(5) Another example is dynamic dependencies in the build system. Many companies have Bazel, but those kind of build systems may not be able to express certain kinds of dynamic dependencies. For Bazel, there's a tool called "Gazelle" which is used to programmatically generate BUILD files, which are then read by Bazel in the next build. There may be some fans of the buck2 build system in the audience who scoff at this, given its native support for dynamic dependencies. [We can't all use buck2, unfortunately.]

(5) Less common, but still important, is building latency-sensitive IDE services. In those cases, the build system may not be able to generate the appropriate build artifacts, possibly because of dynamic dependencies, or the overhead may be too much to serve queries in real-time as the code changes. In those cases, more specialized infrastructure is necessary.

(6) For demonstration, I cloned the "nixpkgs" repository from GitHub. It's not a huge repository by industry standards, with 43k files in the working copy, but it's enough that walking the entire repository is slow on my machine.

(7) For example, on my machine, just visiting all the files in the repository without reading them takes around 750ms. And that's without any additional processing. If you wanted to actually perform a build, you could expect significantly more overhead.

(8) If we were doing remote development, we might simply use a tool like rsync to efficiently sync all the local files to the remote machine.

(9) If we just naively run `rsync` on my machine, from one directory to another, it takes around 1.4 seconds for a no-op sync. That is, if I haven't changed any files, it takes 1.4 seconds to do nothing. That's because `rsync` has to walk and hash all files on the local and remote sides to avoid transferring data that's already present on the remote.

(10) So what can we do? I'll give a few ideas.

(10) One is to maintain a persistent data store to try to avoid reading files that probably haven't changed, similarly to how Git maintains its index. This is helpful but still scales linearly with the size of the repository, so it's not necessarily sufficient by itself.

(10) Another is to launch a background process (a "daemon") that waits for the operating system to notify it about changed files, and then syncs the files preemptively. This is a workable, but I'll argue hugely complex, solution.

(10) Now I have to explain the subtitle for this talk, "don't daemonize that build!".

(11) By "daemon", I basically mean a background process that runs independently of explicit user interaction. Oftentimes, I see daemonization proposed as a natural next step when a build task is starting to take too long to run end-to-end.

(12) There are a few common reasons to want to daemonize.

(12) One is to keep previously-computed data in memory without having to recompute it or reload it. We'll discuss some ways to address that without a daemon in this talk.

(12) Another one is just the fact that operating system APIs require that you subscribe to filesystem notifications in a long-running process in order to actually receive the events as they happen. We'll discuss how Watchman fits in here.

(12) One last thing is specifically to reduce startup latency due to the choice of programming language or runtime. This talk unfortunately doesn't address that issue.

(13) So why not daemonize? I'm not going to read off every point on this slide, but, basically, it's a ton of incidental complexity, by which I mean complexity you have to deal with that's not really helping you accomplish your engineering goals.

(13) Daemonization is an attractive solution to improve performance at first glance, but it incurs a lot of unexpected and insidious costs down the road.

(14) So my recommendation is: avoid daemonizing your build tasks for as long as possible.

(15) This talk is about using Watchman, a file-watching service, as a way to abstract out a lot of the incidental complexity and help you focus on tackling your actual engineering problems.

(15) You can use Watchman as a high-level primitive in custom build systems. Watchman is a great tool in my opinion because it can completely change the design of your system for the better. And, in fact, even if you do one day decide to daemonize your system, you may benefit a lot from continuing to use Watchman and designing your system around the abstractions that it offers.

(15) I'll also mention that other systems offer similar interfaces. For example, the build system buck2 supports a similar interface via its "incremental actions", and the Language Server Protocol supports subscribing to file-watching notifications.

(16) So let's get started with Watchman.

(17) The first thing we have to do is ask Watchman to start watching a directory with the watch-project command. Easy enough.

(18) Next, let's issue a basic query.

(18) Notice that we're calling Watchman via the command-line interface with a JSON payload. This is already a huge improvement from an engineering perspective, just because it's way easier to experiment with this rather than, for example, the inotify syscall interface for Linux in a long-running C program.

(18) Here's, I'm piping in a JSON payload to standard input using bash. The subcommand is query, the watched directory is the current directory, which is nixpkgs in this case, and the last parameter is the query options.

(18) By default, if we don't pass any query options, Watchman returns data about all of the files in the watched directory. In this case, I piped the result to jq to just get the first file for demonstration purposes. We'll see how to do incremental processing shortly.

(18) In the result, you can see the filename — in this case, it's happens to be the .git directory — and a few other metadata fields that are returned with the default query options. You can ask Watchman for a different set of metadata if you want.

(19) Now let's look at the metadata returned by Watchman for the query itself, rather than the metadata for individual files.

(19) There's two main things to look at. The first one is clock, which is the key to working with Watchman. Basically, this value represents the point in time immediately after the query returned. I can use this value in subsequent queries to get a list of changed files since that previous clock ID or point in time. It's very similar to a database cursor in that respect.

(19) The second one is is_fresh_instance, which basically means that I, the caller, may have missed some filesystem notifications since the last time I queried Watchman. We'll discuss the implications of this in more detail later.

(20) To use the clock ID, you can add since to your query with your previous clock ID, and Watchman will only return files that have changed since that clock ID.

(20/21) In this example, I made an initial query and got an initial clock ID, and then I immediately use it in the next query via the since field, and Watchman returns an empty files array, meaning that no files have changed since that clock ID. Then I create a new file called foo and query since the same clock ID as before, and this time Watchman returns the file foo.

(22) Watchman will also tell you about files that have been deleted since the clock ID. You can see here that `exists` is now set to `false`, meaning Watchman thinks that the file has been deleted on disk since the last clock ID. We often need this for the correctness of build tasks in order to invalidate data corresponding to deleted files.

(23) And just a few more features. Here, we're explicitly setting metadata fields we're interested in, including the SHA1 content hash for each file. If you want, Watchman can compute and store the content hashes for you in memory, which can be convenient for caching as discussed later.

(23) And we can provide arbitrarily complex expressions to limit what kinds of entries Watchman returns. In this case, we're limiting the returned entries to files of type f, which is to say that they're real files, and not directories or symlinks or something else, mainly so that I can show an example of Watchman returning the content hash. And we're excluding files under the .git directory, so that Watchman returns a real source file instead of some random Git metadata file.

(23) In the result, we can see that Watchman returned some Main.java file along with its metadata and hash as the first file.

(24) So let's show a real example of working with Watchman.

(25) This is a bash script to implement incremental rsync. Instead of unconditionally syncing all files, we'll sync only the files that have changed since the last sync.

(25) First, we start watching the project. We load the previous clock ID from persistent state on disk, or a default clock ID if it's not available. We query Watchman, and based on is_fresh_instance, we do either a full sync or an incremental sync.

(25) We have to do a full sync if it's the first sync, or if we missed any filesystem updates, to bring the remote side back to a known state. That includes deleting any extra files on the remote side with rsync's --delete-after option.

(25) In the incremental sync case, we limit rsync to syncing only the changed set of files. Note that this set may include deleted files. We pass --delete-missing-args to rsync to indicate that a missing file is not an error, but that we actually want rsync to delete that file from the remote side.

(25) Then we run rsync, and we make sure to only save the new Watchman clock if it succeeds. You can think of this as similar to "committing" a database transaction. If the rsync failed for some reason, then the next attempt will try to sync all of the old changed files again, plus any newly-changed files.

(26) If we try it out, you can see that it's around 4.5x times faster than the naive rsync solution, with not a lot of development effort. And I want to emphasize that we could definitely improve on the efficiency of the script.

(27) Hopefully you're starting to see the utility of Watchman as a primitive for your build tasks by now.

(28) There's much more detail about Watchman advantages and disadvantages in the online slides, but I'll just include this snippet from a blog post by an engineer at Stripe. [read quote aloud]

(29) The real advantage of Watchman is that encourages you to design and implement correct systems.

(29) If you think about it, your filesystem is a kind of distributed system. You can send messages to files in your filesystem and ask them about their current state, but it's always possible that someone else will come and modify a file when you're not looking. So, fundamentally, it's much harder to work with a filesystem than just a hash map in memory, for example.

(29) The Watchman design lifts the level of abstraction from "synchronizing against a shared mutable data store" to "processing an ordered, replayable stream of events". And that's the big advantage of using Watchman. It's just a nice bonus that it has a bunch of other practically-useful features for building incremental systems.

(30) I'll talk a little bit more about a couple of features of the Watchman design.

(31) Practically-speaking Watchman supports three main workflows:

(31) One is where you run a program which queries and processes changes on-demand, which is the model we've been talking about so far, and that can take you a long way.

(31) But with the trigger subcommand, you can invert the control flow and ask Watchman to call you when something changes. This is very useful if you want to process changes immediately, instead of when the user asks you to. Watchman will ensure that there's only one instance of your command running at once, and it can also do things like batch changes for efficiency.

(31) Or you can subscribe to changes in a long-running process, similarly to using the operating system APIs, but at a higher level of abstraction. So you can still use Watchman with a daemonized build.

(32) Underneath the hood, you can consider Watchman as maintaining a linked hashmap in memory, from path to file metadata. When Watchman receives a filesystem notification for a path, it looks up that entry, updates the metadata, and bumps it to the head of the list in constant time. When you ask Watchman for recent changes, it iterates the list and returns entries until it reaches one older than the clock ID you provided, then terminates the traversal.

(33) Next, I'll shift gears to giving practical advice to using Watchman. But before that, I'd like to take any questions that you might have.

(34) First, I'll discuss some rules to follow in order to build correct systems on top of Watchman.

(35) I recommend you read the linked Stack Overflow answer on what is_fresh_instance means. Basically, you need to assume that any persistent state may now be invalid. You have to either clear the persistent state or validate it before using it again.

(36) Be mindful when using queries that might change. One example is if you construct a query using .gitignore files in the repository, you may have a cyclic dependency between .gitignore files and the query that watches those .gitignore files for changes. If you're not careful, you might end up in a situation where you can't detect certain changes to ignored files.

(37) Like we discussed earlier, the local filesystem is basically a racy distributed system. For example, if Watchman reports a changed file, you may try to read it from disk, and discover that it's been deleted since the last Watchman query. You should plan to handle that case up-front.

(38) Now some tips and common patterns for using Watchman.

(39) One quick algorithmic tip. I recommend that you try to unify your full and incremental processing paths as much as possible. The way to do that is to treat Watchman results not as a set of files to traverse in the filesystem, but instead a set of files to limit your traversal of the filesystem. Here's an example code snippet: we put all the changed paths into the set paths_to_visit, plus their transitive ancestor directories. If we got is_fresh_instance from Watchman, then we set paths_to_visit equals None and don't limit traversal at all.

(40) Then, in the filesystem traversal code, we just check should_visit before processing each path, to ensure that we skip processing most files in the incremental case. It really helps improve the reliability of your incremental system when you have fewer distinct code paths to exercise.

(41) If you want to store persistent state, then you probably want a mapping from path to metadata, with the ability to update — and invalidate —individual key-value pairs efficiently.

(41) An easy way is to just store a big JSON blob on disk, read it on startup, make any changes in-memory, and write it on shutdown. This can still be much faster than processing the entire repository contents every time.

(41) Cleverer alternatives include SQLite, which an on-disk relational database, and RocksDB, which an on-disk key-value store.

(41) I've used all three of these approaches.

(42) You may need to compute data that's not indexed directly by path. For example, in an IDE, you may take a file path as a key and compute the list of symbols defined in that file as the value. To support go-to-definition, you would want a mapping in the other direction, from symbol name back to file path.

(42) Maintaining the reverse mapping is just a general build system problem at this point. One technique I want to point out is that it's oftentimes feasible to not fully update the reverse mapping and continue to store stale edges. For example, if I store a reverse mapping that says that class Bar is defined in path foo.py, and then I delete foo.py, I might not update the reverse mapping at all. Instead, when I query the path associated with class Bar, my code could actually go re-parse file foo.py and confirm that class Bar is still there before returning it as a result.

(43) For performance, if you want to keep your persistent state alive across is_fresh_instances, you can use an extra key to confirm that data is still valid. One idea is to store the content hash associated with a file, so that you know that the data is still valid without needing to reprocess the file.

(43) If you didn't clear the entire persistent state when getting is_fresh_instance, then keep in mind that the set of paths in your persistent state might include extra stale paths if you don't explicitly clean them up.

(44) If your caching scheme is machine-independent, and your build artifact is expensive enough to compute, then it might make sense to rely on a recent precomputed artifact or service as a base, and compute the changes since then. Supposing that I have a recent build artifact at tag warm, I can download it, and then ask source control for the files changed between the warm commit and HEAD, and rely on Watchman from that point onwards. This is what I did to support Hack IDE services at Meta.

(44) To do this correctly, make sure you have a strategy for handling files deleted since the `warm` tag. For path-addressable data stores, you can employ a technique like tombstones. For content-addressable data stores, you might effectively handle deletions for free.

(45) That's all of the practical items. Thanks everyone for watching! Hopefully you learned something about incremental computation or will consider using Watchman to avoid daemonizing your next build. If you're following along with the slides, you can go to the next slide to see some of the content I cut.

(45) If you enjoyed this talk, I'm on the job market currently and would love to continue working in the developer infrastructure and tooling space. You can reach out to me in person or at my email, which is me@waleedkhan.name.

(45) Now I'll open up the floor to questions.

[no notes for deleted slides]

{% include end_matter.md %}
