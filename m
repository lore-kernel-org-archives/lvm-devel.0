From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 22 Apr 2015 14:36:36 +0000 (UTC)
Subject: master - doc: Update dm kernel files.
Message-ID: <20150422143636.8BE5F61144@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81d03b46b01de3f082e4dcd0eb9993c64be0686e
Commit:        81d03b46b01de3f082e4dcd0eb9993c64be0686e
Parent:        2fea7208810ace2b4ab08408d12ab5e728f498b0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Apr 22 15:34:25 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Apr 22 15:34:25 2015 +0100

doc: Update dm kernel files.

v4.0-9804-gdb4fd9c
---
 doc/kernel/cache-policies.txt    |   38 ++++++--
 doc/kernel/cache.txt             |  129 +++++++++++++++++++--------
 doc/kernel/crypt.txt             |   28 +++++-
 doc/kernel/era.txt               |  108 ++++++++++++++++++++++
 doc/kernel/log-writes.txt        |  140 ++++++++++++++++++++++++++++
 doc/kernel/raid.txt              |    2 +
 doc/kernel/statistics.txt        |  186 ++++++++++++++++++++++++++++++++++++++
 doc/kernel/switch.txt            |  138 ++++++++++++++++++++++++++++
 doc/kernel/thin-provisioning.txt |   62 ++++++++++---
 doc/kernel/verity.txt            |   21 ++++-
 10 files changed, 787 insertions(+), 65 deletions(-)

diff --git a/doc/kernel/cache-policies.txt b/doc/kernel/cache-policies.txt
index d7c440b..0d124a9 100644
--- a/doc/kernel/cache-policies.txt
+++ b/doc/kernel/cache-policies.txt
@@ -30,28 +30,48 @@ multiqueue
 
 This policy is the default.
 
-The multiqueue policy has two sets of 16 queues: one set for entries
-waiting for the cache and another one for those in the cache.
+The multiqueue policy has three sets of 16 queues: one set for entries
+waiting for the cache and another two for those in the cache (a set for
+clean entries and a set for dirty entries).
+
 Cache entries in the queues are aged based on logical time. Entry into
 the cache is based on variable thresholds and queue selection is based
 on hit count on entry. The policy aims to take different cache miss
 costs into account and to adjust to varying load patterns automatically.
 
 Message and constructor argument pairs are:
-	'sequential_threshold <#nr_sequential_ios>' and
-	'random_threshold <#nr_random_ios>'.
+	'sequential_threshold <#nr_sequential_ios>'
+	'random_threshold <#nr_random_ios>'
+	'read_promote_adjustment <value>'
+	'write_promote_adjustment <value>'
+	'discard_promote_adjustment <value>'
 
 The sequential threshold indicates the number of contiguous I/Os
-required before a stream is treated as sequential.  The random threshold
+required before a stream is treated as sequential.  Once a stream is
+considered sequential it will bypass the cache.  The random threshold
 is the number of intervening non-contiguous I/Os that must be seen
 before the stream is treated as random again.
 
 The sequential and random thresholds default to 512 and 4 respectively.
 
-Large, sequential ios are probably better left on the origin device
-since spindles tend to have good bandwidth. The io_tracker counts
-contiguous I/Os to try to spot when the io is in one of these sequential
-modes.
+Large, sequential I/Os are probably better left on the origin device
+since spindles tend to have good sequential I/O bandwidth.  The
+io_tracker counts contiguous I/Os to try to spot when the I/O is in one
+of these sequential modes.  But there are use-cases for wanting to
+promote sequential blocks to the cache (e.g. fast application startup).
+If sequential threshold is set to 0 the sequential I/O detection is
+disabled and sequential I/O will no longer implicitly bypass the cache.
+Setting the random threshold to 0 does _not_ disable the random I/O
+stream detection.
+
+Internally the mq policy determines a promotion threshold.  If the hit
+count of a block not in the cache goes above this threshold it gets
+promoted to the cache.  The read, write and discard promote adjustment
+tunables allow you to tweak the promotion threshold by adding a small
+value based on the io type.  They default to 4, 8 and 1 respectively.
+If you're trying to quickly warm a new cache device you may wish to
+reduce these to encourage promotion.  Remember to switch them back to
+their defaults after the cache fills though.
 
 cleaner
 -------
diff --git a/doc/kernel/cache.txt b/doc/kernel/cache.txt
index f50470a..68c0f51 100644
--- a/doc/kernel/cache.txt
+++ b/doc/kernel/cache.txt
@@ -50,14 +50,16 @@ other parameters detailed later):
    which are dirty, and extra hints for use by the policy object.
    This information could be put on the cache device, but having it
    separate allows the volume manager to configure it differently,
-   e.g. as a mirror for extra robustness.
+   e.g. as a mirror for extra robustness.  This metadata device may only
+   be used by a single cache device.
 
 Fixed block size
 ----------------
 
 The origin is divided up into blocks of a fixed size.  This block size
 is configurable when you first create the cache.  Typically we've been
-using block sizes of 256k - 1024k.
+using block sizes of 256KB - 1024KB.  The block size must be between 64
+(32KB) and 2097152 (1GB) and a multiple of 64 (32KB).
 
 Having a fixed block size simplifies the target a lot.  But it is
 something of a compromise.  For instance, a small part of a block may be
@@ -66,10 +68,11 @@ So large block sizes are bad because they waste cache space.  And small
 block sizes are bad because they increase the amount of metadata (both
 in core and on disk).
 
-Writeback/writethrough
-----------------------
+Cache operating modes
+---------------------
 
-The cache has two modes, writeback and writethrough.
+The cache has three operating modes: writeback, writethrough and
+passthrough.
 
 If writeback, the default, is selected then a write to a block that is
 cached will go only to the cache and the block will be marked dirty in
@@ -79,15 +82,38 @@ If writethrough is selected then a write to a cached block will not
 complete until it has hit both the origin and cache devices.  Clean
 blocks should remain clean.
 
+If passthrough is selected, useful when the cache contents are not known
+to be coherent with the origin device, then all reads are served from
+the origin device (all reads miss the cache) and all writes are
+forwarded to the origin device; additionally, write hits cause cache
+block invalidates.  To enable passthrough mode the cache must be clean.
+Passthrough mode allows a cache device to be activated without having to
+worry about coherency.  Coherency that exists is maintained, although
+the cache will gradually cool as writes take place.  If the coherency of
+the cache can later be verified, or established through use of the
+"invalidate_cblocks" message, the cache device can be transitioned to
+writethrough or writeback mode while still warm.  Otherwise, the cache
+contents can be discarded prior to transitioning to the desired
+operating mode.
+
 A simple cleaner policy is provided, which will clean (write back) all
-dirty blocks in a cache.  Useful for decommissioning a cache.
+dirty blocks in a cache.  Useful for decommissioning a cache or when
+shrinking a cache.  Shrinking the cache's fast device requires all cache
+blocks, in the area of the cache being removed, to be clean.  If the
+area being removed from the cache still contains dirty blocks the resize
+will fail.  Care must be taken to never reduce the volume used for the
+cache's fast device until the cache is clean.  This is of particular
+importance if writeback mode is used.  Writethrough and passthrough
+modes already maintain a clean cache.  Future support to partially clean
+the cache, above a specified threshold, will allow for keeping the cache
+warm and in writeback mode during resize.
 
 Migration throttling
 --------------------
 
 Migrating data between the origin and cache device uses bandwidth.
 The user can set a throttle to prevent more than a certain amount of
-migration occuring at any one time.  Currently we're not taking any
+migration occurring at any one time.  Currently we're not taking any
 account of normal io traffic going to the devices.  More work needs
 doing here to avoid migrating during those peak io moments.
 
@@ -98,12 +124,11 @@ the default being 204800 sectors (or 100MB).
 Updating on-disk metadata
 -------------------------
 
-On-disk metadata is committed every time a REQ_SYNC or REQ_FUA bio is
-written.  If no such requests are made then commits will occur every
-second.  This means the cache behaves like a physical disk that has a
-write cache (the same is true of the thin-provisioning target).  If
-power is lost you may lose some recent writes.  The metadata should
-always be consistent in spite of any crash.
+On-disk metadata is committed every time a FLUSH or FUA bio is written.
+If no such requests are made then commits will occur every second.  This
+means the cache behaves like a physical disk that has a volatile write
+cache.  If power is lost you may lose some recent writes.  The metadata
+should always be consistent in spite of any crash.
 
 The 'dirty' state for a cache block changes far too frequently for us
 to keep updating it on the fly.  So we treat it as a hint.  In normal
@@ -159,7 +184,7 @@ Constructor
  block size      : cache unit size in sectors
 
  #feature args   : number of feature arguments passed
- feature args    : writethrough.  (The default is writeback.)
+ feature args    : writethrough or passthrough (The default is writeback.)
 
  policy          : the replacement policy to use
  #policy args    : an even number of arguments corresponding to
@@ -175,6 +200,13 @@ Optional feature arguments are:
 		   back cache block contents later for performance reasons,
 		   so they may differ from the corresponding origin blocks.
 
+   passthrough	 : a degraded mode useful for various cache coherency
+		   situations (e.g., rolling back snapshots of
+		   underlying storage).	 Reads and writes always go to
+		   the origin.	If a write goes to a cached origin
+		   block, then the cache block is invalidated.
+		   To enable passthrough mode the cache must be clean.
+
 A policy called 'default' is always registered.  This is an alias for
 the policy we currently think is giving best all round performance.
 
@@ -184,36 +216,43 @@ the characteristics of a specific policy, always request it by name.
 Status
 ------
 
-<#used metadata blocks>/<#total metadata blocks> <#read hits> <#read misses>
-<#write hits> <#write misses> <#demotions> <#promotions> <#blocks in cache>
-<#dirty> <#features> <features>* <#core args> <core args>* <#policy args>
-<policy args>*
-
-#used metadata blocks    : Number of metadata blocks used
-#total metadata blocks   : Total number of metadata blocks
-#read hits               : Number of times a READ bio has been mapped
+<metadata block size> <#used metadata blocks>/<#total metadata blocks>
+<cache block size> <#used cache blocks>/<#total cache blocks>
+<#read hits> <#read misses> <#write hits> <#write misses>
+<#demotions> <#promotions> <#dirty> <#features> <features>*
+<#core args> <core args>* <policy name> <#policy args> <policy args>*
+
+metadata block size	 : Fixed block size for each metadata block in
+			     sectors
+#used metadata blocks	 : Number of metadata blocks used
+#total metadata blocks	 : Total number of metadata blocks
+cache block size	 : Configurable block size for the cache device
+			     in sectors
+#used cache blocks	 : Number of blocks resident in the cache
+#total cache blocks	 : Total number of cache blocks
+#read hits		 : Number of times a READ bio has been mapped
 			     to the cache
-#read misses             : Number of times a READ bio has been mapped
+#read misses		 : Number of times a READ bio has been mapped
 			     to the origin
-#write hits              : Number of times a WRITE bio has been mapped
+#write hits		 : Number of times a WRITE bio has been mapped
 			     to the cache
-#write misses            : Number of times a WRITE bio has been
+#write misses		 : Number of times a WRITE bio has been
 			     mapped to the origin
-#demotions               : Number of times a block has been removed
+#demotions		 : Number of times a block has been removed
 			     from the cache
-#promotions              : Number of times a block has been moved to
+#promotions		 : Number of times a block has been moved to
 			     the cache
-#blocks in cache         : Number of blocks resident in the cache
-#dirty                   : Number of blocks in the cache that differ
+#dirty			 : Number of blocks in the cache that differ
 			     from the origin
-#feature args            : Number of feature args to follow
-feature args             : 'writethrough' (optional)
-#core args               : Number of core arguments (must be even)
-core args                : Key/value pairs for tuning the core
+#feature args		 : Number of feature args to follow
+feature args		 : 'writethrough' (optional)
+#core args		 : Number of core arguments (must be even)
+core args		 : Key/value pairs for tuning the core
 			     e.g. migration_threshold
-#policy args             : Number of policy arguments to follow (must be even)
-policy args              : Key/value pairs
-			     e.g. 'sequential_threshold 1024
+policy name		 : Name of the policy
+#policy args		 : Number of policy arguments to follow (must be even)
+policy args		 : Key/value pairs
+			     e.g. sequential_threshold
 
 Messages
 --------
@@ -229,12 +268,28 @@ The message format is:
 E.g.
    dmsetup message my_cache 0 sequential_threshold 1024
 
+
+Invalidation is removing an entry from the cache without writing it
+back.  Cache blocks can be invalidated via the invalidate_cblocks
+message, which takes an arbitrary number of cblock ranges.  Each cblock
+range's end value is "one past the end", meaning 5-10 expresses a range
+of values from 5 to 9.  Each cblock must be expressed as a decimal
+value, in the future a variant message that takes cblock ranges
+expressed in hexidecimal may be needed to better support efficient
+invalidation of larger caches.  The cache must be in passthrough mode
+when invalidate_cblocks is used.
+
+   invalidate_cblocks [<cblock>|<cblock begin>-<cblock end>]*
+
+E.g.
+   dmsetup message my_cache 0 invalidate_cblocks 2345 3456-4567 5678-6789
+
 Examples
 ========
 
 The test suite can be found here:
 
-https://github.com/jthornber/thinp-test-suite
+https://github.com/jthornber/device-mapper-test-suite
 
 dmsetup create my_cache --table '0 41943040 cache /dev/mapper/metadata \
 	/dev/mapper/ssd /dev/mapper/origin 512 1 writeback default 0'
diff --git a/doc/kernel/crypt.txt b/doc/kernel/crypt.txt
index 2c656ae..692171f 100644
--- a/doc/kernel/crypt.txt
+++ b/doc/kernel/crypt.txt
@@ -4,12 +4,15 @@ dm-crypt
 Device-Mapper's "crypt" target provides transparent encryption of block devices
 using the kernel crypto API.
 
+For a more detailed description of supported parameters see:
+https://gitlab.com/cryptsetup/cryptsetup/wikis/DMCrypt
+
 Parameters: <cipher> <key> <iv_offset> <device path> \
 	      <offset> [<#opt_params> <opt_params>]
 
 <cipher>
     Encryption cipher and an optional IV generation mode.
-    (In format cipher[:keycount]-chainmode-ivopts:ivmode).
+    (In format cipher[:keycount]-chainmode-ivmode[:ivopts]).
     Examples:
        des
        aes-cbc-essiv:sha256
@@ -19,7 +22,11 @@ Parameters: <cipher> <key> <iv_offset> <device path> \
 
 <key>
     Key used for encryption. It is encoded as a hexadecimal number.
-    You can only use key sizes that are valid for the selected cipher.
+    You can only use key sizes that are valid for the selected cipher
+    in combination with the selected iv mode.
+    Note that for some iv modes the key string can contain additional
+    keys (for example IV seed) so the key contains more parts concatenated
+    into a single string.
 
 <keycount>
     Multi-key compatibility mode. You can define <keycount> keys and
@@ -44,7 +51,7 @@ Parameters: <cipher> <key> <iv_offset> <device path> \
     Otherwise #opt_params is the number of following arguments.
 
     Example of optional parameters section:
-        1 allow_discards
+        3 allow_discards same_cpu_crypt submit_from_crypt_cpus
 
 allow_discards
     Block discard requests (a.k.a. TRIM) are passed through the crypt device.
@@ -56,11 +63,24 @@ allow_discards
     used space etc.) if the discarded blocks can be located easily on the
     device later.
 
+same_cpu_crypt
+    Perform encryption using the same cpu that IO was submitted on.
+    The default is to use an unbound workqueue so that encryption work
+    is automatically balanced between available CPUs.
+
+submit_from_crypt_cpus
+    Disable offloading writes to a separate thread after encryption.
+    There are some situations where offloading write bios from the
+    encryption threads to a single thread degrades performance
+    significantly.  The default is to offload write bios to the same
+    thread because it benefits CFQ to have writes submitted using the
+    same context.
+
 Example scripts
 ===============
 LUKS (Linux Unified Key Setup) is now the preferred way to set up disk
 encryption with dm-crypt using the 'cryptsetup' utility, see
-http://code.google.com/p/cryptsetup/
+https://gitlab.com/cryptsetup/cryptsetup
 
 [[
 #!/bin/sh
diff --git a/doc/kernel/era.txt b/doc/kernel/era.txt
new file mode 100644
index 0000000..3c6d01b
--- /dev/null
+++ b/doc/kernel/era.txt
@@ -0,0 +1,108 @@
+Introduction
+============
+
+dm-era is a target that behaves similar to the linear target.  In
+addition it keeps track of which blocks were written within a user
+defined period of time called an 'era'.  Each era target instance
+maintains the current era as a monotonically increasing 32-bit
+counter.
+
+Use cases include tracking changed blocks for backup software, and
+partially invalidating the contents of a cache to restore cache
+coherency after rolling back a vendor snapshot.
+
+Constructor
+===========
+
+ era <metadata dev> <origin dev> <block size>
+
+ metadata dev    : fast device holding the persistent metadata
+ origin dev	 : device holding data blocks that may change
+ block size      : block size of origin data device, granularity that is
+		     tracked by the target
+
+Messages
+========
+
+None of the dm messages take any arguments.
+
+checkpoint
+----------
+
+Possibly move to a new era.  You shouldn't assume the era has
+incremented.  After sending this message, you should check the
+current era via the status line.
+
+take_metadata_snap
+------------------
+
+Create a clone of the metadata, to allow a userland process to read it.
+
+drop_metadata_snap
+------------------
+
+Drop the metadata snapshot.
+
+Status
+======
+
+<metadata block size> <#used metadata blocks>/<#total metadata blocks>
+<current era> <held metadata root | '-'>
+
+metadata block size	 : Fixed block size for each metadata block in
+			     sectors
+#used metadata blocks	 : Number of metadata blocks used
+#total metadata blocks	 : Total number of metadata blocks
+current era		 : The current era
+held metadata root	 : The location, in blocks, of the metadata root
+			     that has been 'held' for userspace read
+			     access. '-' indicates there is no held root
+
+Detailed use case
+=================
+
+The scenario of invalidating a cache when rolling back a vendor
+snapshot was the primary use case when developing this target:
+
+Taking a vendor snapshot
+------------------------
+
+- Send a checkpoint message to the era target
+- Make a note of the current era in its status line
+- Take vendor snapshot (the era and snapshot should be forever
+  associated now).
+
+Rolling back to an vendor snapshot
+----------------------------------
+
+- Cache enters passthrough mode (see: dm-cache's docs in cache.txt)
+- Rollback vendor storage
+- Take metadata snapshot
+- Ascertain which blocks have been written since the snapshot was taken
+  by checking each block's era
+- Invalidate those blocks in the caching software
+- Cache returns to writeback/writethrough mode
+
+Memory usage
+============
+
+The target uses a bitset to record writes in the current era.  It also
+has a spare bitset ready for switching over to a new era.  Other than
+that it uses a few 4k blocks for updating metadata.
+
+   (4 * nr_blocks) bytes + buffers
+
+Resilience
+==========
+
+Metadata is updated on disk before a write to a previously unwritten
+block is performed.  As such dm-era should not be effected by a hard
+crash such as power failure.
+
+Userland tools
+==============
+
+Userland tools are found in the increasingly poorly named
+thin-provisioning-tools project:
+
+    https://github.com/jthornber/thin-provisioning-tools
diff --git a/doc/kernel/log-writes.txt b/doc/kernel/log-writes.txt
new file mode 100644
index 0000000..c10f30c
--- /dev/null
+++ b/doc/kernel/log-writes.txt
@@ -0,0 +1,140 @@
+dm-log-writes
+=============
+
+This target takes 2 devices, one to pass all IO to normally, and one to log all
+of the write operations to.  This is intended for file system developers wishing
+to verify the integrity of metadata or data as the file system is written to.
+There is a log_write_entry written for every WRITE request and the target is
+able to take arbitrary data from userspace to insert into the log.  The data
+that is in the WRITE requests is copied into the log to make the replay happen
+exactly as it happened originally.
+
+Log Ordering
+============
+
+We log things in order of completion once we are sure the write is no longer in
+cache.  This means that normal WRITE requests are not actually logged until the
+next REQ_FLUSH request.  This is to make it easier for userspace to replay the
+log in a way that correlates to what is on disk and not what is in cache, to
+make it easier to detect improper waiting/flushing.
+
+This works by attaching all WRITE requests to a list once the write completes.
+Once we see a REQ_FLUSH request we splice this list onto the request and once
+the FLUSH request completes we log all of the WRITEs and then the FLUSH.  Only
+completed WRITEs, at the time the REQ_FLUSH is issued, are added in order to
+simulate the worst case scenario with regard to power failures.  Consider the
+following example (W means write, C means complete):
+
+W1,W2,W3,C3,C2,Wflush,C1,Cflush
+
+The log would show the following
+
+W3,W2,flush,W1....
+
+Again this is to simulate what is actually on disk, this allows us to detect
+cases where a power failure at a particular point in time would create an
+inconsistent file system.
+
+Any REQ_FUA requests bypass this flushing mechanism and are logged as soon as
+they complete as those requests will obviously bypass the device cache.
+
+Any REQ_DISCARD requests are treated like WRITE requests.  Otherwise we would
+have all the DISCARD requests, and then the WRITE requests and then the FLUSH
+request.  Consider the following example:
+
+WRITE block 1, DISCARD block 1, FLUSH
+
+If we logged DISCARD when it completed, the replay would look like this
+
+DISCARD 1, WRITE 1, FLUSH
+
+which isn't quite what happened and wouldn't be caught during the log replay.
+
+Target interface
+================
+
+i) Constructor
+
+   log-writes <dev_path> <log_dev_path>
+
+   dev_path	: Device that all of the IO will go to normally.
+   log_dev_path : Device where the log entries are written to.
+
+ii) Status
+
+    <#logged entries> <highest allocated sector>
+
+    #logged entries	       : Number of logged entries
+    highest allocated sector   : Highest allocated sector
+
+iii) Messages
+
+    mark <description>
+
+	You can use a dmsetup message to set an arbitrary mark in a log.
+	For example say you want to fsck a file system after every
+	write, but first you need to replay up to the mkfs to make sure
+	we're fsck'ing something reasonable, you would do something like
+	this:
+
+	  mkfs.btrfs -f /dev/mapper/log
+	  dmsetup message log 0 mark mkfs
+	  <run test>
+
+	  This would allow you to replay the log up to the mkfs mark and
+	  then replay from that point on doing the fsck check in the
+	  interval that you want.
+
+	Every log has a mark at the end labeled "dm-log-writes-end".
+
+Userspace component
+===================
+
+There is a userspace tool that will replay the log for you in various ways.
+It can be found here: https://github.com/josefbacik/log-writes
+
+Example usage
+=============
+
+Say you want to test fsync on your file system.  You would do something like
+this:
+
+TABLE="0 $(blockdev --getsz /dev/sdb) log-writes /dev/sdb /dev/sdc"
+dmsetup create log --table "$TABLE"
+mkfs.btrfs -f /dev/mapper/log
+dmsetup message log 0 mark mkfs
+
+mount /dev/mapper/log /mnt/btrfs-test
+<some test that does fsync@the end>
+dmsetup message log 0 mark fsync
+md5sum /mnt/btrfs-test/foo
+umount /mnt/btrfs-test
+
+dmsetup remove log
+replay-log --log /dev/sdc --replay /dev/sdb --end-mark fsync
+mount /dev/sdb /mnt/btrfs-test
+md5sum /mnt/btrfs-test/foo
+<verify md5sum's are correct>
+
+Another option is to do a complicated file system operation and verify the file
+system is consistent during the entire operation.  You could do this with:
+
+TABLE="0 $(blockdev --getsz /dev/sdb) log-writes /dev/sdb /dev/sdc"
+dmsetup create log --table "$TABLE"
+mkfs.btrfs -f /dev/mapper/log
+dmsetup message log 0 mark mkfs
+
+mount /dev/mapper/log /mnt/btrfs-test
+<fsstress to dirty the fs>
+btrfs filesystem balance /mnt/btrfs-test
+umount /mnt/btrfs-test
+dmsetup remove log
+
+replay-log --log /dev/sdc --replay /dev/sdb --end-mark mkfs
+btrfsck /dev/sdb
+replay-log --log /dev/sdc --replay /dev/sdb --start-mark mkfs \
+	--fsck "btrfsck /dev/sdb" --check fua
+
+And that will replay the log until it sees a FUA request, run the fsck command
+and if the fsck passes it will replay to the next FUA, until it is completed or
+the fsck command exists abnormally.
diff --git a/doc/kernel/raid.txt b/doc/kernel/raid.txt
index e919228..ef8ba9f 100644
--- a/doc/kernel/raid.txt
+++ b/doc/kernel/raid.txt
@@ -222,3 +222,5 @@ Version History
 1.4.2   Add RAID10 "far" and "offset" algorithm support.
 1.5.0   Add message interface to allow manipulation of the sync_action.
 	New status (STATUSTYPE_INFO) fields: sync_action and mismatch_cnt.
+1.5.1   Add ability to restore transiently failed devices on resume.
+1.5.2   'mismatch_cnt' is zero unless [last_]sync_action is "check".
diff --git a/doc/kernel/statistics.txt b/doc/kernel/statistics.txt
new file mode 100644
index 0000000..2a1673a
--- /dev/null
+++ b/doc/kernel/statistics.txt
@@ -0,0 +1,186 @@
+DM statistics
+=============
+
+Device Mapper supports the collection of I/O statistics on user-defined
+regions of a DM device.	 If no regions are defined no statistics are
+collected so there isn't any performance impact.  Only bio-based DM
+devices are currently supported.
+
+Each user-defined region specifies a starting sector, length and step.
+Individual statistics will be collected for each step-sized area within
+the range specified.
+
+The I/O statistics counters for each step-sized area of a region are
+in the same format as /sys/block/*/stat or /proc/diskstats (see:
+Documentation/iostats.txt).  But two extra counters (12 and 13) are
+provided: total time spent reading and writing in milliseconds.	 All
+these counters may be accessed by sending the @stats_print message to
+the appropriate DM device via dmsetup.
+
+Each region has a corresponding unique identifier, which we call a
+region_id, that is assigned when the region is created.	 The region_id
+must be supplied when querying statistics about the region, deleting the
+region, etc.  Unique region_ids enable multiple userspace programs to
+request and process statistics for the same DM device without stepping
+on each other's data.
+
+The creation of DM statistics will allocate memory via kmalloc or
+fallback to using vmalloc space.  At most, 1/4 of the overall system
+memory may be allocated by DM statistics.  The admin can see how much
+memory is used by reading
+/sys/module/dm_mod/parameters/stats_current_allocated_bytes
+
+Messages
+========
+
+    @stats_create <range> <step> [<program_id> [<aux_data>]]
+
+	Create a new region and return the region_id.
+
+	<range>
+	  "-" - whole device
+	  "<start_sector>+<length>" - a range of <length> 512-byte sectors
+				      starting with <start_sector>.
+
+	<step>
+	  "<area_size>" - the range is subdivided into areas each containing
+			  <area_size> sectors.
+	  "/<number_of_areas>" - the range is subdivided into the specified
+				 number of areas.
+
+	<program_id>
+	  An optional parameter.  A name that uniquely identifies
+	  the userspace owner of the range.  This groups ranges together
+	  so that userspace programs can identify the ranges they
+	  created and ignore those created by others.
+	  The kernel returns this string back in the output of
+	  @stats_list message, but it doesn't use it for anything else.
+
+	<aux_data>
+	  An optional parameter.  A word that provides auxiliary data
+	  that is useful to the client program that created the range.
+	  The kernel returns this string back in the output of
+	  @stats_list message, but it doesn't use this value for anything.
+
+    @stats_delete <region_id>
+
+	Delete the region with the specified id.
+
+	<region_id>
+	  region_id returned from @stats_create
+
+    @stats_clear <region_id>
+
+	Clear all the counters except the in-flight i/o counters.
+
+	<region_id>
+	  region_id returned from @stats_create
+
+    @stats_list [<program_id>]
+
+	List all regions registered with @stats_create.
+
+	<program_id>
+	  An optional parameter.
+	  If this parameter is specified, only matching regions
+	  are returned.
+	  If it is not specified, all regions are returned.
+
+	Output format:
+	  <region_id>: <start_sector>+<length> <step> <program_id> <aux_data>
+
+    @stats_print <region_id> [<starting_line> <number_of_lines>]
+
+	Print counters for each step-sized area of a region.
+
+	<region_id>
+	  region_id returned from @stats_create
+
+	<starting_line>
+	  The index of the starting line in the output.
+	  If omitted, all lines are returned.
+
+	<number_of_lines>
+	  The number of lines to include in the output.
+	  If omitted, all lines are returned.
+
+	Output format for each step-sized area of a region:
+
+	  <start_sector>+<length> counters
+
+	  The first 11 counters have the same meaning as
+	  /sys/block/*/stat or /proc/diskstats.
+
+	  Please refer to Documentation/iostats.txt for details.
+
+	  1. the number of reads completed
+	  2. the number of reads merged
+	  3. the number of sectors read
+	  4. the number of milliseconds spent reading
+	  5. the number of writes completed
+	  6. the number of writes merged
+	  7. the number of sectors written
+	  8. the number of milliseconds spent writing
+	  9. the number of I/Os currently in progress
+	  10. the number of milliseconds spent doing I/Os
+	  11. the weighted number of milliseconds spent doing I/Os
+
+	  Additional counters:
+	  12. the total time spent reading in milliseconds
+	  13. the total time spent writing in milliseconds
+
+    @stats_print_clear <region_id> [<starting_line> <number_of_lines>]
+
+	Atomically print and then clear all the counters except the
+	in-flight i/o counters.	 Useful when the client consuming the
+	statistics does not want to lose any statistics (those updated
+	between printing and clearing).
+
+	<region_id>
+	  region_id returned from @stats_create
+
+	<starting_line>
+	  The index of the starting line in the output.
+	  If omitted, all lines are printed and then cleared.
+
+	<number_of_lines>
+	  The number of lines to process.
+	  If omitted, all lines are printed and then cleared.
+
+    @stats_set_aux <region_id> <aux_data>
+
+	Store auxiliary data aux_data for the specified region.
+
+	<region_id>
+	  region_id returned from @stats_create
+
+	<aux_data>
+	  The string that identifies data which is useful to the client
+	  program that created the range.  The kernel returns this
+	  string back in the output of @stats_list message, but it
+	  doesn't use this value for anything.
+
+Examples
+========
+
+Subdivide the DM device 'vol' into 100 pieces and start collecting
+statistics on them:
+
+  dmsetup message vol 0 @stats_create - /100
+
+Set the auxillary data string to "foo bar baz" (the escape for each
+space must also be escaped, otherwise the shell will consume them):
+
+  dmsetup message vol 0 @stats_set_aux 0 foo\\ bar\\ baz
+
+List the statistics:
+
+  dmsetup message vol 0 @stats_list
+
+Print the statistics:
+
+  dmsetup message vol 0 @stats_print 0
+
+Delete the statistics:
+
+  dmsetup message vol 0 @stats_delete 0
diff --git a/doc/kernel/switch.txt b/doc/kernel/switch.txt
new file mode 100644
index 0000000..424835e
--- /dev/null
+++ b/doc/kernel/switch.txt
@@ -0,0 +1,138 @@
+dm-switch
+=========
+
+The device-mapper switch target creates a device that supports an
+arbitrary mapping of fixed-size regions of I/O across a fixed set of
+paths.  The path used for any specific region can be switched
+dynamically by sending the target a message.
+
+It maps I/O to underlying block devices efficiently when there is a large
+number of fixed-sized address regions but there is no simple pattern
+that would allow for a compact representation of the mapping such as
+dm-stripe.
+
+Background
+----------
+
+Dell EqualLogic and some other iSCSI storage arrays use a distributed
+frameless architecture.  In this architecture, the storage group
+consists of a number of distinct storage arrays ("members") each having
+independent controllers, disk storage and network adapters.  When a LUN
+is created it is spread across multiple members.  The details of the
+spreading are hidden from initiators connected to this storage system.
+The storage group exposes a single target discovery portal, no matter
+how many members are being used.  When iSCSI sessions are created, each
+session is connected to an eth port on a single member.  Data to a LUN
+can be sent on any iSCSI session, and if the blocks being accessed are
+stored on another member the I/O will be forwarded as required.  This
+forwarding is invisible to the initiator.  The storage layout is also
+dynamic, and the blocks stored on disk may be moved from member to
+member as needed to balance the load.
+
+This architecture simplifies the management and configuration of both
+the storage group and initiators.  In a multipathing configuration, it
+is possible to set up multiple iSCSI sessions to use multiple network
+interfaces on both the host and target to take advantage of the
+increased network bandwidth.  An initiator could use a simple round
+robin algorithm to send I/O across all paths and let the storage array
+members forward it as necessary, but there is a performance advantage to
+sending data directly to the correct member.
+
+A device-mapper table already lets you map different regions of a
+device onto different targets.  However in this architecture the LUN is
+spread with an address region size on the order of 10s of MBs, which
+means the resulting table could have more than a million entries and
+consume far too much memory.
+
+Using this device-mapper switch target we can now build a two-layer
+device hierarchy:
+
+    Upper Tier - Determine which array member the I/O should be sent to.
+    Lower Tier - Load balance amongst paths to a particular member.
+
+The lower tier consists of a single dm multipath device for each member.
+Each of these multipath devices contains the set of paths directly to
+the array member in one priority group, and leverages existing path
+selectors to load balance amongst these paths.  We also build a
+non-preferred priority group containing paths to other array members for
+failover reasons.
+
+The upper tier consists of a single dm-switch device.  This device uses
+a bitmap to look up the location of the I/O and choose the appropriate
+lower tier device to route the I/O.  By using a bitmap we are able to
+use 4 bits for each address range in a 16 member group (which is very
+large for us).  This is a much denser representation than the dm table
+b-tree can achieve.
+
+Construction Parameters
+=======================
+
+    <num_paths> <region_size> <num_optional_args> [<optional_args>...]
+    [<dev_path> <offset>]+
+
+<num_paths>
+    The number of paths across which to distribute the I/O.
+
+<region_size>
+    The number of 512-byte sectors in a region. Each region can be redirected
+    to any of the available paths.
+
+<num_optional_args>
+    The number of optional arguments. Currently, no optional arguments
+    are supported and so this must be zero.
+
+<dev_path>
+    The block device that represents a specific path to the device.
+
+<offset>
+    The offset of the start of data on the specific <dev_path> (in units
+    of 512-byte sectors). This number is added to the sector number when
+    forwarding the request to the specific path. Typically it is zero.
+
+Messages
+========
+
+set_region_mappings <index>:<path_nr> [<index>]:<path_nr> [<index>]:<path_nr>...
+
+Modify the region table by specifying which regions are redirected to
+which paths.
+
+<index>
+    The region number (region size was specified in constructor parameters).
+    If index is omitted, the next region (previous index + 1) is used.
+    Expressed in hexadecimal (WITHOUT any prefix like 0x).
+
+<path_nr>
+    The path number in the range 0 ... (<num_paths> - 1).
+    Expressed in hexadecimal (WITHOUT any prefix like 0x).
+
+R<n>,<m>
+    This parameter allows repetitive patterns to be loaded quickly. <n> and <m>
+    are hexadecimal numbers. The last <n> mappings are repeated in the next <m>
+    slots.
+
+Status
+======
+
+No status line is reported.
+
+Example
+=======
+
+Assume that you have volumes vg1/switch0 vg1/switch1 vg1/switch2 with
+the same size.
+
+Create a switch device with 64kB region size:
+    dmsetup create switch --table "0 `blockdev --getsize /dev/vg1/switch0`
+	switch 3 128 0 /dev/vg1/switch0 0 /dev/vg1/switch1 0 /dev/vg1/switch2 0"
+
+Set mappings for the first 7 entries to point to devices switch0, switch1,
+switch2, switch0, switch1, switch2, switch1:
+    dmsetup message switch 0 set_region_mappings 0:0 :1 :2 :0 :1 :2 :1
+
+Set repetitive mapping. This command:
+    dmsetup message switch 0 set_region_mappings 1000:1 :2 R2,10
+is equivalent to:
+    dmsetup message switch 0 set_region_mappings 1000:1 :2 :1 :2 :1 :2 :1 :2 \
+	:1 :2 :1 :2 :1 :2 :1 :2 :1 :2
+
diff --git a/doc/kernel/thin-provisioning.txt b/doc/kernel/thin-provisioning.txt
index 30b8b83..4f67578 100644
--- a/doc/kernel/thin-provisioning.txt
+++ b/doc/kernel/thin-provisioning.txt
@@ -99,13 +99,14 @@ Using an existing pool device
 		 $data_block_size $low_water_mark"
 
 $data_block_size gives the smallest unit of disk space that can be
-allocated at a time expressed in units of 512-byte sectors.  People
-primarily interested in thin provisioning may want to use a value such
-as 1024 (512KB).  People doing lots of snapshotting may want a smaller value
-such as 128 (64KB).  If you are not zeroing newly-allocated data,
-a larger $data_block_size in the region of 256000 (128MB) is suggested.
-$data_block_size must be the same for the lifetime of the
-metadata device.
+allocated at a time expressed in units of 512-byte sectors.
+$data_block_size must be between 128 (64KB) and 2097152 (1GB) and a
+multiple of 128 (64KB).  $data_block_size cannot be changed after the
+thin-pool is created.  People primarily interested in thin provisioning
+may want to use a value such as 1024 (512KB).  People doing lots of
+snapshotting may want a smaller value such as 128 (64KB).  If you are
+not zeroing newly-allocated data, a larger $data_block_size in the
+region of 256000 (128MB) is suggested.
 
 $low_water_mark is expressed in blocks of size $data_block_size.  If
 free space on the data device drops below this level then a dm event
@@ -115,6 +116,35 @@ Resuming a device with a new table itself triggers an event so the
 userspace daemon can use this to detect a situation where a new table
 already exceeds the threshold.
 
+A low water mark for the metadata device is maintained in the kernel and
+will trigger a dm event if free space on the metadata device drops below
+it.
+
+Updating on-disk metadata
+-------------------------
+
+On-disk metadata is committed every time a FLUSH or FUA bio is written.
+If no such requests are made then commits will occur every second.  This
+means the thin-provisioning target behaves like a physical disk that has
+a volatile write cache.  If power is lost you may lose some recent
+writes.  The metadata should always be consistent in spite of any crash.
+
+If data space is exhausted the pool will either error or queue IO
+according to the configuration (see: error_if_no_space).  If metadata
+space is exhausted or a metadata operation fails: the pool will error IO
+until the pool is taken offline and repair is performed to 1) fix any
+potential inconsistencies and 2) clear the flag that imposes repair.
+Once the pool's metadata device is repaired it may be resized, which
+will allow the pool to return to normal operation.  Note that if a pool
+is flagged as needing repair, the pool's data and metadata devices
+cannot be resized until repair is performed.  It should also be noted
+that when the pool's metadata space is exhausted the current metadata
+transaction is aborted.  Given that the pool will cache IO whose
+completion may have already been acknowledged to upper IO layers
+(e.g. filesystem) it is strongly suggested that consistency checks
+(e.g. fsck) be performed on those layers when repair of the pool is
+required.
+
 Thin provisioning
 -----------------
 
@@ -234,6 +264,8 @@ i) Constructor
       read_only: Don't allow any changes to be made to the pool
 		 metadata.
 
+      error_if_no_space: Error IOs, instead of queueing, if no space.
+
     Data block size must be between 64KB (128 sectors) and 1GB
     (2097152 sectors) inclusive.
 
@@ -255,10 +287,9 @@ ii) Status
 	should register for the event and then check the target's status.
 
     held metadata root:
-	The location, in sectors, of the metadata root that has been
+	The location, in blocks, of the metadata root that has been
 	'held' for userspace read access.  '-' indicates there is no
-	held root.  This feature is not yet implemented so '-' is
-	always returned.
+	held root.
 
     discard_passdown|no_discard_passdown
 	Whether or not discards are actually being passed down to the
@@ -275,6 +306,14 @@ ii) Status
 	contain the string 'Fail'.  The userspace recovery tools
 	should then be used.
 
+    error_if_no_space|queue_if_no_space
+	If the pool runs out of data or metadata space, the pool will
+	either queue or error the IO destined to the data device.  The
+	default is to queue the IO until more space is added or the
+	'no_space_timeout' expires.  The 'no_space_timeout' dm-thin-pool
+	module parameter can be used to change this timeout -- it
+	defaults to 60 seconds but may be disabled using a value of 0.
+
 iii) Messages
 
     create_thin <dev id>
@@ -341,9 +380,6 @@ then you'll have no access to blocks mapped beyond the end.  If you
 load a target that is bigger than before, then extra blocks will be
 provisioned as and when needed.
 
-If you wish to reduce the size of your thin device and potentially
-regain some space then send the 'trim' message to the pool.
-
 ii) Status
 
      <nr mapped sectors> <highest mapped sector>
diff --git a/doc/kernel/verity.txt b/doc/kernel/verity.txt
index 9884681..e15bc1a 100644
--- a/doc/kernel/verity.txt
+++ b/doc/kernel/verity.txt
@@ -11,6 +11,7 @@ Construction Parameters
     <data_block_size> <hash_block_size>
     <num_data_blocks> <hash_start_block>
     <algorithm> <digest> <salt>
+    [<#opt_params> <opt_params>]
 
 <version>
     This is the type of the on-disk hash format.
@@ -62,6 +63,22 @@ Construction Parameters
 <salt>
     The hexadecimal encoding of the salt value.
 
+<#opt_params>
+    Number of optional parameters. If there are no optional parameters,
+    the optional paramaters section can be skipped or #opt_params can be zero.
+    Otherwise #opt_params is the number of following arguments.
+
+    Example of optional parameters section:
+        1 ignore_corruption
+
+ignore_corruption
+    Log corrupted blocks, but allow read operations to proceed normally.
+
+restart_on_corruption
+    Restart the system when a corrupted block is discovered. This option is
+    not compatible with ignore_corruption and requires user space support to
+    avoid restart loops.
+
 Theory of operation
 ===================
 
@@ -125,7 +142,7 @@ block boundary) are the hash blocks which are stored a depth at a time
 
 The full specification of kernel parameters and on-disk metadata format
 is available at the cryptsetup project's wiki page
-  http://code.google.com/p/cryptsetup/wiki/DMVerity
+  https://gitlab.com/cryptsetup/cryptsetup/wikis/DMVerity
 
 Status
 ======
@@ -142,7 +159,7 @@ Set up a device:
 
 A command line tool veritysetup is available to compute or verify
 the hash tree or activate the kernel device. This is available from
-the cryptsetup upstream repository http://code.google.com/p/cryptsetup/
+the cryptsetup upstream repository https://gitlab.com/cryptsetup/cryptsetup/
 (as a libcryptsetup extension).
 
 Create hash on the device:


