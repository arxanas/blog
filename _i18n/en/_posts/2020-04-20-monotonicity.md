---
layout: post
title: Monotonicity is a halfway point between mutability and immutability
permalink: monotonicity/
tags:
  - software-engineering
---

* toc
{:toc}

## Introduction

Immutable values are easy to reason about in complex systems, because they never change. Many functional languages strongly encourage the developer to use immutable values. For example, Clojure has a strong emphasis on using immutable values, so that multithreading can be made easy and safe.

However, making everything immutable can be impractical, especially in established codebases with poor language-level support for immutability-by-default. Some modern languages with good support for immutable values still let you opt into mutable data when needed (such as Rust with the `mut` keyword).

In this article, I describe a property called _monotonicity_, which is a halfway point between mutable and immutable values. Structuring your code around monotonicity can make it easier to reason about values without having to make them immutable, even in languages with good support for immutable values.

The concepts in this article are probably obvious to anyone who took a databases course in college, but I didn't!

## What is monotonicity?

A "monotonic" value is a value for which information is always added, never removed. You could consider it a sort of "append-only" data structure. It rests between mutability and immutability in that you can still change it by adding information (which may change the meaning of the data), but data is never lost.

## Simple values

Suppose that we're modeling a user. We could store the user's name as a single field in a structure:

```python
@dataclass
class User:
    name: str
```

When we want to update the name, we can modify it in-place:

```python
@dataclass
class User:
    name: str

    def update_name(self, new_name: str) -> None:
        self.name = new_name
```

This **loses data**, specifically the old version of the name. In enterprise systems, you can imagine wanting an "audit log" that would let you examine changes that occurred to the system. We can use a monotonic value to accomplish this. Instead of storing a single name, we'll store _all_ the names that the user has ever had, and return the last one as the user's canonical name:

```python
@dataclass
class User:
    names: List[str]

    @property
    def name(self) -> str:
        return names[-1]

    def update_name(self, new_name: str) -> None:
        self.names.append(new_name)
```

Now an administrator can view all of the historical names for a user. (In a real system, we would also store the person who did the action, the time, etc.).

This is also useful for non-enterprise-systems. If a user loses data somehow (either due to the user's accident or due to a bug in the code), then an administrator can manually reconstruct the data by looking at the history of the value.

## Memoized values

Memoized ("lazy") values are another common use-case for monotonicity. Sometimes, computation might be deferred until you need it, and once it's completed, it can be re-used for future requests:

```python
@dataclass
class User:
    profile: Optional[Profile]

    def read_profile(self) -> Profile:
        if self.profile is not None:
            return self.profile
        profile = load_profile_from_disk()
        self.profile = profile
        return profile
```

Mutable state can be difficult to reason about at times, but in the case of a memoized value, it's hardly considered mutable at all. Once the value is loaded, it's never changed.

This makes it easier for someone to debug the system. When they see a value for `profile`, it implies something about the _history_ for that value. If it is `None`, then it has never been computed in the past, and if it is a `Profile`, then it was computed exactly once and updated. There's no concern that `profile` was updated multiple times in the past with a value you can no longer access, or that different callers may have seen different values.

## State machines

A memoized value is a special case of a [state machine](https://en.wikipedia.org/wiki/Finite-state_machine). The value in the previous example transitions from the `None` state to the `Profile` state.

A _monotonic state machine_ is a state machine that never revisits a previous state. For example, we may transition a user through multiple states of verification when they sign up for a service:

```python
class ContactDataState(Enum):
    NONE = 0
    UNVERIFIED = 1
    VERIFIED = 2
    REVOKED = 3


@dataclass
class User:
    email_state: ContactDataState
    email: str
    phone_number_state: ContactDataState
    phone_number: str

    def add_email(self, email: str) -> None:
        if self.email_state == ContactDataState.NONE:
            self.email_state = ContactDataState.UNVERIFIED
            self.email = email
        else:
            raise RuntimeError("Cannot set email for a user who already has an email")

    def verify_email(self, email: str) -> None:
        if self.email_state == ContactDataState.NONE:
            raise RuntimeError("No current email set")
        elif self.email_state == ContactDataState.UNVERIFIED:
            if email == self.email:
                self.email_state = ContactDataState.VERIFIED
            else:
                raise RuntimeError("Could not validate email")
        elif email_state == ContactDataState.VERIFIED:
            raise RuntimeError("Email already verified")
        else:
            raise AssertionError("Invalid state")

    def revoke_email(self) -> None:
        self.email_state = ContactDataState.REVOKED

    # Similar for `phone_number`...
```

This example represents a monotonic state machine, since the only transitions are from `NONE` to `UNVERIFIED` and `UNVERIFIED` to `VERIFIED`, or from any state to `REVOKED`. No state is ever re-visited. This means that the developer never has to worry about the question "was this email ever valid in the past?". Instead, an email becomes revoked, which is a different status.

Of course, if the user wants to set up a new email, this pattern won't work. Then we can combine it with the "simple value" pattern above and store lists of email-plus-email-state. The current status of the user's email would be the most recent email-plus-email-state entry.

In practice, many pieces of data benefit from the monotonic state machine approach, and don't actually require the ability to return to an initial state. Then the state machine by itself is enough. In my experience, including a separate state denoting the invalidation of data rather than reusing a state becomes a very helpful way of treating data for reasoning about code and for debugging purposes.

## In distributed contexts

Monotonic data structures are extremely useful for orchestrating data updates across multiple machines (or across multiple workers on the same machine). This is because of the append-only nature; it's easier to emit a stream of updates and combine them than it is to emit full data structures and combine them. In a monotonic data structure, the update approach is simply to union together the all the updates.

### Case study: a workout tracking app

Suppose you have a fitness tracker bracelet and a corresponding companion app. The fitness tracker bracelet automatically detect workouts based on the wearer's physical activity, and the wearer can manually enter a workout into the app. How do we synchronize the two event streams?

One option is to queue up workouts on the fitness tracker bracelet for syncing with the app. Its state might look like this:

```python
@dataclass
class Workout:
    kind: WorkoutKind
    duration: int

@dataclass
class WorkoutDatabase:
    queued_workouts: List[Workout]

    def add_workout_to_queue(self, workout: Workout) -> None:
        self.queued_workouts.append(add_workout_to_queue)

    def get_queued_workouts(self) -> List[Workout]:
        return queued_workouts

    def clear_queued_workouts(self) -> None:
        self.queued_workouts = []
```

The app wants to call `get_queued_workouts` to get the queued up workouts, and then `clear_queued_workouts` so that they're not returned and double-counted the next time it asks for them. If the connection between the fitness tracker and the app dies in between `get_queued_workouts` and `clear_queued_workouts`, then we may return the workouts again in the next `get_queued_workouts` call.

(There is another approach where `get_queued_workouts` and `clear_queued_workouts` are combined into the same call. This also has a flaw: if the app received the workouts and then crashes before it can process them, then the workouts are lost forever.)

The core problem is that this data structure is not monotonic: data can be lost. A simple fix is to retain all the data and use a monotonically-increasing integer to synchronize the two systems:

```python
@dataclass
class Workout:
    kind: WorkoutKind
    duration: int

@dataclass
class WorkoutDatabase:
    next_id: int
    queued_workouts: List[Tuple[int, Workout]]

    def add_workout_to_queue(self, workout: Workout) -> None:
        self.queued_workouts.append((self.next_id, workout))
        self.next_id += 1

    def get_queued_workouts(self, since_id: int) -> Tuple[int, List[Workout]]:
        result = [workout
                  for (id, workout) in queued_workouts
                  if id >= since_id]
        # The caller can use the `next_id` we return for their next call to
        # `get_queued_workouts`. If they crashed and didn't process the
        # previous workouts we sent them, then they can try again with their
        # previous value for the ID.
        return (next_id, result)
```

The app can essentially filter out workouts it's already seen. This ensures that the bracelet and the app can always sync and get correct data, even if one party breaks the connection in the middle of the protocol. The technical term for the kind of ID that enables this is a ["cursor"](<https://en.wikipedia.org/wiki/Cursor_(databases)>).

If we really want to delete entries and reclaim space (likely for an embedded system), the monotonic rewriting makes it clearer what changes need to be made to safely delete data:

```python
@dataclass
class Workout:
    kind: WorkoutKind
    duration: int

@dataclass
class WorkoutDatabase:
    next_id: int
    queued_workouts: List[Tuple[int, Workout]]

    def add_workout_to_queue(self, workout: Workout) -> None:
        self.queued_workouts.append((self.next_id, workout))
        self.next_id += 1

    def get_queued_workouts(self, since_id: int) -> Tuple[int, List[Workout]]:
        result = [workout
                  for (id, workout) in queued_workouts
                  if id >= since_id]
        # The caller can use the `next_id` we return for their next call to
        # `get_queued_workouts`. If they crashed and didn't process the
        # previous workouts we sent them, then they can try again with their
        # previous value for the ID.
        return (next_id, result)

    def clear_queued_workouts(self, since_id: int) -> None:
        # Delete any workouts that occurred before `since_id`, since they've
        # been acknowledged by the caller.
        self.queued_workouts = [(id, workout)
                                for (id, workout) in queued_workouts
                                if id >= since_id]
```

If there are multiple consumers of the workout data from the fitness bracelet, then the safe-to-delete data of the whole system is the intersection of safe-to-delete data for each individual consumer.

## Invalidating data

Sometimes, we want to remove a piece of data. Rather than literally deleting it (which may not be audit-log friendly), one can simply commit a new marker piece of data associated with the old piece of data that marks it as deleted.

If you have a database of records, then you can assign each record an ID, and use that to invalidate the record later. For example:

```json
{"id": 1, "type": "create", "data": {"name": "foo"}}
{"id": 2, "type": "delete", "entity_id": 1}
```

Then a record is only valid if there is no deletion record for that same record. (A database engine should be able to configure a schema to query for this quickly.)

This is the same as transitioning the data to a new state called `DELETED`, except that it's doable in a distributed context. Multiple parties can synchronize data, and the deletion will be properly synchronized between them --- without having to modify any data in-place. The technical term for this kind of marker is a ["tombstone"](<https://en.wikipedia.org/wiki/Tombstone_(data_store)>).

## Compaction

In a monotonic data structure, there may be many updates to the same logical object (including deletions). To speed up queries, it might be prudent to periodically "compact" the state of the monotonic data structure.

To compact the data structure, one simply iterates over all the update records in the data structure and constructs new aggregate records for each of the entities described therein, with all of the updates/deletions applied. For example, the input of such a procedure might be as follows:

```json
{"id": 1, "type": "create", "data": {"name": "foo"}}
{"id": 2, "type": "create", "data": {"name": "bar"}}
{"id": 3, "type": "create", "data": {"name": "baz"}}
{"id": 4, "type": "set", "entity_id": 1, "data": {"status": "qux"}}
{"id": 5, "type": "delete", "entity_id": 2}
```

And the output:

```json
{"id": 1, "type": "create", "data": {"name": "foo", "status": "qux"}}
{"id": 3, "type": "create", "data": {"name": "baz"}}
```

To carry out this compaction procedure may require an exclusive lock or some other kind of synchronization, but it can reduce the performance overhead of a monotonic approach.

{% include end_matter.md %}
