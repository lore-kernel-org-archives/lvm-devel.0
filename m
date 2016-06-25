From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 25 Jun 2016 19:01:36 +0000 (UTC)
Subject: master - doc: Resync kernel docs.
Message-ID: <20160625190136.460DA609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15b932a70e4a29f386ea57e1b845d637780b463b
Commit:        15b932a70e4a29f386ea57e1b845d637780b463b
Parent:        d914151591dab4ac924fe3b72fb296bc66f2e51c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jun 25 19:59:49 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jun 25 19:59:49 2016 +0100

doc: Resync kernel docs.

---
 doc/kernel/cache-policies.txt    |  102 +++++++++++++++++++++++--------------
 doc/kernel/cache.txt             |   15 +++++-
 doc/kernel/delay.txt             |    1 +
 doc/kernel/raid.txt              |   33 ++++++++++++
 doc/kernel/snapshot.txt          |   10 +++-
 doc/kernel/statistics.txt        |   47 ++++++++++++++++--
 doc/kernel/thin-provisioning.txt |    9 +++-
 doc/kernel/verity.txt            |   40 ++++++++++++++-
 8 files changed, 205 insertions(+), 52 deletions(-)

diff --git a/doc/kernel/cache-policies.txt b/doc/kernel/cache-policies.txt
index 0d124a9..d3ca8af 100644
--- a/doc/kernel/cache-policies.txt
+++ b/doc/kernel/cache-policies.txt
@@ -11,7 +11,7 @@ Every bio that is mapped by the target is referred to the policy.
 The policy can return a simple HIT or MISS or issue a migration.
 
 Currently there's no way for the policy to issue background work,
-e.g. to start writing back dirty blocks that are going to be evicte
+e.g. to start writing back dirty blocks that are going to be evicted
 soon.
 
 Because we map bios, rather than requests it's easy for the policy
@@ -25,53 +25,77 @@ trying to see when the io scheduler has let the ios run.
 Overview of supplied cache replacement policies
 ===============================================
 
-multiqueue
-----------
+multiqueue (mq)
+---------------
 
-This policy is the default.
-
-The multiqueue policy has three sets of 16 queues: one set for entries
-waiting for the cache and another two for those in the cache (a set for
-clean entries and a set for dirty entries).
+This policy is now an alias for smq (see below).
 
-Cache entries in the queues are aged based on logical time. Entry into
-the cache is based on variable thresholds and queue selection is based
-on hit count on entry. The policy aims to take different cache miss
-costs into account and to adjust to varying load patterns automatically.
+The following tunables are accepted, but have no effect:
 
-Message and constructor argument pairs are:
 	'sequential_threshold <#nr_sequential_ios>'
 	'random_threshold <#nr_random_ios>'
 	'read_promote_adjustment <value>'
 	'write_promote_adjustment <value>'
 	'discard_promote_adjustment <value>'
 
-The sequential threshold indicates the number of contiguous I/Os
-required before a stream is treated as sequential.  Once a stream is
-considered sequential it will bypass the cache.  The random threshold
-is the number of intervening non-contiguous I/Os that must be seen
-before the stream is treated as random again.
-
-The sequential and random thresholds default to 512 and 4 respectively.
-
-Large, sequential I/Os are probably better left on the origin device
-since spindles tend to have good sequential I/O bandwidth.  The
-io_tracker counts contiguous I/Os to try to spot when the I/O is in one
-of these sequential modes.  But there are use-cases for wanting to
-promote sequential blocks to the cache (e.g. fast application startup).
-If sequential threshold is set to 0 the sequential I/O detection is
-disabled and sequential I/O will no longer implicitly bypass the cache.
-Setting the random threshold to 0 does _not_ disable the random I/O
-stream detection.
-
-Internally the mq policy determines a promotion threshold.  If the hit
-count of a block not in the cache goes above this threshold it gets
-promoted to the cache.  The read, write and discard promote adjustment
-tunables allow you to tweak the promotion threshold by adding a small
-value based on the io type.  They default to 4, 8 and 1 respectively.
-If you're trying to quickly warm a new cache device you may wish to
-reduce these to encourage promotion.  Remember to switch them back to
-their defaults after the cache fills though.
+Stochastic multiqueue (smq)
+---------------------------
+
+This policy is the default.
+
+The stochastic multi-queue (smq) policy addresses some of the problems
+with the multiqueue (mq) policy.
+
+The smq policy (vs mq) offers the promise of less memory utilization,
+improved performance and increased adaptability in the face of changing
+workloads.  smq also does not have any cumbersome tuning knobs.
+
+Users may switch from "mq" to "smq" simply by appropriately reloading a
+DM table that is using the cache target.  Doing so will cause all of the
+mq policy's hints to be dropped.  Also, performance of the cache may
+degrade slightly until smq recalculates the origin device's hotspots
+that should be cached.
+
+Memory usage:
+The mq policy used a lot of memory; 88 bytes per cache block on a 64
+bit machine.
+
+smq uses 28bit indexes to implement it's data structures rather than
+pointers.  It avoids storing an explicit hit count for each block.  It
+has a 'hotspot' queue, rather than a pre-cache, which uses a quarter of
+the entries (each hotspot block covers a larger area than a single
+cache block).
+
+All this means smq uses ~25bytes per cache block.  Still a lot of
+memory, but a substantial improvement nontheless.
+
+Level balancing:
+mq placed entries in different levels of the multiqueue structures
+based on their hit count (~ln(hit count)).  This meant the bottom
+levels generally had the most entries, and the top ones had very
+few.  Having unbalanced levels like this reduced the efficacy of the
+multiqueue.
+
+smq does not maintain a hit count, instead it swaps hit entries with
+the least recently used entry from the level above.  The overall
+ordering being a side effect of this stochastic process.  With this
+scheme we can decide how many entries occupy each multiqueue level,
+resulting in better promotion/demotion decisions.
+
+Adaptability:
+The mq policy maintained a hit count for each cache block.  For a
+different block to get promoted to the cache it's hit count has to
+exceed the lowest currently in the cache.  This meant it could take a
+long time for the cache to adapt between varying IO patterns.
+
+smq doesn't maintain hit counts, so a lot of this problem just goes
+away.  In addition it tracks performance of the hotspot queue, which
+is used to decide which blocks to promote.  If the hotspot queue is
+performing badly then it starts moving entries more quickly between
+levels.  This lets it adapt to new IO patterns very quickly.
+
+Performance:
+Testing smq shows substantially better performance than mq.
 
 cleaner
 -------
diff --git a/doc/kernel/cache.txt b/doc/kernel/cache.txt
index 68c0f51..785eab8 100644
--- a/doc/kernel/cache.txt
+++ b/doc/kernel/cache.txt
@@ -221,6 +221,7 @@ Status
 <#read hits> <#read misses> <#write hits> <#write misses>
 <#demotions> <#promotions> <#dirty> <#features> <features>*
 <#core args> <core args>* <policy name> <#policy args> <policy args>*
+<cache metadata mode>
 
 metadata block size	 : Fixed block size for each metadata block in
 			     sectors
@@ -251,8 +252,18 @@ core args		 : Key/value pairs for tuning the core
 			     e.g. migration_threshold
 policy name		 : Name of the policy
 #policy args		 : Number of policy arguments to follow (must be even)
-policy args		 : Key/value pairs
-			     e.g. sequential_threshold
+policy args		 : Key/value pairs e.g. sequential_threshold
+cache metadata mode      : ro if read-only, rw if read-write
+	In serious cases where even a read-only mode is deemed unsafe
+	no further I/O will be permitted and the status will just
+	contain the string 'Fail'.  The userspace recovery tools
+	should then be used.
+needs_check		 : 'needs_check' if set, '-' if not set
+	A metadata operation has failed, resulting in the needs_check
+	flag being set in the metadata's superblock.  The metadata
+	device must be deactivated and checked/repaired before the
+	cache can be made fully operational again.  '-' indicates
+	needs_check is not set.
 
 Messages
 --------
diff --git a/doc/kernel/delay.txt b/doc/kernel/delay.txt
index 15adc55..a07b592 100644
--- a/doc/kernel/delay.txt
+++ b/doc/kernel/delay.txt
@@ -8,6 +8,7 @@ Parameters:
     <device> <offset> <delay> [<write_device> <write_offset> <write_delay>]
 
 With separate write parameters, the first set is only used for reads.
+Offsets are specified in sectors.
 Delays are specified in milliseconds.
 
 Example scripts
diff --git a/doc/kernel/raid.txt b/doc/kernel/raid.txt
index ef8ba9f..df2d636 100644
--- a/doc/kernel/raid.txt
+++ b/doc/kernel/raid.txt
@@ -209,6 +209,37 @@ include:
 	"repair" - Initiate a repair of the array.
 	"reshape"- Currently unsupported (-EINVAL).
 
+
+Discard Support
+---------------
+The implementation of discard support among hardware vendors varies.
+When a block is discarded, some storage devices will return zeroes when
+the block is read.  These devices set the 'discard_zeroes_data'
+attribute.  Other devices will return random data.  Confusingly, some
+devices that advertise 'discard_zeroes_data' will not reliably return
+zeroes when discarded blocks are read!  Since RAID 4/5/6 uses blocks
+from a number of devices to calculate parity blocks and (for performance
+reasons) relies on 'discard_zeroes_data' being reliable, it is important
+that the devices be consistent.  Blocks may be discarded in the middle
+of a RAID 4/5/6 stripe and if subsequent read results are not
+consistent, the parity blocks may be calculated differently at any time;
+making the parity blocks useless for redundancy.  It is important to
+understand how your hardware behaves with discards if you are going to
+enable discards with RAID 4/5/6.
+
+Since the behavior of storage devices is unreliable in this respect,
+even when reporting 'discard_zeroes_data', by default RAID 4/5/6
+discard support is disabled -- this ensures data integrity at the
+expense of losing some performance.
+
+Storage devices that properly support 'discard_zeroes_data' are
+increasingly whitelisted in the kernel and can thus be trusted.
+
+For trusted devices, the following dm-raid module parameter can be set
+to safely enable discard support for RAID 4/5/6:
+    'devices_handle_discards_safely'
+
+
 Version History
 ---------------
 1.0.0	Initial version.  Support for RAID 4/5/6
@@ -224,3 +255,5 @@ Version History
 	New status (STATUSTYPE_INFO) fields: sync_action and mismatch_cnt.
 1.5.1   Add ability to restore transiently failed devices on resume.
 1.5.2   'mismatch_cnt' is zero unless [last_]sync_action is "check".
+1.6.0   Add discard support (and devices_handle_discard_safely module param).
+1.7.0   Add support for MD RAID0 mappings.
diff --git a/doc/kernel/snapshot.txt b/doc/kernel/snapshot.txt
index 0d5bc46..ad6949b 100644
--- a/doc/kernel/snapshot.txt
+++ b/doc/kernel/snapshot.txt
@@ -41,9 +41,13 @@ useless and be disabled, returning errors.  So it is important to monitor
 the amount of free space and expand the <COW device> before it fills up.
 
 <persistent?> is P (Persistent) or N (Not persistent - will not survive
-after reboot).
-The difference is that for transient snapshots less metadata must be
-saved on disk - they can be kept in memory by the kernel.
+after reboot).  O (Overflow) can be added as a persistent store option
+to allow userspace to advertise its support for seeing "Overflow" in the
+snapshot status.  So supported store types are "P", "PO" and "N".
+
+The difference between persistent and transient is with transient
+snapshots less metadata must be saved on disk - they can be kept in
+memory by the kernel.
 
 
 * snapshot-merge <origin> <COW device> <persistent> <chunksize>
diff --git a/doc/kernel/statistics.txt b/doc/kernel/statistics.txt
index 2a1673a..170ac02 100644
--- a/doc/kernel/statistics.txt
+++ b/doc/kernel/statistics.txt
@@ -13,9 +13,14 @@ the range specified.
 The I/O statistics counters for each step-sized area of a region are
 in the same format as /sys/block/*/stat or /proc/diskstats (see:
 Documentation/iostats.txt).  But two extra counters (12 and 13) are
-provided: total time spent reading and writing in milliseconds.	 All
-these counters may be accessed by sending the @stats_print message to
-the appropriate DM device via dmsetup.
+provided: total time spent reading and writing.  When the histogram
+argument is used, the 14th parameter is reported that represents the
+histogram of latencies.  All these counters may be accessed by sending
+the @stats_print message to the appropriate DM device via dmsetup.
+
+The reported times are in milliseconds and the granularity depends on
+the kernel ticks.  When the option precise_timestamps is used, the
+reported times are in nanoseconds.
 
 Each region has a corresponding unique identifier, which we call a
 region_id, that is assigned when the region is created.	 The region_id
@@ -33,7 +38,9 @@ memory is used by reading
 Messages
 ========
 
-    @stats_create <range> <step> [<program_id> [<aux_data>]]
+    @stats_create <range> <step>
+		[<number_of_optional_arguments> <optional_arguments>...]
+		[<program_id> [<aux_data>]]
 
 	Create a new region and return the region_id.
 
@@ -48,6 +55,29 @@ Messages
 	  "/<number_of_areas>" - the range is subdivided into the specified
 				 number of areas.
 
+	<number_of_optional_arguments>
+	  The number of optional arguments
+
+	<optional_arguments>
+	  The following optional arguments are supported
+	  precise_timestamps - use precise timer with nanosecond resolution
+		instead of the "jiffies" variable.  When this argument is
+		used, the resulting times are in nanoseconds instead of
+		milliseconds.  Precise timestamps are a little bit slower
+		to obtain than jiffies-based timestamps.
+	  histogram:n1,n2,n3,n4,... - collect histogram of latencies.  The
+		numbers n1, n2, etc are times that represent the boundaries
+		of the histogram.  If precise_timestamps is not used, the
+		times are in milliseconds, otherwise they are in
+		nanoseconds.  For each range, the kernel will report the
+		number of requests that completed within this range. For
+		example, if we use "histogram:10,20,30", the kernel will
+		report four numbers a:b:c:d. a is the number of requests
+		that took 0-10 ms to complete, b is the number of requests
+		that took 10-20 ms to complete, c is the number of requests
+		that took 20-30 ms to complete and d is the number of
+		requests that took more than 30 ms to complete.
+
 	<program_id>
 	  An optional parameter.  A name that uniquely identifies
 	  the userspace owner of the range.  This groups ranges together
@@ -55,6 +85,9 @@ Messages
 	  created and ignore those created by others.
 	  The kernel returns this string back in the output of
 	  @stats_list message, but it doesn't use it for anything else.
+	  If we omit the number of optional arguments, program id must not
+	  be a number, otherwise it would be interpreted as the number of
+	  optional arguments.
 
 	<aux_data>
 	  An optional parameter.  A word that provides auxiliary data
@@ -88,6 +121,10 @@ Messages
 
 	Output format:
 	  <region_id>: <start_sector>+<length> <step> <program_id> <aux_data>
+	        precise_timestamps histogram:n1,n2,n3,...
+
+	The strings "precise_timestamps" and "histogram" are printed only
+	if they were specified when creating the region.
 
     @stats_print <region_id> [<starting_line> <number_of_lines>]
 
@@ -168,7 +205,7 @@ statistics on them:
 
   dmsetup message vol 0 @stats_create - /100
 
-Set the auxillary data string to "foo bar baz" (the escape for each
+Set the auxiliary data string to "foo bar baz" (the escape for each
 space must also be escaped, otherwise the shell will consume them):
 
   dmsetup message vol 0 @stats_set_aux 0 foo\\ bar\\ baz
diff --git a/doc/kernel/thin-provisioning.txt b/doc/kernel/thin-provisioning.txt
index 4f67578..1699a55 100644
--- a/doc/kernel/thin-provisioning.txt
+++ b/doc/kernel/thin-provisioning.txt
@@ -296,7 +296,7 @@ ii) Status
 	underlying device.  When this is enabled when loading the table,
 	it can get disabled if the underlying device doesn't support it.
 
-    ro|rw
+    ro|rw|out_of_data_space
 	If the pool encounters certain types of device failures it will
 	drop into a read-only metadata mode in which no changes to
 	the pool metadata (like allocating new blocks) are permitted.
@@ -314,6 +314,13 @@ ii) Status
 	module parameter can be used to change this timeout -- it
 	defaults to 60 seconds but may be disabled using a value of 0.
 
+    needs_check
+	A metadata operation has failed, resulting in the needs_check
+	flag being set in the metadata's superblock.  The metadata
+	device must be deactivated and checked/repaired before the
+	thin-pool can be made fully operational again.  '-' indicates
+	needs_check is not set.
+
 iii) Messages
 
     create_thin <dev id>
diff --git a/doc/kernel/verity.txt b/doc/kernel/verity.txt
index e15bc1a..89fd8f9 100644
--- a/doc/kernel/verity.txt
+++ b/doc/kernel/verity.txt
@@ -18,11 +18,11 @@ Construction Parameters
 
     0 is the original format used in the Chromium OS.
       The salt is appended when hashing, digests are stored continuously and
-      the rest of the block is padded with zeros.
+      the rest of the block is padded with zeroes.
 
     1 is the current format that should be used for new devices.
       The salt is prepended when hashing and each digest is
-      padded with zeros to the power of two.
+      padded with zeroes to the power of two.
 
 <dev>
     This is the device containing data, the integrity of which needs to be
@@ -79,6 +79,37 @@ restart_on_corruption
     not compatible with ignore_corruption and requires user space support to
     avoid restart loops.
 
+ignore_zero_blocks
+    Do not verify blocks that are expected to contain zeroes and always return
+    zeroes instead. This may be useful if the partition contains unused blocks
+    that are not guaranteed to contain zeroes.
+
+use_fec_from_device <fec_dev>
+    Use forward error correction (FEC) to recover from corruption if hash
+    verification fails. Use encoding data from the specified device. This
+    may be the same device where data and hash blocks reside, in which case
+    fec_start must be outside data and hash areas.
+
+    If the encoding data covers additional metadata, it must be accessible
+    on the hash device after the hash blocks.
+
+    Note: block sizes for data and hash devices must match. Also, if the
+    verity <dev> is encrypted the <fec_dev> should be too.
+
+fec_roots <num>
+    Number of generator roots. This equals to the number of parity bytes in
+    the encoding data. For example, in RS(M, N) encoding, the number of roots
+    is M-N.
+
+fec_blocks <num>
+    The number of encoding data blocks on the FEC device. The block size for
+    the FEC device is <data_block_size>.
+
+fec_start <offset>
+    This is the offset, in <data_block_size> blocks, from the start of the
+    FEC device to the beginning of the encoding data.
+
+
 Theory of operation
 ===================
 
@@ -98,6 +129,11 @@ per-block basis. This allows for a lightweight hash computation on first read
 into the page cache. Block hashes are stored linearly, aligned to the nearest
 block size.
 
+If forward error correction (FEC) support is enabled any recovery of
+corrupted data will be verified using the cryptographic hash of the
+corresponding data. This is why combining error correction with
+integrity checking is essential.
+
 Hash Tree
 ---------
 


