From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 21 Jun 2012 22:49:20 +0000 (UTC)
Subject: master - kernel docs: Refresh kernel target documentation
Message-ID: <20120621224920.388B9167C@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da42ee3a1f0280742e87a96f5d0694fb869a23e0
Commit:        da42ee3a1f0280742e87a96f5d0694fb869a23e0
Parent:        461eb1ac6adbf8e1938bd6e726dd4048c341cb49
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jun 21 23:48:40 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jun 21 23:48:40 2012 +0100

kernel docs: Refresh kernel target documentation

Update the packaged copy of the in-kernel target documentation files.
Adds dm-verity, updates thin provisioning and makes minor corrections
elsewhere.
---
 doc/kernel/persistent-data.txt   |    2 +-
 doc/kernel/raid.txt              |    2 +-
 doc/kernel/striped.txt           |    7 +-
 doc/kernel/thin-provisioning.txt |   78 +++++++++++++++----
 doc/kernel/verity.txt            |  155 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 222 insertions(+), 22 deletions(-)

diff --git a/doc/kernel/persistent-data.txt b/doc/kernel/persistent-data.txt
index 0e5df9b..a333bcb 100644
--- a/doc/kernel/persistent-data.txt
+++ b/doc/kernel/persistent-data.txt
@@ -3,7 +3,7 @@ Introduction
 
 The more-sophisticated device-mapper targets require complex metadata
 that is managed in kernel.  In late 2010 we were seeing that various
-different targets were rolling their own data strutures, for example:
+different targets were rolling their own data structures, for example:
 
 - Mikulas Patocka's multisnap implementation
 - Heinz Mauelshagen's thin provisioning target
diff --git a/doc/kernel/raid.txt b/doc/kernel/raid.txt
index 2a8c113..946c733 100644
--- a/doc/kernel/raid.txt
+++ b/doc/kernel/raid.txt
@@ -28,7 +28,7 @@ The target is named "raid" and it accepts the following parameters:
   raid6_nc	RAID6 N continue
 		- rotating parity N (right-to-left) with data continuation
 
-  Refererence: Chapter 4 of
+  Reference: Chapter 4 of
   http://www.snia.org/sites/default/files/SNIA_DDF_Technical_Position_v2.0.pdf
 
 <#raid_params>: The number of parameters that follow.
diff --git a/doc/kernel/striped.txt b/doc/kernel/striped.txt
index f34d323..45f3b91 100644
--- a/doc/kernel/striped.txt
+++ b/doc/kernel/striped.txt
@@ -9,15 +9,14 @@ devices in parallel.
 
 Parameters: <num devs> <chunk size> [<dev path> <offset>]+
     <num devs>: Number of underlying devices.
-    <chunk size>: Size of each chunk of data. Must be a power-of-2 and at
-                  least as large as the system's PAGE_SIZE.
+    <chunk size>: Size of each chunk of data. Must be at least as
+                  large as the system's PAGE_SIZE.
     <dev path>: Full pathname to the underlying block-device, or a
                 "major:minor" device-number.
     <offset>: Starting sector within the device.
 
 One or more underlying devices can be specified. The striped device size must
-be a multiple of the chunk size and a multiple of the number of underlying
-devices.
+be a multiple of the chunk size multiplied by the number of underlying devices.
 
 
 Example scripts
diff --git a/doc/kernel/thin-provisioning.txt b/doc/kernel/thin-provisioning.txt
index 801d9d1..f5cfc62 100644
--- a/doc/kernel/thin-provisioning.txt
+++ b/doc/kernel/thin-provisioning.txt
@@ -1,7 +1,7 @@
 Introduction
 ============
 
-This document descibes a collection of device-mapper targets that
+This document describes a collection of device-mapper targets that
 between them implement thin-provisioning and snapshots.
 
 The main highlight of this implementation, compared to the previous
@@ -75,10 +75,12 @@ less sharing than average you'll need a larger-than-average metadata device.
 
 As a guide, we suggest you calculate the number of bytes to use in the
 metadata device as 48 * $data_dev_size / $data_block_size but round it up
-to 2MB if the answer is smaller.  The largest size supported is 16GB.
+to 2MB if the answer is smaller.  If you're creating large numbers of
+snapshots which are recording large amounts of change, you may find you
+need to increase this.
 
-If you're creating large numbers of snapshots which are recording large
-amounts of change, you may need find you need to increase this.
+The largest size supported is 16GB: If the device is larger,
+a warning will be issued and the excess space will not be used.
 
 Reloading a pool table
 ----------------------
@@ -167,6 +169,38 @@ ii) Using an internal snapshot.
 
     dmsetup create snap --table "0 2097152 thin /dev/mapper/pool 1"
 
+External snapshots
+------------------
+
+You can use an external _read only_ device as an origin for a
+thinly-provisioned volume.  Any read to an unprovisioned area of the
+thin device will be passed through to the origin.  Writes trigger
+the allocation of new blocks as usual.
+
+One use case for this is VM hosts that want to run guests on
+thinly-provisioned volumes but have the base image on another device
+(possibly shared between many VMs).
+
+You must not write to the origin device if you use this technique!
+Of course, you may write to the thin device and take internal snapshots
+of the thin volume.
+
+i) Creating a snapshot of an external device
+
+  This is the same as creating a thin device.
+  You don't mention the origin at this stage.
+
+    dmsetup message /dev/mapper/pool 0 "create_thin 0"
+
+ii) Using a snapshot of an external device.
+
+  Append an extra parameter to the thin target specifying the origin:
+
+    dmsetup create snap --table "0 2097152 thin /dev/mapper/pool 0 /dev/image"
+
+  N.B. All descendants (internal snapshots) of this snapshot require the
+  same extra origin parameter.
+
 Deactivation
 ------------
 
@@ -189,7 +223,13 @@ i) Constructor
 	      <low water mark (blocks)> [<number of feature args> [<arg>]*]
 
     Optional feature arguments:
-    - 'skip_block_zeroing': skips the zeroing of newly-provisioned blocks.
+
+      skip_block_zeroing: Skip the zeroing of newly-provisioned blocks.
+
+      ignore_discard: Disable discard support.
+
+      no_discard_passdown: Don't pass discards down to the underlying
+			   data device, but just remove the mapping.
 
     Data block size must be between 64KB (128 sectors) and 1GB
     (2097152 sectors) inclusive.
@@ -237,16 +277,6 @@ iii) Messages
 
 	Deletes a thin device.  Irreversible.
 
-    trim <dev id> <new size in sectors>
-
-	Delete mappings from the end of a thin device.  Irreversible.
-	You might want to use this if you're reducing the size of
-	your thinly-provisioned device.  In many cases, due to the
-	sharing of blocks between devices, it is not possible to
-	determine in advance how much space 'trim' will release.  (In
-	future a userspace tool might be able to perform this
-	calculation.)
-
     set_transaction_id <current id> <new id>
 
 	Userland volume managers, such as LVM, need a way to
@@ -257,12 +287,23 @@ iii) Messages
 	the current transaction id is when you change it with this
 	compare-and-swap message.
 
+    reserve_metadata_snap
+
+        Reserve a copy of the data mapping btree for use by userland.
+        This allows userland to inspect the mappings as they were when
+        this message was executed.  Use the pool's status command to
+        get the root block associated with the metadata snapshot.
+
+    release_metadata_snap
+
+        Release a previously reserved copy of the data mapping btree.
+
 'thin' target
 -------------
 
 i) Constructor
 
-    thin <pool dev> <dev id>
+    thin <pool dev> <dev id> [<external origin dev>]
 
     pool dev:
 	the thin-pool device, e.g. /dev/mapper/my_pool or 253:0
@@ -271,6 +312,11 @@ i) Constructor
 	the internal device identifier of the device to be
 	activated.
 
+    external origin dev:
+	an optional block device outside the pool to be treated as a
+	read-only snapshot origin: reads to unprovisioned areas of the
+	thin target will be mapped to this device.
+
 The pool doesn't store any size against the thin devices.  If you
 load a thin target that is smaller than you've been using previously,
 then you'll have no access to blocks mapped beyond the end.  If you
diff --git a/doc/kernel/verity.txt b/doc/kernel/verity.txt
new file mode 100644
index 0000000..9884681
--- /dev/null
+++ b/doc/kernel/verity.txt
@@ -0,0 +1,155 @@
+dm-verity
+==========
+
+Device-Mapper's "verity" target provides transparent integrity checking of
+block devices using a cryptographic digest provided by the kernel crypto API.
+This target is read-only.
+
+Construction Parameters
+=======================
+    <version> <dev> <hash_dev>
+    <data_block_size> <hash_block_size>
+    <num_data_blocks> <hash_start_block>
+    <algorithm> <digest> <salt>
+
+<version>
+    This is the type of the on-disk hash format.
+
+    0 is the original format used in the Chromium OS.
+      The salt is appended when hashing, digests are stored continuously and
+      the rest of the block is padded with zeros.
+
+    1 is the current format that should be used for new devices.
+      The salt is prepended when hashing and each digest is
+      padded with zeros to the power of two.
+
+<dev>
+    This is the device containing data, the integrity of which needs to be
+    checked.  It may be specified as a path, like /dev/sdaX, or a device number,
+    <major>:<minor>.
+
+<hash_dev>
+    This is the device that supplies the hash tree data.  It may be
+    specified similarly to the device path and may be the same device.  If the
+    same device is used, the hash_start should be outside the configured
+    dm-verity device.
+
+<data_block_size>
+    The block size on a data device in bytes.
+    Each block corresponds to one digest on the hash device.
+
+<hash_block_size>
+    The size of a hash block in bytes.
+
+<num_data_blocks>
+    The number of data blocks on the data device.  Additional blocks are
+    inaccessible.  You can place hashes to the same partition as data, in this
+    case hashes are placed after <num_data_blocks>.
+
+<hash_start_block>
+    This is the offset, in <hash_block_size>-blocks, from the start of hash_dev
+    to the root block of the hash tree.
+
+<algorithm>
+    The cryptographic hash algorithm used for this device.  This should
+    be the name of the algorithm, like "sha1".
+
+<digest>
+    The hexadecimal encoding of the cryptographic hash of the root hash block
+    and the salt.  This hash should be trusted as there is no other authenticity
+    beyond this point.
+
+<salt>
+    The hexadecimal encoding of the salt value.
+
+Theory of operation
+===================
+
+dm-verity is meant to be set up as part of a verified boot path.  This
+may be anything ranging from a boot using tboot or trustedgrub to just
+booting from a known-good device (like a USB drive or CD).
+
+When a dm-verity device is configured, it is expected that the caller
+has been authenticated in some way (cryptographic signatures, etc).
+After instantiation, all hashes will be verified on-demand during
+disk access.  If they cannot be verified up to the root node of the
+tree, the root hash, then the I/O will fail.  This should detect
+tampering with any data on the device and the hash data.
+
+Cryptographic hashes are used to assert the integrity of the device on a
+per-block basis. This allows for a lightweight hash computation on first read
+into the page cache. Block hashes are stored linearly, aligned to the nearest
+block size.
+
+Hash Tree
+---------
+
+Each node in the tree is a cryptographic hash.  If it is a leaf node, the hash
+of some data block on disk is calculated. If it is an intermediary node,
+the hash of a number of child nodes is calculated.
+
+Each entry in the tree is a collection of neighboring nodes that fit in one
+block.  The number is determined based on block_size and the size of the
+selected cryptographic digest algorithm.  The hashes are linearly-ordered in
+this entry and any unaligned trailing space is ignored but included when
+calculating the parent node.
+
+The tree looks something like:
+
+alg = sha256, num_blocks = 32768, block_size = 4096
+
+                                 [   root    ]
+                                /    . . .    \
+                     [entry_0]                 [entry_1]
+                    /  . . .  \                 . . .   \
+         [entry_0_0]   . . .  [entry_0_127]    . . . .  [entry_1_127]
+           / ... \             /   . . .  \             /           \
+     blk_0 ... blk_127  blk_16256   blk_16383      blk_32640 . . . blk_32767
+
+
+On-disk format
+==============
+
+The verity kernel code does not read the verity metadata on-disk header.
+It only reads the hash blocks which directly follow the header.
+It is expected that a user-space tool will verify the integrity of the
+verity header.
+
+Alternatively, the header can be omitted and the dmsetup parameters can
+be passed via the kernel command-line in a rooted chain of trust where
+the command-line is verified.
+
+Directly following the header (and with sector number padded to the next hash
+block boundary) are the hash blocks which are stored a depth at a time
+(starting from the root), sorted in order of increasing index.
+
+The full specification of kernel parameters and on-disk metadata format
+is available at the cryptsetup project's wiki page
+  http://code.google.com/p/cryptsetup/wiki/DMVerity
+
+Status
+======
+V (for Valid) is returned if every check performed so far was valid.
+If any check failed, C (for Corruption) is returned.
+
+Example
+=======
+Set up a device:
+  # dmsetup create vroot --readonly --table \
+    "0 2097152 verity 1 /dev/sda1 /dev/sda2 4096 4096 262144 1 sha256 "\
+    "4392712ba01368efdf14b05c76f9e4df0d53664630b5d48632ed17a137f39076 "\
+    "1234000000000000000000000000000000000000000000000000000000000000"
+
+A command line tool veritysetup is available to compute or verify
+the hash tree or activate the kernel device. This is available from
+the cryptsetup upstream repository http://code.google.com/p/cryptsetup/
+(as a libcryptsetup extension).
+
+Create hash on the device:
+  # veritysetup format /dev/sda1 /dev/sda2
+  ...
+  Root hash: 4392712ba01368efdf14b05c76f9e4df0d53664630b5d48632ed17a137f39076
+
+Activate the device:
+  # veritysetup create vroot /dev/sda1 /dev/sda2 \
+    4392712ba01368efdf14b05c76f9e4df0d53664630b5d48632ed17a137f39076


