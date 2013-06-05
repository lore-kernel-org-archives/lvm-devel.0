From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:41 +0000 (UTC)
Subject: dev-mornfall-lvmcache - doc: update dm kernel files to 3.10-rc1
Message-ID: <20130605120341.36DF16116D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fca5acd072a9ab4899a76e421c714ca14df3e516
Commit:        fca5acd072a9ab4899a76e421c714ca14df3e516
Parent:        06ac797f420e0af50fb23dbb85a3b5f908918e6a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri May 17 16:05:17 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri May 17 16:05:17 2013 +0100

doc: update dm kernel files to 3.10-rc1

---
 doc/kernel/cache-policies.txt    |   77 ++++++++++++
 doc/kernel/cache.txt             |  243 ++++++++++++++++++++++++++++++++++++++
 doc/kernel/raid.txt              |  146 ++++++++++++++++++++---
 doc/kernel/thin-provisioning.txt |   24 ++++-
 4 files changed, 474 insertions(+), 16 deletions(-)

diff --git a/doc/kernel/cache-policies.txt b/doc/kernel/cache-policies.txt
new file mode 100644
index 0000000..d7c440b
--- /dev/null
+++ b/doc/kernel/cache-policies.txt
@@ -0,0 +1,77 @@
+Guidance for writing policies
+=============================
+
+Try to keep transactionality out of it.  The core is careful to
+avoid asking about anything that is migrating.  This is a pain, but
+makes it easier to write the policies.
+
+Mappings are loaded into the policy at construction time.
+
+Every bio that is mapped by the target is referred to the policy.
+The policy can return a simple HIT or MISS or issue a migration.
+
+Currently there's no way for the policy to issue background work,
+e.g. to start writing back dirty blocks that are going to be evicte
+soon.
+
+Because we map bios, rather than requests it's easy for the policy
+to get fooled by many small bios.  For this reason the core target
+issues periodic ticks to the policy.  It's suggested that the policy
+doesn't update states (eg, hit counts) for a block more than once
+for each tick.  The core ticks by watching bios complete, and so
+trying to see when the io scheduler has let the ios run.
+
+
+Overview of supplied cache replacement policies
+===============================================
+
+multiqueue
+----------
+
+This policy is the default.
+
+The multiqueue policy has two sets of 16 queues: one set for entries
+waiting for the cache and another one for those in the cache.
+Cache entries in the queues are aged based on logical time. Entry into
+the cache is based on variable thresholds and queue selection is based
+on hit count on entry. The policy aims to take different cache miss
+costs into account and to adjust to varying load patterns automatically.
+
+Message and constructor argument pairs are:
+	'sequential_threshold <#nr_sequential_ios>' and
+	'random_threshold <#nr_random_ios>'.
+
+The sequential threshold indicates the number of contiguous I/Os
+required before a stream is treated as sequential.  The random threshold
+is the number of intervening non-contiguous I/Os that must be seen
+before the stream is treated as random again.
+
+The sequential and random thresholds default to 512 and 4 respectively.
+
+Large, sequential ios are probably better left on the origin device
+since spindles tend to have good bandwidth. The io_tracker counts
+contiguous I/Os to try to spot when the io is in one of these sequential
+modes.
+
+cleaner
+-------
+
+The cleaner writes back all dirty blocks in a cache to decommission it.
+
+Examples
+========
+
+The syntax for a table is:
+	cache <metadata dev> <cache dev> <origin dev> <block size>
+	<#feature_args> [<feature arg>]*
+	<policy> <#policy_args> [<policy arg>]*
+
+The syntax to send a message using the dmsetup command is:
+	dmsetup message <mapped device> 0 sequential_threshold 1024
+	dmsetup message <mapped device> 0 random_threshold 8
+
+Using dmsetup:
+	dmsetup create blah --table "0 268435456 cache /dev/sdb /dev/sdc \
+	    /dev/sdd 512 0 mq 4 sequential_threshold 1024 random_threshold 8"
+	creates a 128GB large mapped device named 'blah' with the
+	sequential threshold set to 1024 and the random_threshold set to 8.
diff --git a/doc/kernel/cache.txt b/doc/kernel/cache.txt
new file mode 100644
index 0000000..f50470a
--- /dev/null
+++ b/doc/kernel/cache.txt
@@ -0,0 +1,243 @@
+Introduction
+============
+
+dm-cache is a device mapper target written by Joe Thornber, Heinz
+Mauelshagen, and Mike Snitzer.
+
+It aims to improve performance of a block device (eg, a spindle) by
+dynamically migrating some of its data to a faster, smaller device
+(eg, an SSD).
+
+This device-mapper solution allows us to insert this caching at
+different levels of the dm stack, for instance above the data device for
+a thin-provisioning pool.  Caching solutions that are integrated more
+closely with the virtual memory system should give better performance.
+
+The target reuses the metadata library used in the thin-provisioning
+library.
+
+The decision as to what data to migrate and when is left to a plug-in
+policy module.  Several of these have been written as we experiment,
+and we hope other people will contribute others for specific io
+scenarios (eg. a vm image server).
+
+Glossary
+========
+
+  Migration -  Movement of the primary copy of a logical block from one
+	       device to the other.
+  Promotion -  Migration from slow device to fast device.
+  Demotion  -  Migration from fast device to slow device.
+
+The origin device always contains a copy of the logical block, which
+may be out of date or kept in sync with the copy on the cache device
+(depending on policy).
+
+Design
+======
+
+Sub-devices
+-----------
+
+The target is constructed by passing three devices to it (along with
+other parameters detailed later):
+
+1. An origin device - the big, slow one.
+
+2. A cache device - the small, fast one.
+
+3. A small metadata device - records which blocks are in the cache,
+   which are dirty, and extra hints for use by the policy object.
+   This information could be put on the cache device, but having it
+   separate allows the volume manager to configure it differently,
+   e.g. as a mirror for extra robustness.
+
+Fixed block size
+----------------
+
+The origin is divided up into blocks of a fixed size.  This block size
+is configurable when you first create the cache.  Typically we've been
+using block sizes of 256k - 1024k.
+
+Having a fixed block size simplifies the target a lot.  But it is
+something of a compromise.  For instance, a small part of a block may be
+getting hit a lot, yet the whole block will be promoted to the cache.
+So large block sizes are bad because they waste cache space.  And small
+block sizes are bad because they increase the amount of metadata (both
+in core and on disk).
+
+Writeback/writethrough
+----------------------
+
+The cache has two modes, writeback and writethrough.
+
+If writeback, the default, is selected then a write to a block that is
+cached will go only to the cache and the block will be marked dirty in
+the metadata.
+
+If writethrough is selected then a write to a cached block will not
+complete until it has hit both the origin and cache devices.  Clean
+blocks should remain clean.
+
+A simple cleaner policy is provided, which will clean (write back) all
+dirty blocks in a cache.  Useful for decommissioning a cache.
+
+Migration throttling
+--------------------
+
+Migrating data between the origin and cache device uses bandwidth.
+The user can set a throttle to prevent more than a certain amount of
+migration occuring at any one time.  Currently we're not taking any
+account of normal io traffic going to the devices.  More work needs
+doing here to avoid migrating during those peak io moments.
+
+For the time being, a message "migration_threshold <#sectors>"
+can be used to set the maximum number of sectors being migrated,
+the default being 204800 sectors (or 100MB).
+
+Updating on-disk metadata
+-------------------------
+
+On-disk metadata is committed every time a REQ_SYNC or REQ_FUA bio is
+written.  If no such requests are made then commits will occur every
+second.  This means the cache behaves like a physical disk that has a
+write cache (the same is true of the thin-provisioning target).  If
+power is lost you may lose some recent writes.  The metadata should
+always be consistent in spite of any crash.
+
+The 'dirty' state for a cache block changes far too frequently for us
+to keep updating it on the fly.  So we treat it as a hint.  In normal
+operation it will be written when the dm device is suspended.  If the
+system crashes all cache blocks will be assumed dirty when restarted.
+
+Per-block policy hints
+----------------------
+
+Policy plug-ins can store a chunk of data per cache block.  It's up to
+the policy how big this chunk is, but it should be kept small.  Like the
+dirty flags this data is lost if there's a crash so a safe fallback
+value should always be possible.
+
+For instance, the 'mq' policy, which is currently the default policy,
+uses this facility to store the hit count of the cache blocks.  If
+there's a crash this information will be lost, which means the cache
+may be less efficient until those hit counts are regenerated.
+
+Policy hints affect performance, not correctness.
+
+Policy messaging
+----------------
+
+Policies will have different tunables, specific to each one, so we
+need a generic way of getting and setting these.  Device-mapper
+messages are used.  Refer to cache-policies.txt.
+
+Discard bitset resolution
+-------------------------
+
+We can avoid copying data during migration if we know the block has
+been discarded.  A prime example of this is when mkfs discards the
+whole block device.  We store a bitset tracking the discard state of
+blocks.  However, we allow this bitset to have a different block size
+from the cache blocks.  This is because we need to track the discard
+state for all of the origin device (compare with the dirty bitset
+which is just for the smaller cache device).
+
+Target interface
+================
+
+Constructor
+-----------
+
+ cache <metadata dev> <cache dev> <origin dev> <block size>
+       <#feature args> [<feature arg>]*
+       <policy> <#policy args> [policy args]*
+
+ metadata dev    : fast device holding the persistent metadata
+ cache dev	 : fast device holding cached data blocks
+ origin dev	 : slow device holding original data blocks
+ block size      : cache unit size in sectors
+
+ #feature args   : number of feature arguments passed
+ feature args    : writethrough.  (The default is writeback.)
+
+ policy          : the replacement policy to use
+ #policy args    : an even number of arguments corresponding to
+                   key/value pairs passed to the policy
+ policy args     : key/value pairs passed to the policy
+		   E.g. 'sequential_threshold 1024'
+		   See cache-policies.txt for details.
+
+Optional feature arguments are:
+   writethrough  : write through caching that prohibits cache block
+		   content from being different from origin block content.
+		   Without this argument, the default behaviour is to write
+		   back cache block contents later for performance reasons,
+		   so they may differ from the corresponding origin blocks.
+
+A policy called 'default' is always registered.  This is an alias for
+the policy we currently think is giving best all round performance.
+
+As the default policy could vary between kernels, if you are relying on
+the characteristics of a specific policy, always request it by name.
+
+Status
+------
+
+<#used metadata blocks>/<#total metadata blocks> <#read hits> <#read misses>
+<#write hits> <#write misses> <#demotions> <#promotions> <#blocks in cache>
+<#dirty> <#features> <features>* <#core args> <core args>* <#policy args>
+<policy args>*
+
+#used metadata blocks    : Number of metadata blocks used
+#total metadata blocks   : Total number of metadata blocks
+#read hits               : Number of times a READ bio has been mapped
+			     to the cache
+#read misses             : Number of times a READ bio has been mapped
+			     to the origin
+#write hits              : Number of times a WRITE bio has been mapped
+			     to the cache
+#write misses            : Number of times a WRITE bio has been
+			     mapped to the origin
+#demotions               : Number of times a block has been removed
+			     from the cache
+#promotions              : Number of times a block has been moved to
+			     the cache
+#blocks in cache         : Number of blocks resident in the cache
+#dirty                   : Number of blocks in the cache that differ
+			     from the origin
+#feature args            : Number of feature args to follow
+feature args             : 'writethrough' (optional)
+#core args               : Number of core arguments (must be even)
+core args                : Key/value pairs for tuning the core
+			     e.g. migration_threshold
+#policy args             : Number of policy arguments to follow (must be even)
+policy args              : Key/value pairs
+			     e.g. 'sequential_threshold 1024
+
+Messages
+--------
+
+Policies will have different tunables, specific to each one, so we
+need a generic way of getting and setting these.  Device-mapper
+messages are used.  (A sysfs interface would also be possible.)
+
+The message format is:
+
+   <key> <value>
+
+E.g.
+   dmsetup message my_cache 0 sequential_threshold 1024
+
+Examples
+========
+
+The test suite can be found here:
+
+https://github.com/jthornber/thinp-test-suite
+
+dmsetup create my_cache --table '0 41943040 cache /dev/mapper/metadata \
+	/dev/mapper/ssd /dev/mapper/origin 512 1 writeback default 0'
+dmsetup create my_cache --table '0 41943040 cache /dev/mapper/metadata \
+	/dev/mapper/ssd /dev/mapper/origin 1024 1 writeback \
+	mq 4 sequential_threshold 1024 random_threshold 8'
diff --git a/doc/kernel/raid.txt b/doc/kernel/raid.txt
index 946c733..e919228 100644
--- a/doc/kernel/raid.txt
+++ b/doc/kernel/raid.txt
@@ -1,10 +1,13 @@
 dm-raid
--------
+=======
 
 The device-mapper RAID (dm-raid) target provides a bridge from DM to MD.
 It allows the MD RAID drivers to be accessed using a device-mapper
 interface.
 
+
+Mapping Table Interface
+-----------------------
 The target is named "raid" and it accepts the following parameters:
 
   <raid_type> <#raid_params> <raid_params> \
@@ -27,6 +30,11 @@ The target is named "raid" and it accepts the following parameters:
 		- rotating parity N (right-to-left) with data restart
   raid6_nc	RAID6 N continue
 		- rotating parity N (right-to-left) with data continuation
+  raid10        Various RAID10 inspired algorithms chosen by additional params
+		- RAID10: Striped Mirrors (aka 'Striping on top of mirrors')
+		- RAID1E: Integrated Adjacent Stripe Mirroring
+		- RAID1E: Integrated Offset Stripe Mirroring
+		-  and other similar RAID10 variants
 
   Reference: Chapter 4 of
   http://www.snia.org/sites/default/files/SNIA_DDF_Technical_Position_v2.0.pdf
@@ -42,7 +50,7 @@ The target is named "raid" and it accepts the following parameters:
     followed by optional parameters (in any order):
 	[sync|nosync]   Force or prevent RAID initialization.
 
-	[rebuild <idx>]	Rebuild drive number idx (first drive is 0).
+	[rebuild <idx>]	Rebuild drive number 'idx' (first drive is 0).
 
 	[daemon_sleep <ms>]
 		Interval between runs of the bitmap daemon that
@@ -51,14 +59,63 @@ The target is named "raid" and it accepts the following parameters:
 
 	[min_recovery_rate <kB/sec/disk>]  Throttle RAID initialization
 	[max_recovery_rate <kB/sec/disk>]  Throttle RAID initialization
-	[write_mostly <idx>]		   Drive index is write-mostly
-	[max_write_behind <sectors>]       See '-write-behind=' (man mdadm)
-	[stripe_cache <sectors>]           Stripe cache size (higher RAIDs only)
+	[write_mostly <idx>]		   Mark drive index 'idx' write-mostly.
+	[max_write_behind <sectors>]       See '--write-behind=' (man mdadm)
+	[stripe_cache <sectors>]           Stripe cache size (RAID 4/5/6 only)
 	[region_size <sectors>]
 		The region_size multiplied by the number of regions is the
 		logical size of the array.  The bitmap records the device
 		synchronisation state for each region.
 
+        [raid10_copies   <# copies>]
+        [raid10_format   <near|far|offset>]
+		These two options are used to alter the default layout of
+		a RAID10 configuration.  The number of copies is can be
+		specified, but the default is 2.  There are also three
+		variations to how the copies are laid down - the default
+		is "near".  Near copies are what most people think of with
+		respect to mirroring.  If these options are left unspecified,
+		or 'raid10_copies 2' and/or 'raid10_format near' are given,
+		then the layouts for 2, 3 and 4 devices	are:
+		2 drives         3 drives          4 drives
+		--------         ----------        --------------
+		A1  A1           A1  A1  A2        A1  A1  A2  A2
+		A2  A2           A2  A3  A3        A3  A3  A4  A4
+		A3  A3           A4  A4  A5        A5  A5  A6  A6
+		A4  A4           A5  A6  A6        A7  A7  A8  A8
+		..  ..           ..  ..  ..        ..  ..  ..  ..
+		The 2-device layout is equivalent 2-way RAID1.  The 4-device
+		layout is what a traditional RAID10 would look like.  The
+		3-device layout is what might be called a 'RAID1E - Integrated
+		Adjacent Stripe Mirroring'.
+
+		If 'raid10_copies 2' and 'raid10_format far', then the layouts
+		for 2, 3 and 4 devices are:
+		2 drives             3 drives             4 drives
+		--------             --------------       --------------------
+		A1  A2               A1   A2   A3         A1   A2   A3   A4
+		A3  A4               A4   A5   A6         A5   A6   A7   A8
+		A5  A6               A7   A8   A9         A9   A10  A11  A12
+		..  ..               ..   ..   ..         ..   ..   ..   ..
+		A2  A1               A3   A1   A2         A2   A1   A4   A3
+		A4  A3               A6   A4   A5         A6   A5   A8   A7
+		A6  A5               A9   A7   A8         A10  A9   A12  A11
+		..  ..               ..   ..   ..         ..   ..   ..   ..
+
+		If 'raid10_copies 2' and 'raid10_format offset', then the
+		layouts for 2, 3 and 4 devices are:
+		2 drives       3 drives           4 drives
+		--------       ------------       -----------------
+		A1  A2         A1  A2  A3         A1  A2  A3  A4
+		A2  A1         A3  A1  A2         A2  A1  A4  A3
+		A3  A4         A4  A5  A6         A5  A6  A7  A8
+		A4  A3         A6  A4  A5         A6  A5  A8  A7
+		A5  A6         A7  A8  A9         A9  A10 A11 A12
+		A6  A5         A9  A7  A8         A10 A9  A12 A11
+		..  ..         ..  ..  ..         ..  ..  ..  ..
+		Here we see layouts closely akin to 'RAID1E - Integrated
+		Offset Stripe Mirroring'.
+
 <#raid_devs>: The number of devices composing the array.
 	Each device consists of two entries.  The first is the device
 	containing the metadata (if any); the second is the one containing the
@@ -68,7 +125,7 @@ The target is named "raid" and it accepts the following parameters:
 	given for both the metadata and data drives for a given position.
 
 
-Example tables
+Example Tables
 --------------
 # RAID4 - 4 data drives, 1 parity (no metadata devices)
 # No metadata devices specified to hold superblock/bitmap info
@@ -87,22 +144,81 @@ Example tables
         raid4 4 2048 sync min_recovery_rate 20 \
         5 8:17 8:18 8:33 8:34 8:49 8:50 8:65 8:66 8:81 8:82
 
+
+Status Output
+-------------
 'dmsetup table' displays the table used to construct the mapping.
 The optional parameters are always printed in the order listed
 above with "sync" or "nosync" always output ahead of the other
 arguments, regardless of the order used when originally loading the table.
 Arguments that can be repeated are ordered by value.
 
-'dmsetup status' yields information on the state and health of the
-array.
-The output is as follows:
+
+'dmsetup status' yields information on the state and health of the array.
+The output is as follows (normally a single line, but expanded here for
+clarity):
 1: <s> <l> raid \
-2:      <raid_type> <#devices> <1 health char for each dev> <resync_ratio>
+2:      <raid_type> <#devices> <health_chars> \
+3:      <sync_ratio> <sync_action> <mismatch_cnt>
 
 Line 1 is the standard output produced by device-mapper.
-Line 2 is produced by the raid target, and best explained by example:
-        0 1960893648 raid raid4 5 AAAAA 2/490221568
+Line 2 & 3 are produced by the raid target and are best explained by example:
+        0 1960893648 raid raid4 5 AAAAA 2/490221568 init 0
 Here we can see the RAID type is raid4, there are 5 devices - all of
-which are 'A'live, and the array is 2/490221568 complete with recovery.
-Faulty or missing devices are marked 'D'.  Devices that are out-of-sync
-are marked 'a'.
+which are 'A'live, and the array is 2/490221568 complete with its initial
+recovery.  Here is a fuller description of the individual fields:
+	<raid_type>     Same as the <raid_type> used to create the array.
+	<health_chars>  One char for each device, indicating: 'A' = alive and
+			in-sync, 'a' = alive but not in-sync, 'D' = dead/failed.
+	<sync_ratio>    The ratio indicating how much of the array has undergone
+			the process described by 'sync_action'.  If the
+			'sync_action' is "check" or "repair", then the process
+			of "resync" or "recover" can be considered complete.
+	<sync_action>   One of the following possible states:
+			idle    - No synchronization action is being performed.
+			frozen  - The current action has been halted.
+			resync  - Array is undergoing its initial synchronization
+				  or is resynchronizing after an unclean shutdown
+				  (possibly aided by a bitmap).
+			recover - A device in the array is being rebuilt or
+				  replaced.
+			check   - A user-initiated full check of the array is
+				  being performed.  All blocks are read and
+				  checked for consistency.  The number of
+				  discrepancies found are recorded in
+				  <mismatch_cnt>.  No changes are made to the
+				  array by this action.
+			repair  - The same as "check", but discrepancies are
+				  corrected.
+			reshape - The array is undergoing a reshape.
+	<mismatch_cnt>  The number of discrepancies found between mirror copies
+			in RAID1/10 or wrong parity values found in RAID4/5/6.
+			This value is valid only after a "check" of the array
+			is performed.  A healthy array has a 'mismatch_cnt' of 0.
+
+Message Interface
+-----------------
+The dm-raid target will accept certain actions through the 'message' interface.
+('man dmsetup' for more information on the message interface.)  These actions
+include:
+	"idle"   - Halt the current sync action.
+	"frozen" - Freeze the current sync action.
+	"resync" - Initiate/continue a resync.
+	"recover"- Initiate/continue a recover process.
+	"check"  - Initiate a check (i.e. a "scrub") of the array.
+	"repair" - Initiate a repair of the array.
+	"reshape"- Currently unsupported (-EINVAL).
+
+Version History
+---------------
+1.0.0	Initial version.  Support for RAID 4/5/6
+1.1.0	Added support for RAID 1
+1.2.0	Handle creation of arrays that contain failed devices.
+1.3.0	Added support for RAID 10
+1.3.1	Allow device replacement/rebuild for RAID 10
+1.3.2   Fix/improve redundancy checking for RAID10
+1.4.0	Non-functional change.  Removes arg from mapping function.
+1.4.1   RAID10 fix redundancy validation checks (commit 55ebbb5).
+1.4.2   Add RAID10 "far" and "offset" algorithm support.
+1.5.0   Add message interface to allow manipulation of the sync_action.
+	New status (STATUSTYPE_INFO) fields: sync_action and mismatch_cnt.
diff --git a/doc/kernel/thin-provisioning.txt b/doc/kernel/thin-provisioning.txt
index f5cfc62..30b8b83 100644
--- a/doc/kernel/thin-provisioning.txt
+++ b/doc/kernel/thin-provisioning.txt
@@ -231,6 +231,9 @@ i) Constructor
       no_discard_passdown: Don't pass discards down to the underlying
 			   data device, but just remove the mapping.
 
+      read_only: Don't allow any changes to be made to the pool
+		 metadata.
+
     Data block size must be between 64KB (128 sectors) and 1GB
     (2097152 sectors) inclusive.
 
@@ -239,7 +242,7 @@ ii) Status
 
     <transaction id> <used metadata blocks>/<total metadata blocks>
     <used data blocks>/<total data blocks> <held metadata root>
-
+    [no_]discard_passdown ro|rw
 
     transaction id:
 	A 64-bit number used by userspace to help synchronise with metadata
@@ -257,6 +260,21 @@ ii) Status
 	held root.  This feature is not yet implemented so '-' is
 	always returned.
 
+    discard_passdown|no_discard_passdown
+	Whether or not discards are actually being passed down to the
+	underlying device.  When this is enabled when loading the table,
+	it can get disabled if the underlying device doesn't support it.
+
+    ro|rw
+	If the pool encounters certain types of device failures it will
+	drop into a read-only metadata mode in which no changes to
+	the pool metadata (like allocating new blocks) are permitted.
+
+	In serious cases where even a read-only mode is deemed unsafe
+	no further I/O will be permitted and the status will just
+	contain the string 'Fail'.  The userspace recovery tools
+	should then be used.
+
 iii) Messages
 
     create_thin <dev id>
@@ -329,3 +347,7 @@ regain some space then send the 'trim' message to the pool.
 ii) Status
 
      <nr mapped sectors> <highest mapped sector>
+
+	If the pool has encountered device errors and failed, the status
+	will just contain the string 'Fail'.  The userspace recovery
+	tools should then be used.


