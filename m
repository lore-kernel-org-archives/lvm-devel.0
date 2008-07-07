From: Daniel Phillips <phillips@phunq.net>
Date: Mon, 7 Jul 2008 03:36:47 -0700
Subject: Versioned pointers: a new method of representing snapshots
Message-ID: <200807070336.47375.phillips@phunq.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Good day storage mavens,

Every now and then down in the unexciting and arcane underbelling of
storage research one encounters some real computer science.  Today I will
outline one such encounter, which I expect to result in significant
improvements to the capability and performance of our ddsnap
snapshotting block device, and most probably has benefits in other areas
as well, such as snapshotting filesystems.  I apologize in advance for
any forward references, as I wish to get straight to the meat of this.
For definitions of various domain specific terms, please see the
terminology section at the end.

A snapshot of a disk volume may be represented as a list of exceptions
to an origin volume, where each exception points to a logical chunk of
data in a "snapshot store", which holds the data for the snapshot at a
particular logical address.  For any logical address for which no
exception is present, the data resides on the origin volume.  Thus, the
entire set of exceptions for a snapshot can be thought of as a list of
places where the snapshot differs from the origin.

The "versioned pointer" method is a new way of representing
exceptions for multiple simultaneous snapshots in a surprisingly compact
form.  The idea was inspired by a proposal from Steve Vandebogart
(interning at Google) to represent exception sharing for a series of
volume snapshots using a snapshot sequence number in place of a fixed
size chunk sharing bitmap, as is the existing practice in ddsnap.  The
sequence number would be fewer bits than the bitmap and could be packed
into unused bits of a physical block pointer, which would shrink our
snapshot metadata significantly.  However, when the sequence eventually
wraps a full metadata edit would be needed to relabel stored exceptions,
and so some snapshot creates would take much longer than others.  Users
generally do not like to wait around while snapshots are created.

Versioned Pointers

This issue was addressed by introducing a one to one mapping between
snapshots and arbitrary version numbers in place of sequence numbers
(and in the process notched up yet another example of a problem solved
by adding a new layer of indirection).  The idea of sequenced pointers
thus begat version labels, which begat the notion of "versioned
pointers", the subject of this post.

It occurred to me that a pointer version label is similar to a revision
control version id, and I proceeded to investigate the question of
whether revision control techniques could be applied to volume
snapshots.  I had experimented with a system where each piece of text is
labeled by the version in which it first appears, and by the version in
which it disappears (the "birth" and "death" labels, essentially a
binary weave).  By knowing the hierarchical relationship between
versions, the "version tree", it is possible to determine whether any
given piece of labeled text belongs to a given version.

Volume versioning differs from text versioning in that data chunks do
not appear and disappear, but only change.  Each change of chunk data
can be viewed as a disappearance followed by an appearance, so only a
single label needs to be associated with each change.  The other label
is implied by the presence of a change labeled by some descendent in the
version tree.  It became clear that a single version label for each
rewrite of a given volume chunk is enough to determine the set of
versions to which the written data belongs.

Version Inheritance

If a given version does not have an exception of its own for a
particular logical address, then it inherits an exception from its
parent, which in turn inherits from its parent if it does not have its
own, and so on up to the root of the version tree.  The root implicitly
inherits all the chunks of the origin volume.  Thus, a snapshot of the
origin volume is just a new root of the version tree, with the old root
as its child.  Similarly, a snapshot of a snapshot is a new child of
some version, and inherits all the exception of its parent, exactly as
required.

Since we have not so far had an efficient way of creating snapshots of
snapshots in ddsnap, the possibly of being able to do so merely by
altering a version tree seemed very interesting.

Thus encouraged, I set out to determine whether a stable representation
is possible in the sense that no full metadata edit would ever be
required to maintain this representation except when a version is
deleted.  If this were the case then this new technique would be well
suited to volume snapshotting, where a large amount of durable metadata
has to be maintained and updated with good locality.

Examples

Here is an example version tree with version nodes labeled in the order
created:

.
`-- C '1003'
? ? ?`-- B '1002'
? ? ? ? ?|-- A '1001'
? ? ? ? ?`-- D
? ? ? ? ? ? ?|-- E '1005'
? ? ? ? ? ? ?`-- F
? ? ? ? ? ? ? ? ?|-- G '1007'
? ? ? ? ? ? ? ? ?`-- H '1006'

Versions A, B and C are snapshots of the origin. ?(They appear inverted
in the tree because new origin snapshots are added at the root.) ?All
other versions represent snapshots of snapshots.  Most of the versions
have snapshot tags, in quotes.  Those that do not are inaccessible ghost
versions, explained below.

Given the exception list [[A, p1] [B, p2]] where p1 and p2 are physical
chunks, and omitting the snapshot tags, we have:

.
`-- C
? ? ?`-- B => p2
? ? ? ? ?|-- A => p1
? ? ? ? ?`-- D => p2
? ? ? ? ? ? ?|-- E => p2
? ? ? ? ? ? ?`-- F => p2
? ? ? ? ? ? ? ? ?|-- G => p2
? ? ? ? ? ? ? ? ?`-- H => p2

Version A is the exclusive owner of chunk p1 while all other versions
except C inherit p2. ?C has no exception at this logical address,
therefore inherits a chunk of the origin.

Another way to represent this is to overlay the chunks of the exception
list on their respective versions:

.
`-- C
? ? ?`-- B [p2]
? ? ? ? ?|-- A [p1]
? ? ? ? ?`-- D
? ? ? ? ? ? ?|-- E
? ? ? ? ? ? ?`-- F
? ? ? ? ? ? ? ? ?|-- G
? ? ? ? ? ? ? ? ?`-- H

This representation shows both the global version tree and an exception
list for a particular logical address.

Writable Snapshots

It is highly desirable that snapshots be writeable.  As an example of
why one might wish to do this, consider a virtualized server farm
where each server has its own, slightly different image of the root
volume.  For each virtual server instance, a snapshot of a generic root
volume is taken and customized for or altered at runtime by one of the
server instances.  (This also constitutes a use case for snapshots of
snapshots, to avoid a clumsy revert of the origin volume for each new
server instance.)

Writeable snapshots are problematic in terms of inheritance: if a
pointer for a newly allocated snapshot store chunk pointer is labeled
with a given version then it may be inherited by other children of the
same version, violating the principle of snapshot isolation (a write to
a snapshot may not change any other snapshot).  My solution is to
generate a new, implicit version as a child of the written version, to
which the new versioned pointer can be added without affecting any
other version.

Ghost Versions

Adding a new layer of indirection was the method of choice once again:
each snapshot is known externally by a numeric "tag" which is the handle
for all operations on the snapshot, such as creating a virtual block
device for it or deleting it.  When a snapshot mapping to a version
having one or more children is written for the first time, a new version
is generated as above and its tag is reassigned to the new version.

The original version loses its tag and cannot thereafter be accessed
externally, becoming a "ghost version".  A ghost version exists only to
allow its children to continue to inherit any data written to it before
it had any children.

Thinking back on it, this was a fairly radical idea because it was far
from clear that the implicitly snapshot strategy would not rapidly
exhaust the limited supply of version numbers.  Remarkably, it turned
out to be the case that only a limited number of ghost versions could
ever be created, that limit being one less than the number of externally
known snapshots.  Unfortunately, the proof of this will not fit in the
margin of this email.

An essential property of a ghost version is that, because it is not
externally accessible and thus cannot be read or written, it need
not be a consistent point in time version of a volume.  Therefore its
exceptions can (and must) be freely cannibalized by other versions as
the geometry of the version tree changes and exception lists are
modified over time.

To illustrate, given a write to a snapshot with tag '1001' mapping to
version A, with one child snapshot:

.
`-- A '1001'
? ? ?`-- B '1002'

A version C is implicitly created to hold the new exception [C, p1],
which could not have been added to version A because it would then have
been inherited by version B, violating the isolation of snapshot 1002:

.
`-- A
? ?  |-- B '1002'
? ? ?`-- C [p1] '1001'

Version A has become a ghost.

Version Deletion Problem

When a snapshot with exactly one child is deleted, all the exceptions
it owns can simply be relabelled to the child version, and the
child version replaces the deleted version in the version tree.  This
does not violate snapshot isolation because the chunks in question were
previously inherited by the child anyway.

When a version with more than one child is deleted, it is not obvious
how to relabel exceptions belonging to the deleted version.  It would
be possible to generate duplicate exceptions sharing the original chunk
pointers, but this would raise the specter of metadata that can expand
during a delete.   When the snapshot store is nearly full the delete
could fail for lack of space.  Not only would this surprise the user,
but in the case of automatic deletion to recover space to service a
write to a snapshot, the system could deadlock.  There is no such thing
as an elegant workaround for an expand-in-delete problem.

Ghost Versions Redux

The solution I adopted is to leave the version associated with a deleted
snapshot in the version tree, along with any inherited exceptions.  The
version's tag is deleted, creating what I initially called a "zombie"
version.  Later we discovered that zombie and ghost versions are in fact
the same, and in particular, share the property that they cannot
proliferate without bound.  (This was just one of many close calls for
the versioned pointer method, where subtle logic came to the rescue in
the face of some seemingly insurmountable problem.)

A ghost version can always be deleted when its child count drops to one
at the time one of its remaining two children was deleted.  The single
remaining child is promoted to take its place in the veresion tree, and
all exceptions belonging to the ghost are relabeled to the child as in
the case of explicit deletion of a snapshot with a single child.

This fact is one link in the long chain of reasoning required to show
that ghost can never outnumber explicitly created snapshots.  As a
corollary, each ghost version requires at least two children to force
its continued existence.  (Before leaping to the conclusion that this
shows there are always more explicitly snapshots than ghost versions,
consider that both children may themselves be ghosts.)

Exclusive Exceptions

An exclusive exception is one that is not inherited by any child,
either because the owner has no children, or each of its heirs has
an exception for the same chunk address, or every version that inherits
the exception is a ghost.  An exclusive exception's data chunk can
always be modified without affecting any other snapshot.  In
particular, whenever a logical chunk of a given snapshot is written
repeatedly with no intervening snapshot creates, all but the first
write are guaranteed to be to exclusive exceptions.

Orphan Exceptions

An orphan exception is an exclusive exception that belongs to a ghost.
Because it cannot be read or written directly via a snapshot tag or
indirectly by being inherited, it is completely inaccessible and will
only waste space in the snapshot store if allowed to exist.  Orphan
exceptions may be created by writes to snapshots or deletes, and the
respective algorithms must detect and delete them immediately to avoid
leakage.  Potentially long and complex chains of inheritance can be
involved, so this requirement gives rise to some particularly subtle
rules.  For example:

   "If a target has no children and no exception then removing it
   or replacing its ghost parent with no exception by a sibling of
   the target with no heirs reduces heirs of the parent.  If heirs
   are reduced, a search for a ghost ancestor with an uninherited
   exception must be performed."

Reading from a Snapshot

Reading from a snapshot at a given logical chunk address requires
determining which exceptions are present in the exception list for that
logical address, and are labeled by versions lying between the target
version and the root of the snapshot tree.  If any such exceptions are
found, then the exception furthest from the root owns the snapshot data
of interest.  Otherwise the data for that logical address resides on the
origin volume.

Writing to a Snapshot

After a write to particular logical chunk of a snapshot an exclusive
exception for that chunk of that snapshot will always exist, containing
the written data.  Before the write, the snapshot may have had no
exception but inherited an exception from some other snapshot or
inherited a chunk from the origin, or it may have had an exception that
is inherited by one or more of its descendants, or it may have already
had an exclusive exception.  In all cases except the last, an
exception is added to the snapshot at that logical address.  If an
exception is inherited from a ghost and the written snapshot is the sole
heir of the exception, then the exception will be relabeled, otherwise a
new exception will be created, including allocating a snapshot store
chunk to hold the exception data.

Writing to the Origin

If an origin chunk is inherited by any snapshot, then the data about to
be overwritten must be copied to the snapshot store before the new data
is written.  If the root of the snapshot already has an exception, then
the origin chunk is clearly not inherited and nothing needs to be done.
Otherwise a new exception for the root version is created and the data
to be preserved from the origin is copied to the associated chunk.

Deleting a Snapshot

Snapshot deletion is by far the most complex aspect of the versioned
pointers technique.  Various rules must be enforced, for example, that
no ghost version may exist with less than two children.  If the deleted
snapshot has one child then the child will be promoted to be a child of
the deleted snapshot's parent.  If it has two or more children then the
deleted snapshot will become a ghost.  If it has no children and its
parent is a ghost with two children, then the parent will be deleted and
the sibling of the deleted snapshot will be promoted to take the place
of the parent.

Besides adjusting the version tree, each exception for the deleted
version (or versions if the parent is also deleted) must be
either removed from the snapshot metadata if it is not inherited by any
version, or relabeled to one of its children if it is.  Any exceptions
that become orphans as a result of no longer being inherited by the
deleted snapshot must be detected and removed.

Implementation

The attached test program implements all six basic snapshot operations:

  1) Create snapshot of origin
  2) Create snapshot of snapshot
  3) Delete snapshot
  4) Write to origin
  5) Write to snapshot
  6) Read from snapshot

None of the algorithms are worse than O(n) where n is the number of
versions in the version tree.  Most are O(e) where e is the number of
exceptions in an exception list.  This level of performance was largely
achieved through pre-computation of lookup tables to accelerate such
operations as determining whether a given version lies on the path from
some other version to the root of the version tree.  The snapshot
delete in particular started as an O(n^3) algorithm before being
gradually improved to O(e) using mapping tables and a multipass
approach.

It is thought that all the algorithms can eventually be improved to
O(log n) worst case performance.  Meanwhile, since n is limited to a
fairly small number by the number of bits available in a version
label, real world performance appears entirely satisfactory.  Compared
to our current representation of snapshot exception data, fitting more
data in cache is likely to have a bigger effect than the slightly more
expensive base operations.

Extents

The versioned pointer technique is compatible with extent-based data
representations, much more so than the snapshot exception
representation it is expected to replace, which ties snapshots together
with a sharing bitmap that would be complex to represent in an extent
form, as the extents are likely to be different for each snapshot.

On the other hand, each exception represented by a versioned pointer
simply needs a count field added to become an extent.  Using 64 bit
exceptions as we do, there is enough room in the pointer for 48 bits of
logical address, addressing an even exabyte of snapshot store, 10 bits
of version label allowing 512 user visible snapshots, and a 6 bit
extent count, allowing extents up to 256K assuming 4K blocks.  Allowing
for other overheads, this gives a data to metadata ratio of about
15,000 to one, beyond which there is not a great deal of additional
benefit to be obtained from extents.

Extension of the current algorithms to handle extents is in progress.

Application to filesystems

The versioned pointer technique is by no means limited to representing
volume data.  It also has promise as a means of implementing filesystem
snapshots.  Compared to the technique used by WAFL or ZFS, there is no
recursive copying of tree-structured metadata.  Compared to Btrfs, there
are no reference counts.  A possible deficiency is the bias towards
representing all version information for a given logical address
together at the same location in the metadata.  If there is a lot of
version metadata and only a single snapshot is being accessed, a larger
amount of metadata may have to be read.  Extending the method to handle
extents would mitigate this.

If applied to filesystems, it would be feasible to independently
snapshot each file and each directory.

Fuzzing Test

The attached test program implements a "fuzzing test" to verify
empirically the correct implementation of the versioned pointers
operations.  Without loss of generality, only a single exception list is
tested, because each exception list is self contained and independent
from all other exception associated with other logical addresses.

Each iteration of the fuzz test randomly selects one of the first five
operations and performs it on a random target, then reads every
snapshot to verify that all contain the expected data.  Various
consistency tests are performed, for example:

  * All exception labels are valid
  * No deleted version labels an exception
  * No multiple exceptions with same label in same list
  * No ghosts have orphan exceptions
  * No ghost has less than two children
  * No cycles in the version tree

This fuzzing test has run successfully to ten million iterations.  This
does not prove that the algorithms are correct, but it is encouraging.
Along the way, seemingly endless bugs were discovered especially in
the area of ghost exception detection.  Some of the invariants
described in this note were discovered in response to bugs detected by
the fuzzing test, which is not to say that empirical observation is a
substitute for logical analysis, but that the underlying logic was most
certainly discovered faster than it could have been by logical analysis
alone.

Conclusion

The versioned pointer method is a novel technique for representing
versioned disk data, which promises the following benefit to the ddsnap
snapshotting block device project:

? ?1) Maximum number of snapshots increases
? ?2) Metadata shrinks by up to 50%
? ?3) Supports instant creation of snapshots of snapshots
? ?4) Easier to move to extents for additional compactness

It is also possible that the method may prove useful for filesystem
snapshots.  A prototype implementation exists, demonstrating the
efficacy of the technique and empirically verifying correctness.

Terminology

Snapshot: ?A volume version tagged with a unique id by which it can be
accessed and operated on externally.

Snapshot tag: ?An externally visible 32 bit integer specified by an
application programs at the time a snapshot is created. ?The snapshot
tag is used to create a virtual snapshot volume through which the
snapshot can be read and written.

Snapshot chunk: ?A chunk in the snapshot store holding data that was
either copied from the origin due to a write to an origin logical
volume or written to a snapshot logical volume.

Origin chunk: ?A chunk of data on the origin volume that is implicitly
shared at the same address by any version that does not have alternate
data at that address.

Version label: ?A unique id carried by each node in the version tree.

Version tree: ?The root of the version tree is the most recent snapshot
of the origin. ?Each new version of the origin becomes the new root of
the version tree and the parent of the old root. ?Each new version of a
version becomes a child of the existing version.

Chunk inheritance: ?When a new version is created it inherits every
chunk of its parent. ?The root of the version tree inherits every chunk
of the origin volume. ?Care must be taken never to write to an inherited
chunk, otherwise all versions inheriting the chunk will be altered in
violation of the principle of isolation between versions (the I in
ACID).

Exception list: ?A list of exceptions for a given logical chunk address
defining which physical chunks belong to which versions. ?Each exception
is said to be "at" that logical address.

Exception: ?A pair [V, p] that appears in an exception list to specify
that the physical chunk p is inherited by all nodes in the version
subtree rooted at the node labelled V, and bounded by nodes labelled by
other exceptions in the same list. ?Each physical chunk is owned by
exactly one exception. ?An exception labeled by a given version is said
to be "at" that version. We may say read or write "to an exception"
which really means "to the physical chunk owned by the exception".

Unique vs shared chunks: ?A physical chunk is said to be unique if it is
not inherited and shared otherwise. ?An origin chunk at a given logical
address is unique if and only if there is an exception at that address
labeled by the root version. ?A chunk of the origin or a version can be
written to without affecting any other version if and only if it is
unique.

Regards,

Daniel
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fuzzversion.c
Type: text/x-csrc
Size: 23194 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080707/bcc035c2/attachment.bin>
