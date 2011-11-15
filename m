From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Nov 2011 13:54:29 -0000
Subject: LVM2 ./WHATS_NEW_DM doc/kernel/crypt.txt doc/k ...
Message-ID: <20111115135429.24315.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-11-15 13:54:21

Modified files:
	.              : WHATS_NEW_DM 
Added files:
	doc/kernel     : crypt.txt delay.txt flakey.txt io.txt 
	                 kcopyd.txt linear.txt log.txt 
	                 persistent-data.txt queue-length.txt raid.txt 
	                 service-time.txt snapshot.txt striped.txt 
	                 thin-provisioning.txt uevent.txt zero.txt 

Log message:
	Include a copy of kernel DM documentation in doc/kernel

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.522&r2=1.523
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/crypt.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/delay.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/flakey.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/io.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/kcopyd.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/linear.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/log.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/persistent-data.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/queue-length.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/raid.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/service-time.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/snapshot.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/striped.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/thin-provisioning.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/uevent.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/kernel/zero.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW_DM	2011/11/12 22:48:44	1.522
+++ LVM2/WHATS_NEW_DM	2011/11/15 13:54:20	1.523
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Include a copy of kernel DM documentation in doc/kernel.
   Improve man page style for dmsetup.
   Fix _get_proc_number to be tolerant of malformed /proc/misc entries.
   Add ExecReload to dm-event.service for systemd to reload dmeventd properly.
/cvs/lvm2/LVM2/doc/kernel/crypt.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/crypt.txt
+++ -	2011-11-15 13:54:22.905977000 +0000
@@ -0,0 +1,76 @@
+dm-crypt
+=========
+
+Device-Mapper's "crypt" target provides transparent encryption of block devices
+using the kernel crypto API.
+
+Parameters: <cipher> <key> <iv_offset> <device path> \
+	      <offset> [<#opt_params> <opt_params>]
+
+<cipher>
+    Encryption cipher and an optional IV generation mode.
+    (In format cipher[:keycount]-chainmode-ivopts:ivmode).
+    Examples:
+       des
+       aes-cbc-essiv:sha256
+       twofish-ecb
+
+    /proc/crypto contains supported crypto modes
+
+<key>
+    Key used for encryption. It is encoded as a hexadecimal number.
+    You can only use key sizes that are valid for the selected cipher.
+
+<keycount>
+    Multi-key compatibility mode. You can define <keycount> keys and
+    then sectors are encrypted according to their offsets (sector 0 uses key0;
+    sector 1 uses key1 etc.).  <keycount> must be a power of two.
+
+<iv_offset>
+    The IV offset is a sector count that is added to the sector number
+    before creating the IV.
+
+<device path>
+    This is the device that is going to be used as backend and contains the
+    encrypted data.  You can specify it as a path like /dev/xxx or a device
+    number <major>:<minor>.
+
+<offset>
+    Starting sector within the device where the encrypted data begins.
+
+<#opt_params>
+    Number of optional parameters. If there are no optional parameters,
+    the optional paramaters section can be skipped or #opt_params can be zero.
+    Otherwise #opt_params is the number of following arguments.
+
+    Example of optional parameters section:
+        1 allow_discards
+
+allow_discards
+    Block discard requests (a.k.a. TRIM) are passed through the crypt device.
+    The default is to ignore discard requests.
+
+    WARNING: Assess the specific security risks carefully before enabling this
+    option.  For example, allowing discards on encrypted devices may lead to
+    the leak of information about the ciphertext device (filesystem type,
+    used space etc.) if the discarded blocks can be located easily on the
+    device later.
+
+Example scripts
+===============
+LUKS (Linux Unified Key Setup) is now the preferred way to set up disk
+encryption with dm-crypt using the 'cryptsetup' utility, see
+http://code.google.com/p/cryptsetup/
+
+[[
+#!/bin/sh
+# Create a crypt device using dmsetup
+dmsetup create crypt1 --table "0 `blockdev --getsize $1` crypt aes-cbc-essiv:sha256 babebabebabebabebabebabebabebabe 0 $1 0"
+]]
+
+[[
+#!/bin/sh
+# Create a crypt device using cryptsetup and LUKS header with default cipher
+cryptsetup luksFormat $1
+cryptsetup luksOpen $1 crypt1
+]]
/cvs/lvm2/LVM2/doc/kernel/delay.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/delay.txt
+++ -	2011-11-15 13:54:23.207124000 +0000
@@ -0,0 +1,26 @@
+dm-delay
+========
+
+Device-Mapper's "delay" target delays reads and/or writes
+and maps them to different devices.
+
+Parameters:
+    <device> <offset> <delay> [<write_device> <write_offset> <write_delay>]
+
+With separate write parameters, the first set is only used for reads.
+Delays are specified in milliseconds.
+
+Example scripts
+===============
+[[
+#!/bin/sh
+# Create device delaying rw operation for 500ms
+echo "0 `blockdev --getsize $1` delay $1 0 500" | dmsetup create delayed
+]]
+
+[[
+#!/bin/sh
+# Create device delaying only write operation for 500ms and
+# splitting reads and writes to different devices $1 $2
+echo "0 `blockdev --getsize $1` delay $1 0 0 $2 0 500" | dmsetup create delayed
+]]
/cvs/lvm2/LVM2/doc/kernel/flakey.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/flakey.txt
+++ -	2011-11-15 13:54:23.516354000 +0000
@@ -0,0 +1,53 @@
+dm-flakey
+=========
+
+This target is the same as the linear target except that it exhibits
+unreliable behaviour periodically.  It's been found useful in simulating
+failing devices for testing purposes.
+
+Starting from the time the table is loaded, the device is available for
+<up interval> seconds, then exhibits unreliable behaviour for <down
+interval> seconds, and then this cycle repeats.
+
+Also, consider using this in combination with the dm-delay target too,
+which can delay reads and writes and/or send them to different
+underlying devices.
+
+Table parameters
+----------------
+  <dev path> <offset> <up interval> <down interval> \
+    [<num_features> [<feature arguments>]]
+
+Mandatory parameters:
+    <dev path>: Full pathname to the underlying block-device, or a
+                "major:minor" device-number.
+    <offset>: Starting sector within the device.
+    <up interval>: Number of seconds device is available.
+    <down interval>: Number of seconds device returns errors.
+
+Optional feature parameters:
+  If no feature parameters are present, during the periods of
+  unreliability, all I/O returns errors.
+
+  drop_writes:
+	All write I/O is silently ignored.
+	Read I/O is handled correctly.
+
+  corrupt_bio_byte <Nth_byte> <direction> <value> <flags>:
+	During <down interval>, replace <Nth_byte> of the data of
+	each matching bio with <value>.
+
+    <Nth_byte>: The offset of the byte to replace.
+		Counting starts at 1, to replace the first byte.
+    <direction>: Either 'r' to corrupt reads or 'w' to corrupt writes.
+		 'w' is incompatible with drop_writes.
+    <value>: The value (from 0-255) to write.
+    <flags>: Perform the replacement only if bio->bi_rw has all the
+	     selected flags set.
+
+Examples:
+  corrupt_bio_byte 32 r 1 0
+	- replaces the 32nd byte of READ bios with the value 1
+
+  corrupt_bio_byte 224 w 0 32
+	- replaces the 224th byte of REQ_META (=32) bios with the value 0
/cvs/lvm2/LVM2/doc/kernel/io.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/io.txt
+++ -	2011-11-15 13:54:24.252249000 +0000
@@ -0,0 +1,75 @@
+dm-io
+=====
+
+Dm-io provides synchronous and asynchronous I/O services. There are three
+types of I/O services available, and each type has a sync and an async
+version.
+
+The user must set up an io_region structure to describe the desired location
+of the I/O. Each io_region indicates a block-device along with the starting
+sector and size of the region.
+
+   struct io_region {
+      struct block_device *bdev;
+      sector_t sector;
+      sector_t count;
+   };
+
+Dm-io can read from one io_region or write to one or more io_regions. Writes
+to multiple regions are specified by an array of io_region structures.
+
+The first I/O service type takes a list of memory pages as the data buffer for
+the I/O, along with an offset into the first page.
+
+   struct page_list {
+      struct page_list *next;
+      struct page *page;
+   };
+
+   int dm_io_sync(unsigned int num_regions, struct io_region *where, int rw,
+                  struct page_list *pl, unsigned int offset,
+                  unsigned long *error_bits);
+   int dm_io_async(unsigned int num_regions, struct io_region *where, int rw,
+                   struct page_list *pl, unsigned int offset,
+                   io_notify_fn fn, void *context);
+
+The second I/O service type takes an array of bio vectors as the data buffer
+for the I/O. This service can be handy if the caller has a pre-assembled bio,
+but wants to direct different portions of the bio to different devices.
+
+   int dm_io_sync_bvec(unsigned int num_regions, struct io_region *where,
+                       int rw, struct bio_vec *bvec,
+                       unsigned long *error_bits);
+   int dm_io_async_bvec(unsigned int num_regions, struct io_region *where,
+                        int rw, struct bio_vec *bvec,
+                        io_notify_fn fn, void *context);
+
+The third I/O service type takes a pointer to a vmalloc'd memory buffer as the
+data buffer for the I/O. This service can be handy if the caller needs to do
+I/O to a large region but doesn't want to allocate a large number of individual
+memory pages.
+
+   int dm_io_sync_vm(unsigned int num_regions, struct io_region *where, int rw,
+                     void *data, unsigned long *error_bits);
+   int dm_io_async_vm(unsigned int num_regions, struct io_region *where, int rw,
+                      void *data, io_notify_fn fn, void *context);
+
+Callers of the asynchronous I/O services must include the name of a completion
+callback routine and a pointer to some context data for the I/O.
+
+   typedef void (*io_notify_fn)(unsigned long error, void *context);
+
+The "error" parameter in this callback, as well as the "*error" parameter in
+all of the synchronous versions, is a bitset (instead of a simple error value).
+In the case of an write-I/O to multiple regions, this bitset allows dm-io to
+indicate success or failure on each individual region.
+
+Before using any of the dm-io services, the user should call dm_io_get()
+and specify the number of pages they expect to perform I/O on concurrently.
+Dm-io will attempt to resize its mempool to make sure enough pages are
+always available in order to avoid unnecessary waiting while performing I/O.
+
+When the user is finished using the dm-io services, they should call
+dm_io_put() and specify the same number of pages that were given on the
+dm_io_get() call.
+
/cvs/lvm2/LVM2/doc/kernel/kcopyd.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/kcopyd.txt
+++ -	2011-11-15 13:54:24.798709000 +0000
@@ -0,0 +1,47 @@
+kcopyd
+======
+
+Kcopyd provides the ability to copy a range of sectors from one block-device
+to one or more other block-devices, with an asynchronous completion
+notification. It is used by dm-snapshot and dm-mirror.
+
+Users of kcopyd must first create a client and indicate how many memory pages
+to set aside for their copy jobs. This is done with a call to
+kcopyd_client_create().
+
+   int kcopyd_client_create(unsigned int num_pages,
+                            struct kcopyd_client **result);
+
+To start a copy job, the user must set up io_region structures to describe
+the source and destinations of the copy. Each io_region indicates a
+block-device along with the starting sector and size of the region. The source
+of the copy is given as one io_region structure, and the destinations of the
+copy are given as an array of io_region structures.
+
+   struct io_region {
+      struct block_device *bdev;
+      sector_t sector;
+      sector_t count;
+   };
+
+To start the copy, the user calls kcopyd_copy(), passing in the client
+pointer, pointers to the source and destination io_regions, the name of a
+completion callback routine, and a pointer to some context data for the copy.
+
+   int kcopyd_copy(struct kcopyd_client *kc, struct io_region *from,
+                   unsigned int num_dests, struct io_region *dests,
+                   unsigned int flags, kcopyd_notify_fn fn, void *context);
+
+   typedef void (*kcopyd_notify_fn)(int read_err, unsigned int write_err,
+				    void *context);
+
+When the copy completes, kcopyd will call the user's completion routine,
+passing back the user's context pointer. It will also indicate if a read or
+write error occurred during the copy.
+
+When a user is done with all their copy jobs, they should call
+kcopyd_client_destroy() to delete the kcopyd client, which will release the
+associated memory pages.
+
+   void kcopyd_client_destroy(struct kcopyd_client *kc);
+
/cvs/lvm2/LVM2/doc/kernel/linear.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/linear.txt
+++ -	2011-11-15 13:54:25.087113000 +0000
@@ -0,0 +1,61 @@
+dm-linear
+=========
+
+Device-Mapper's "linear" target maps a linear range of the Device-Mapper
+device onto a linear range of another device.  This is the basic building
+block of logical volume managers.
+
+Parameters: <dev path> <offset>
+    <dev path>: Full pathname to the underlying block-device, or a
+                "major:minor" device-number.
+    <offset>: Starting sector within the device.
+
+
+Example scripts
+===============
+[[
+#!/bin/sh
+# Create an identity mapping for a device
+echo "0 `blockdev --getsize $1` linear $1 0" | dmsetup create identity
+]]
+
+
+[[
+#!/bin/sh
+# Join 2 devices together
+size1=`blockdev --getsize $1`
+size2=`blockdev --getsize $2`
+echo "0 $size1 linear $1 0
+$size1 $size2 linear $2 0" | dmsetup create joined
+]]
+
+
+[[
+#!/usr/bin/perl -w
+# Split a device into 4M chunks and then join them together in reverse order.
+
+my $name = "reverse";
+my $extent_size = 4 * 1024 * 2;
+my $dev = $ARGV[0];
+my $table = "";
+my $count = 0;
+
+if (!defined($dev)) {
+        die("Please specify a device.\n");
+}
+
+my $dev_size = `blockdev --getsize $dev`;
+my $extents = int($dev_size / $extent_size) -
+              (($dev_size % $extent_size) ? 1 : 0);
+
+while ($extents > 0) {
+        my $this_start = $count * $extent_size;
+        $extents--;
+        $count++;
+        my $this_offset = $extents * $extent_size;
+
+        $table .= "$this_start $extent_size linear $dev $this_offset\n";
+}
+
+`echo \"$table\" | dmsetup create $name`;
+]]
/cvs/lvm2/LVM2/doc/kernel/log.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/log.txt
+++ -	2011-11-15 13:54:25.595868000 +0000
@@ -0,0 +1,54 @@
+Device-Mapper Logging
+=====================
+The device-mapper logging code is used by some of the device-mapper
+RAID targets to track regions of the disk that are not consistent.
+A region (or portion of the address space) of the disk may be
+inconsistent because a RAID stripe is currently being operated on or
+a machine died while the region was being altered.  In the case of
+mirrors, a region would be considered dirty/inconsistent while you
+are writing to it because the writes need to be replicated for all
+the legs of the mirror and may not reach the legs at the same time.
+Once all writes are complete, the region is considered clean again.
+
+There is a generic logging interface that the device-mapper RAID
+implementations use to perform logging operations (see
+dm_dirty_log_type in include/linux/dm-dirty-log.h).  Various different
+logging implementations are available and provide different
+capabilities.  The list includes:
+
+Type		Files
+====		=====
+disk		drivers/md/dm-log.c
+core		drivers/md/dm-log.c
+userspace	drivers/md/dm-log-userspace* include/linux/dm-log-userspace.h
+
+The "disk" log type
+-------------------
+This log implementation commits the log state to disk.  This way, the
+logging state survives reboots/crashes.
+
+The "core" log type
+-------------------
+This log implementation keeps the log state in memory.  The log state
+will not survive a reboot or crash, but there may be a small boost in
+performance.  This method can also be used if no storage device is
+available for storing log state.
+
+The "userspace" log type
+------------------------
+This log type simply provides a way to export the log API to userspace,
+so log implementations can be done there.  This is done by forwarding most
+logging requests to userspace, where a daemon receives and processes the
+request.
+
+The structure used for communication between kernel and userspace are
+located in include/linux/dm-log-userspace.h.  Due to the frequency,
+diversity, and 2-way communication nature of the exchanges between
+kernel and userspace, 'connector' is used as the interface for
+communication.
+
+There are currently two userspace log implementations that leverage this
+framework - "clustered-disk" and "clustered-core".  These implementations
+provide a cluster-coherent log for shared-storage.  Device-mapper mirroring
+can be used in a shared-storage environment when the cluster log implementations
+are employed.
/cvs/lvm2/LVM2/doc/kernel/persistent-data.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/persistent-data.txt
+++ -	2011-11-15 13:54:26.007174000 +0000
@@ -0,0 +1,84 @@
+Introduction
+============
+
+The more-sophisticated device-mapper targets require complex metadata
+that is managed in kernel.  In late 2010 we were seeing that various
+different targets were rolling their own data strutures, for example:
+
+- Mikulas Patocka's multisnap implementation
+- Heinz Mauelshagen's thin provisioning target
+- Another btree-based caching target posted to dm-devel
+- Another multi-snapshot target based on a design of Daniel Phillips
+
+Maintaining these data structures takes a lot of work, so if possible
+we'd like to reduce the number.
+
+The persistent-data library is an attempt to provide a re-usable
+framework for people who want to store metadata in device-mapper
+targets.  It's currently used by the thin-provisioning target and an
+upcoming hierarchical storage target.
+
+Overview
+========
+
+The main documentation is in the header files which can all be found
+under drivers/md/persistent-data.
+
+The block manager
+-----------------
+
+dm-block-manager.[hc]
+
+This provides access to the data on disk in fixed sized-blocks.  There
+is a read/write locking interface to prevent concurrent accesses, and
+keep data that is being used in the cache.
+
+Clients of persistent-data are unlikely to use this directly.
+
+The transaction manager
+-----------------------
+
+dm-transaction-manager.[hc]
+
+This restricts access to blocks and enforces copy-on-write semantics.
+The only way you can get hold of a writable block through the
+transaction manager is by shadowing an existing block (ie. doing
+copy-on-write) or allocating a fresh one.  Shadowing is elided within
+the same transaction so performance is reasonable.  The commit method
+ensures that all data is flushed before it writes the superblock.
+On power failure your metadata will be as it was when last committed.
+
+The Space Maps
+--------------
+
+dm-space-map.h
+dm-space-map-metadata.[hc]
+dm-space-map-disk.[hc]
+
+On-disk data structures that keep track of reference counts of blocks.
+Also acts as the allocator of new blocks.  Currently two
+implementations: a simpler one for managing blocks on a different
+device (eg. thinly-provisioned data blocks); and one for managing
+the metadata space.  The latter is complicated by the need to store
+its own data within the space it's managing.
+
+The data structures
+-------------------
+
+dm-btree.[hc]
+dm-btree-remove.c
+dm-btree-spine.c
+dm-btree-internal.h
+
+Currently there is only one data structure, a hierarchical btree.
+There are plans to add more.  For example, something with an
+array-like interface would see a lot of use.
+
+The btree is 'hierarchical' in that you can define it to be composed
+of nested btrees, and take multiple keys.  For example, the
+thin-provisioning target uses a btree with two levels of nesting.
+The first maps a device id to a mapping tree, and that in turn maps a
+virtual block to a physical block.
+
+Values stored in the btrees can have arbitrary size.  Keys are always
+64bits, although nesting allows you to use multiple keys.
/cvs/lvm2/LVM2/doc/kernel/queue-length.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/queue-length.txt
+++ -	2011-11-15 13:54:26.540768000 +0000
@@ -0,0 +1,39 @@
+dm-queue-length
+===============
+
+dm-queue-length is a path selector module for device-mapper targets,
+which selects a path with the least number of in-flight I/Os.
+The path selector name is 'queue-length'.
+
+Table parameters for each path: [<repeat_count>]
+	<repeat_count>: The number of I/Os to dispatch using the selected
+			path before switching to the next path.
+			If not given, internal default is used. To check
+			the default value, see the activated table.
+
+Status for each path: <status> <fail-count> <in-flight>
+	<status>: 'A' if the path is active, 'F' if the path is failed.
+	<fail-count>: The number of path failures.
+	<in-flight>: The number of in-flight I/Os on the path.
+
+
+Algorithm
+=========
+
+dm-queue-length increments/decrements 'in-flight' when an I/O is
+dispatched/completed respectively.
+dm-queue-length selects a path with the minimum 'in-flight'.
+
+
+Examples
+========
+In case that 2 paths (sda and sdb) are used with repeat_count == 128.
+
+# echo "0 10 multipath 0 0 1 1 queue-length 0 2 1 8:0 128 8:16 128" \
+  dmsetup create test
+#
+# dmsetup table
+test: 0 10 multipath 0 0 1 1 queue-length 0 2 1 8:0 128 8:16 128
+#
+# dmsetup status
+test: 0 10 multipath 2 0 0 0 1 1 E 0 2 1 8:0 A 0 0 8:16 A 0 0
/cvs/lvm2/LVM2/doc/kernel/raid.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/raid.txt
+++ -	2011-11-15 13:54:26.981958000 +0000
@@ -0,0 +1,108 @@
+dm-raid
+-------
+
+The device-mapper RAID (dm-raid) target provides a bridge from DM to MD.
+It allows the MD RAID drivers to be accessed using a device-mapper
+interface.
+
+The target is named "raid" and it accepts the following parameters:
+
+  <raid_type> <#raid_params> <raid_params> \
+    <#raid_devs> <metadata_dev0> <dev0> [.. <metadata_devN> <devN>]
+
+<raid_type>:
+  raid1		RAID1 mirroring
+  raid4		RAID4 dedicated parity disk
+  raid5_la	RAID5 left asymmetric
+		- rotating parity 0 with data continuation
+  raid5_ra	RAID5 right asymmetric
+		- rotating parity N with data continuation
+  raid5_ls	RAID5 left symmetric
+		- rotating parity 0 with data restart
+  raid5_rs 	RAID5 right symmetric
+		- rotating parity N with data restart
+  raid6_zr	RAID6 zero restart
+		- rotating parity zero (left-to-right) with data restart
+  raid6_nr	RAID6 N restart
+		- rotating parity N (right-to-left) with data restart
+  raid6_nc	RAID6 N continue
+		- rotating parity N (right-to-left) with data continuation
+
+  Refererence: Chapter 4 of
+  http://www.snia.org/sites/default/files/SNIA_DDF_Technical_Position_v2.0.pdf
+
+<#raid_params>: The number of parameters that follow.
+
+<raid_params> consists of
+    Mandatory parameters:
+        <chunk_size>: Chunk size in sectors.  This parameter is often known as
+		      "stripe size".  It is the only mandatory parameter and
+		      is placed first.
+
+    followed by optional parameters (in any order):
+	[sync|nosync]   Force or prevent RAID initialization.
+
+	[rebuild <idx>]	Rebuild drive number idx (first drive is 0).
+
+	[daemon_sleep <ms>]
+		Interval between runs of the bitmap daemon that
+		clear bits.  A longer interval means less bitmap I/O but
+		resyncing after a failure is likely to take longer.
+
+	[min_recovery_rate <kB/sec/disk>]  Throttle RAID initialization
+	[max_recovery_rate <kB/sec/disk>]  Throttle RAID initialization
+	[write_mostly <idx>]		   Drive index is write-mostly
+	[max_write_behind <sectors>]       See '-write-behind=' (man mdadm)
+	[stripe_cache <sectors>]           Stripe cache size (higher RAIDs only)
+	[region_size <sectors>]
+		The region_size multiplied by the number of regions is the
+		logical size of the array.  The bitmap records the device
+		synchronisation state for each region.
+
+<#raid_devs>: The number of devices composing the array.
+	Each device consists of two entries.  The first is the device
+	containing the metadata (if any); the second is the one containing the
+	data.
+
+	If a drive has failed or is missing at creation time, a '-' can be
+	given for both the metadata and data drives for a given position.
+
+
+Example tables
+--------------
+# RAID4 - 4 data drives, 1 parity (no metadata devices)
+# No metadata devices specified to hold superblock/bitmap info
+# Chunk size of 1MiB
+# (Lines separated for easy reading)
+
+0 1960893648 raid \
+        raid4 1 2048 \
+        5 - 8:17 - 8:33 - 8:49 - 8:65 - 8:81
+
+# RAID4 - 4 data drives, 1 parity (with metadata devices)
+# Chunk size of 1MiB, force RAID initialization,
+#       min recovery rate at 20 kiB/sec/disk
+
+0 1960893648 raid \
+        raid4 4 2048 sync min_recovery_rate 20 \
+        5 8:17 8:18 8:33 8:34 8:49 8:50 8:65 8:66 8:81 8:82
+
+'dmsetup table' displays the table used to construct the mapping.
+The optional parameters are always printed in the order listed
+above with "sync" or "nosync" always output ahead of the other
+arguments, regardless of the order used when originally loading the table.
+Arguments that can be repeated are ordered by value.
+
+'dmsetup status' yields information on the state and health of the
+array.
+The output is as follows:
+1: <s> <l> raid \
+2:      <raid_type> <#devices> <1 health char for each dev> <resync_ratio>
+
+Line 1 is the standard output produced by device-mapper.
+Line 2 is produced by the raid target, and best explained by example:
+        0 1960893648 raid raid4 5 AAAAA 2/490221568
+Here we can see the RAID type is raid4, there are 5 devices - all of
+which are 'A'live, and the array is 2/490221568 complete with recovery.
+Faulty or missing devices are marked 'D'.  Devices that are out-of-sync
+are marked 'a'.
/cvs/lvm2/LVM2/doc/kernel/service-time.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/service-time.txt
+++ -	2011-11-15 13:54:27.482181000 +0000
@@ -0,0 +1,91 @@
+dm-service-time
+===============
+
+dm-service-time is a path selector module for device-mapper targets,
+which selects a path with the shortest estimated service time for
+the incoming I/O.
+
+The service time for each path is estimated by dividing the total size
+of in-flight I/Os on a path with the performance value of the path.
+The performance value is a relative throughput value among all paths
+in a path-group, and it can be specified as a table argument.
+
+The path selector name is 'service-time'.
+
+Table parameters for each path: [<repeat_count> [<relative_throughput>]]
+	<repeat_count>: The number of I/Os to dispatch using the selected
+			path before switching to the next path.
+			If not given, internal default is used.  To check
+			the default value, see the activated table.
+	<relative_throughput>: The relative throughput value of the path
+			among all paths in the path-group.
+			The valid range is 0-100.
+			If not given, minimum value '1' is used.
+			If '0' is given, the path isn't selected while
+			other paths having a positive value are available.
+
+Status for each path: <status> <fail-count> <in-flight-size> \
+		      <relative_throughput>
+	<status>: 'A' if the path is active, 'F' if the path is failed.
+	<fail-count>: The number of path failures.
+	<in-flight-size>: The size of in-flight I/Os on the path.
+	<relative_throughput>: The relative throughput value of the path
+			among all paths in the path-group.
+
+
+Algorithm
+=========
+
+dm-service-time adds the I/O size to 'in-flight-size' when the I/O is
+dispatched and subtracts when completed.
+Basically, dm-service-time selects a path having minimum service time
+which is calculated by:
+
+	('in-flight-size' + 'size-of-incoming-io') / 'relative_throughput'
+
+However, some optimizations below are used to reduce the calculation
+as much as possible.
+
+	1. If the paths have the same 'relative_throughput', skip
+	   the division and just compare the 'in-flight-size'.
+
+	2. If the paths have the same 'in-flight-size', skip the division
+	   and just compare the 'relative_throughput'.
+
+	3. If some paths have non-zero 'relative_throughput' and others
+	   have zero 'relative_throughput', ignore those paths with zero
+	   'relative_throughput'.
+
+If such optimizations can't be applied, calculate service time, and
+compare service time.
+If calculated service time is equal, the path having maximum
+'relative_throughput' may be better.  So compare 'relative_throughput'
+then.
+
+
+Examples
+========
+In case that 2 paths (sda and sdb) are used with repeat_count == 128
+and sda has an average throughput 1GB/s and sdb has 4GB/s,
+'relative_throughput' value may be '1' for sda and '4' for sdb.
+
+# echo "0 10 multipath 0 0 1 1 service-time 0 2 2 8:0 128 1 8:16 128 4" \
+  dmsetup create test
+#
+# dmsetup table
+test: 0 10 multipath 0 0 1 1 service-time 0 2 2 8:0 128 1 8:16 128 4
+#
+# dmsetup status
+test: 0 10 multipath 2 0 0 0 1 1 E 0 2 2 8:0 A 0 0 1 8:16 A 0 0 4
+
+
+Or '2' for sda and '8' for sdb would be also true.
+
+# echo "0 10 multipath 0 0 1 1 service-time 0 2 2 8:0 128 2 8:16 128 8" \
+  dmsetup create test
+#
+# dmsetup table
+test: 0 10 multipath 0 0 1 1 service-time 0 2 2 8:0 128 2 8:16 128 8
+#
+# dmsetup status
+test: 0 10 multipath 2 0 0 0 1 1 E 0 2 2 8:0 A 0 0 2 8:16 A 0 0 8
/cvs/lvm2/LVM2/doc/kernel/snapshot.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/snapshot.txt
+++ -	2011-11-15 13:54:27.941860000 +0000
@@ -0,0 +1,168 @@
+Device-mapper snapshot support
+==============================
+
+Device-mapper allows you, without massive data copying:
+
+*) To create snapshots of any block device i.e. mountable, saved states of
+the block device which are also writable without interfering with the
+original content;
+*) To create device "forks", i.e. multiple different versions of the
+same data stream.
+*) To merge a snapshot of a block device back into the snapshot's origin
+device.
+
+In the first two cases, dm copies only the chunks of data that get
+changed and uses a separate copy-on-write (COW) block device for
+storage.
+
+For snapshot merge the contents of the COW storage are merged back into
+the origin device.
+
+
+There are three dm targets available:
+snapshot, snapshot-origin, and snapshot-merge.
+
+*) snapshot-origin <origin>
+
+which will normally have one or more snapshots based on it.
+Reads will be mapped directly to the backing device. For each write, the
+original data will be saved in the <COW device> of each snapshot to keep
+its visible content unchanged, at least until the <COW device> fills up.
+
+
+*) snapshot <origin> <COW device> <persistent?> <chunksize>
+
+A snapshot of the <origin> block device is created. Changed chunks of
+<chunksize> sectors will be stored on the <COW device>.  Writes will
+only go to the <COW device>.  Reads will come from the <COW device> or
+from <origin> for unchanged data.  <COW device> will often be
+smaller than the origin and if it fills up the snapshot will become
+useless and be disabled, returning errors.  So it is important to monitor
+the amount of free space and expand the <COW device> before it fills up.
+
+<persistent?> is P (Persistent) or N (Not persistent - will not survive
+after reboot).
+The difference is that for transient snapshots less metadata must be
+saved on disk - they can be kept in memory by the kernel.
+
+
+* snapshot-merge <origin> <COW device> <persistent> <chunksize>
+
+takes the same table arguments as the snapshot target except it only
+works with persistent snapshots.  This target assumes the role of the
+"snapshot-origin" target and must not be loaded if the "snapshot-origin"
+is still present for <origin>.
+
+Creates a merging snapshot that takes control of the changed chunks
+stored in the <COW device> of an existing snapshot, through a handover
+procedure, and merges these chunks back into the <origin>.  Once merging
+has started (in the background) the <origin> may be opened and the merge
+will continue while I/O is flowing to it.  Changes to the <origin> are
+deferred until the merging snapshot's corresponding chunk(s) have been
+merged.  Once merging has started the snapshot device, associated with
+the "snapshot" target, will return -EIO when accessed.
+
+
+How snapshot is used by LVM2
+============================
+When you create the first LVM2 snapshot of a volume, four dm devices are used:
+
+1) a device containing the original mapping table of the source volume;
+2) a device used as the <COW device>;
+3) a "snapshot" device, combining #1 and #2, which is the visible snapshot
+   volume;
+4) the "original" volume (which uses the device number used by the original
+   source volume), whose table is replaced by a "snapshot-origin" mapping
+   from device #1.
+
+A fixed naming scheme is used, so with the following commands:
+
+lvcreate -L 1G -n base volumeGroup
+lvcreate -L 100M --snapshot -n snap volumeGroup/base
+
+we'll have this situation (with volumes in above order):
+
+# dmsetup table|grep volumeGroup
+
+volumeGroup-base-real: 0 2097152 linear 8:19 384
+volumeGroup-snap-cow: 0 204800 linear 8:19 2097536
+volumeGroup-snap: 0 2097152 snapshot 254:11 254:12 P 16
+volumeGroup-base: 0 2097152 snapshot-origin 254:11
+
+# ls -lL /dev/mapper/volumeGroup-*
+brw-------  1 root root 254, 11 29 ago 18:15 /dev/mapper/volumeGroup-base-real
+brw-------  1 root root 254, 12 29 ago 18:15 /dev/mapper/volumeGroup-snap-cow
+brw-------  1 root root 254, 13 29 ago 18:15 /dev/mapper/volumeGroup-snap
+brw-------  1 root root 254, 10 29 ago 18:14 /dev/mapper/volumeGroup-base
+
+
+How snapshot-merge is used by LVM2
+==================================
+A merging snapshot assumes the role of the "snapshot-origin" while
+merging.  As such the "snapshot-origin" is replaced with
+"snapshot-merge".  The "-real" device is not changed and the "-cow"
+device is renamed to <origin name>-cow to aid LVM2's cleanup of the
+merging snapshot after it completes.  The "snapshot" that hands over its
+COW device to the "snapshot-merge" is deactivated (unless using lvchange
+--refresh); but if it is left active it will simply return I/O errors.
+
+A snapshot will merge into its origin with the following command:
+
+lvconvert --merge volumeGroup/snap
+
+we'll now have this situation:
+
+# dmsetup table|grep volumeGroup
+
+volumeGroup-base-real: 0 2097152 linear 8:19 384
+volumeGroup-base-cow: 0 204800 linear 8:19 2097536
+volumeGroup-base: 0 2097152 snapshot-merge 254:11 254:12 P 16
+
+# ls -lL /dev/mapper/volumeGroup-*
+brw-------  1 root root 254, 11 29 ago 18:15 /dev/mapper/volumeGroup-base-real
+brw-------  1 root root 254, 12 29 ago 18:16 /dev/mapper/volumeGroup-base-cow
+brw-------  1 root root 254, 10 29 ago 18:16 /dev/mapper/volumeGroup-base
+
+
+How to determine when a merging is complete
+===========================================
+The snapshot-merge and snapshot status lines end with:
+  <sectors_allocated>/<total_sectors> <metadata_sectors>
+
+Both <sectors_allocated> and <total_sectors> include both data and metadata.
+During merging, the number of sectors allocated gets smaller and
+smaller.  Merging has finished when the number of sectors holding data
+is zero, in other words <sectors_allocated> == <metadata_sectors>.
+
+Here is a practical example (using a hybrid of lvm and dmsetup commands):
+
+# lvs
+  LV      VG          Attr   LSize Origin  Snap%  Move Log Copy%  Convert
+  base    volumeGroup owi-a- 4.00g
+  snap    volumeGroup swi-a- 1.00g base  18.97
+
+# dmsetup status volumeGroup-snap
+0 8388608 snapshot 397896/2097152 1560
+                                  ^^^^ metadata sectors
+
+# lvconvert --merge -b volumeGroup/snap
+  Merging of volume snap started.
+
+# lvs volumeGroup/snap
+  LV      VG          Attr   LSize Origin  Snap%  Move Log Copy%  Convert
+  base    volumeGroup Owi-a- 4.00g          17.23
+
+# dmsetup status volumeGroup-base
+0 8388608 snapshot-merge 281688/2097152 1104
+
+# dmsetup status volumeGroup-base
+0 8388608 snapshot-merge 180480/2097152 712
+
+# dmsetup status volumeGroup-base
+0 8388608 snapshot-merge 16/2097152 16
+
+Merging has finished.
+
+# lvs
+  LV      VG          Attr   LSize Origin  Snap%  Move Log Copy%  Convert
+  base    volumeGroup owi-a- 4.00g
/cvs/lvm2/LVM2/doc/kernel/striped.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/striped.txt
+++ -	2011-11-15 13:54:28.122903000 +0000
@@ -0,0 +1,58 @@
+dm-stripe
+=========
+
+Device-Mapper's "striped" target is used to create a striped (i.e. RAID-0)
+device across one or more underlying devices. Data is written in "chunks",
+with consecutive chunks rotating among the underlying devices. This can
+potentially provide improved I/O throughput by utilizing several physical
+devices in parallel.
+
+Parameters: <num devs> <chunk size> [<dev path> <offset>]+
+    <num devs>: Number of underlying devices.
+    <chunk size>: Size of each chunk of data. Must be a power-of-2 and at
+                  least as large as the system's PAGE_SIZE.
+    <dev path>: Full pathname to the underlying block-device, or a
+                "major:minor" device-number.
+    <offset>: Starting sector within the device.
+
+One or more underlying devices can be specified. The striped device size must
+be a multiple of the chunk size and a multiple of the number of underlying
+devices.
+
+
+Example scripts
+===============
+
+[[
+#!/usr/bin/perl -w
+# Create a striped device across any number of underlying devices. The device
+# will be called "stripe_dev" and have a chunk-size of 128k.
+
+my $chunk_size = 128 * 2;
+my $dev_name = "stripe_dev";
+my $num_devs = @ARGV;
+my @devs = @ARGV;
+my ($min_dev_size, $stripe_dev_size, $i);
+
+if (!$num_devs) {
+        die("Specify at least one device\n");
+}
+
+$min_dev_size = `blockdev --getsize $devs[0]`;
+for ($i = 1; $i < $num_devs; $i++) {
+        my $this_size = `blockdev --getsize $devs[$i]`;
+        $min_dev_size = ($min_dev_size < $this_size) ?
+                        $min_dev_size : $this_size;
+}
+
+$stripe_dev_size = $min_dev_size * $num_devs;
+$stripe_dev_size -= $stripe_dev_size % ($chunk_size * $num_devs);
+
+$table = "0 $stripe_dev_size striped $num_devs $chunk_size";
+for ($i = 0; $i < $num_devs; $i++) {
+        $table .= " $devs[$i] 0";
+}
+
+`echo $table | dmsetup create $dev_name`;
+]]
+
/cvs/lvm2/LVM2/doc/kernel/thin-provisioning.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/thin-provisioning.txt
+++ -	2011-11-15 13:54:28.490956000 +0000
@@ -0,0 +1,285 @@
+Introduction
+============
+
+This document descibes a collection of device-mapper targets that
+between them implement thin-provisioning and snapshots.
+
+The main highlight of this implementation, compared to the previous
+implementation of snapshots, is that it allows many virtual devices to
+be stored on the same data volume.  This simplifies administration and
+allows the sharing of data between volumes, thus reducing disk usage.
+
+Another significant feature is support for an arbitrary depth of
+recursive snapshots (snapshots of snapshots of snapshots ...).  The
+previous implementation of snapshots did this by chaining together
+lookup tables, and so performance was O(depth).  This new
+implementation uses a single data structure to avoid this degradation
+with depth.  Fragmentation may still be an issue, however, in some
+scenarios.
+
+Metadata is stored on a separate device from data, giving the
+administrator some freedom, for example to:
+
+- Improve metadata resilience by storing metadata on a mirrored volume
+  but data on a non-mirrored one.
+
+- Improve performance by storing the metadata on SSD.
+
+Status
+======
+
+These targets are very much still in the EXPERIMENTAL state.  Please
+do not yet rely on them in production.  But do experiment and offer us
+feedback.  Different use cases will have different performance
+characteristics, for example due to fragmentation of the data volume.
+
+If you find this software is not performing as expected please mail
+dm-devel at redhat.com with details and we'll try our best to improve
+things for you.
+
+Userspace tools for checking and repairing the metadata are under
+development.
+
+Cookbook
+========
+
+This section describes some quick recipes for using thin provisioning.
+They use the dmsetup program to control the device-mapper driver
+directly.  End users will be advised to use a higher-level volume
+manager such as LVM2 once support has been added.
+
+Pool device
+-----------
+
+The pool device ties together the metadata volume and the data volume.
+It maps I/O linearly to the data volume and updates the metadata via
+two mechanisms:
+
+- Function calls from the thin targets
+
+- Device-mapper 'messages' from userspace which control the creation of new
+  virtual devices amongst other things.
+
+Setting up a fresh pool device
+------------------------------
+
+Setting up a pool device requires a valid metadata device, and a
+data device.  If you do not have an existing metadata device you can
+make one by zeroing the first 4k to indicate empty metadata.
+
+    dd if=/dev/zero of=$metadata_dev bs=4096 count=1
+
+The amount of metadata you need will vary according to how many blocks
+are shared between thin devices (i.e. through snapshots).  If you have
+less sharing than average you'll need a larger-than-average metadata device.
+
+As a guide, we suggest you calculate the number of bytes to use in the
+metadata device as 48 * $data_dev_size / $data_block_size but round it up
+to 2MB if the answer is smaller.  The largest size supported is 16GB.
+
+If you're creating large numbers of snapshots which are recording large
+amounts of change, you may need find you need to increase this.
+
+Reloading a pool table
+----------------------
+
+You may reload a pool's table, indeed this is how the pool is resized
+if it runs out of space.  (N.B. While specifying a different metadata
+device when reloading is not forbidden at the moment, things will go
+wrong if it does not route I/O to exactly the same on-disk location as
+previously.)
+
+Using an existing pool device
+-----------------------------
+
+    dmsetup create pool \
+	--table "0 20971520 thin-pool $metadata_dev $data_dev \
+		 $data_block_size $low_water_mark"
+
+$data_block_size gives the smallest unit of disk space that can be
+allocated at a time expressed in units of 512-byte sectors.  People
+primarily interested in thin provisioning may want to use a value such
+as 1024 (512KB).  People doing lots of snapshotting may want a smaller value
+such as 128 (64KB).  If you are not zeroing newly-allocated data,
+a larger $data_block_size in the region of 256000 (128MB) is suggested.
+$data_block_size must be the same for the lifetime of the
+metadata device.
+
+$low_water_mark is expressed in blocks of size $data_block_size.  If
+free space on the data device drops below this level then a dm event
+will be triggered which a userspace daemon should catch allowing it to
+extend the pool device.  Only one such event will be sent.
+Resuming a device with a new table itself triggers an event so the
+userspace daemon can use this to detect a situation where a new table
+already exceeds the threshold.
+
+Thin provisioning
+-----------------
+
+i) Creating a new thinly-provisioned volume.
+
+  To create a new thinly- provisioned volume you must send a message to an
+  active pool device, /dev/mapper/pool in this example.
+
+    dmsetup message /dev/mapper/pool 0 "create_thin 0"
+
+  Here '0' is an identifier for the volume, a 24-bit number.  It's up
+  to the caller to allocate and manage these identifiers.  If the
+  identifier is already in use, the message will fail with -EEXIST.
+
+ii) Using a thinly-provisioned volume.
+
+  Thinly-provisioned volumes are activated using the 'thin' target:
+
+    dmsetup create thin --table "0 2097152 thin /dev/mapper/pool 0"
+
+  The last parameter is the identifier for the thinp device.
+
+Internal snapshots
+------------------
+
+i) Creating an internal snapshot.
+
+  Snapshots are created with another message to the pool.
+
+  N.B.  If the origin device that you wish to snapshot is active, you
+  must suspend it before creating the snapshot to avoid corruption.
+  This is NOT enforced at the moment, so please be careful!
+
+    dmsetup suspend /dev/mapper/thin
+    dmsetup message /dev/mapper/pool 0 "create_snap 1 0"
+    dmsetup resume /dev/mapper/thin
+
+  Here '1' is the identifier for the volume, a 24-bit number.  '0' is the
+  identifier for the origin device.
+
+ii) Using an internal snapshot.
+
+  Once created, the user doesn't have to worry about any connection
+  between the origin and the snapshot.  Indeed the snapshot is no
+  different from any other thinly-provisioned device and can be
+  snapshotted itself via the same method.  It's perfectly legal to
+  have only one of them active, and there's no ordering requirement on
+  activating or removing them both.  (This differs from conventional
+  device-mapper snapshots.)
+
+  Activate it exactly the same way as any other thinly-provisioned volume:
+
+    dmsetup create snap --table "0 2097152 thin /dev/mapper/pool 1"
+
+Deactivation
+------------
+
+All devices using a pool must be deactivated before the pool itself
+can be.
+
+    dmsetup remove thin
+    dmsetup remove snap
+    dmsetup remove pool
+
+Reference
+=========
+
+'thin-pool' target
+------------------
+
+i) Constructor
+
+    thin-pool <metadata dev> <data dev> <data block size (sectors)> \
+	      <low water mark (blocks)> [<number of feature args> [<arg>]*]
+
+    Optional feature arguments:
+    - 'skip_block_zeroing': skips the zeroing of newly-provisioned blocks.
+
+    Data block size must be between 64KB (128 sectors) and 1GB
+    (2097152 sectors) inclusive.
+
+
+ii) Status
+
+    <transaction id> <used metadata blocks>/<total metadata blocks>
+    <used data blocks>/<total data blocks> <held metadata root>
+
+
+    transaction id:
+	A 64-bit number used by userspace to help synchronise with metadata
+	from volume managers.
+
+    used data blocks / total data blocks
+	If the number of free blocks drops below the pool's low water mark a
+	dm event will be sent to userspace.  This event is edge-triggered and
+	it will occur only once after each resume so volume manager writers
+	should register for the event and then check the target's status.
+
+    held metadata root:
+	The location, in sectors, of the metadata root that has been
+	'held' for userspace read access.  '-' indicates there is no
+	held root.  This feature is not yet implemented so '-' is
+	always returned.
+
+iii) Messages
+
+    create_thin <dev id>
+
+	Create a new thinly-provisioned device.
+	<dev id> is an arbitrary unique 24-bit identifier chosen by
+	the caller.
+
+    create_snap <dev id> <origin id>
+
+	Create a new snapshot of another thinly-provisioned device.
+	<dev id> is an arbitrary unique 24-bit identifier chosen by
+	the caller.
+	<origin id> is the identifier of the thinly-provisioned device
+	of which the new device will be a snapshot.
+
+    delete <dev id>
+
+	Deletes a thin device.  Irreversible.
+
+    trim <dev id> <new size in sectors>
+
+	Delete mappings from the end of a thin device.  Irreversible.
+	You might want to use this if you're reducing the size of
+	your thinly-provisioned device.  In many cases, due to the
+	sharing of blocks between devices, it is not possible to
+	determine in advance how much space 'trim' will release.  (In
+	future a userspace tool might be able to perform this
+	calculation.)
+
+    set_transaction_id <current id> <new id>
+
+	Userland volume managers, such as LVM, need a way to
+	synchronise their external metadata with the internal metadata of the
+	pool target.  The thin-pool target offers to store an
+	arbitrary 64-bit transaction id and return it on the target's
+	status line.  To avoid races you must provide what you think
+	the current transaction id is when you change it with this
+	compare-and-swap message.
+
+'thin' target
+-------------
+
+i) Constructor
+
+    thin <pool dev> <dev id>
+
+    pool dev:
+	the thin-pool device, e.g. /dev/mapper/my_pool or 253:0
+
+    dev id:
+	the internal device identifier of the device to be
+	activated.
+
+The pool doesn't store any size against the thin devices.  If you
+load a thin target that is smaller than you've been using previously,
+then you'll have no access to blocks mapped beyond the end.  If you
+load a target that is bigger than before, then extra blocks will be
+provisioned as and when needed.
+
+If you wish to reduce the size of your thin device and potentially
+regain some space then send the 'trim' message to the pool.
+
+ii) Status
+
+     <nr mapped sectors> <highest mapped sector>
/cvs/lvm2/LVM2/doc/kernel/uevent.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/uevent.txt
+++ -	2011-11-15 13:54:28.900357000 +0000
@@ -0,0 +1,97 @@
+The device-mapper uevent code adds the capability to device-mapper to create
+and send kobject uevents (uevents).  Previously device-mapper events were only
+available through the ioctl interface.  The advantage of the uevents interface
+is the event contains environment attributes providing increased context for
+the event avoiding the need to query the state of the device-mapper device after
+the event is received.
+
+There are two functions currently for device-mapper events.  The first function
+listed creates the event and the second function sends the event(s).
+
+void dm_path_uevent(enum dm_uevent_type event_type, struct dm_target *ti,
+                    const char *path, unsigned nr_valid_paths)
+
+void dm_send_uevents(struct list_head *events, struct kobject *kobj)
+
+
+The variables added to the uevent environment are:
+
+Variable Name: DM_TARGET
+Uevent Action(s): KOBJ_CHANGE
+Type: string
+Description:
+Value: Name of device-mapper target that generated the event.
+
+Variable Name: DM_ACTION
+Uevent Action(s): KOBJ_CHANGE
+Type: string
+Description:
+Value: Device-mapper specific action that caused the uevent action.
+	PATH_FAILED - A path has failed.
+	PATH_REINSTATED - A path has been reinstated.
+
+Variable Name: DM_SEQNUM
+Uevent Action(s): KOBJ_CHANGE
+Type: unsigned integer
+Description: A sequence number for this specific device-mapper device.
+Value: Valid unsigned integer range.
+
+Variable Name: DM_PATH
+Uevent Action(s): KOBJ_CHANGE
+Type: string
+Description: Major and minor number of the path device pertaining to this
+event.
+Value: Path name in the form of "Major:Minor"
+
+Variable Name: DM_NR_VALID_PATHS
+Uevent Action(s): KOBJ_CHANGE
+Type: unsigned integer
+Description:
+Value: Valid unsigned integer range.
+
+Variable Name: DM_NAME
+Uevent Action(s): KOBJ_CHANGE
+Type: string
+Description: Name of the device-mapper device.
+Value: Name
+
+Variable Name: DM_UUID
+Uevent Action(s): KOBJ_CHANGE
+Type: string
+Description: UUID of the device-mapper device.
+Value: UUID. (Empty string if there isn't one.)
+
+An example of the uevents generated as captured by udevmonitor is shown
+below.
+
+1.) Path failure.
+UEVENT[1192521009.711215] change@/block/dm-3
+ACTION=change
+DEVPATH=/block/dm-3
+SUBSYSTEM=block
+DM_TARGET=multipath
+DM_ACTION=PATH_FAILED
+DM_SEQNUM=1
+DM_PATH=8:32
+DM_NR_VALID_PATHS=0
+DM_NAME=mpath2
+DM_UUID=mpath-35333333000002328
+MINOR=3
+MAJOR=253
+SEQNUM=1130
+
+2.) Path reinstate.
+UEVENT[1192521132.989927] change@/block/dm-3
+ACTION=change
+DEVPATH=/block/dm-3
+SUBSYSTEM=block
+DM_TARGET=multipath
+DM_ACTION=PATH_REINSTATED
+DM_SEQNUM=2
+DM_PATH=8:32
+DM_NR_VALID_PATHS=1
+DM_NAME=mpath2
+DM_UUID=mpath-35333333000002328
+MINOR=3
+MAJOR=253
+SEQNUM=1131
/cvs/lvm2/LVM2/doc/kernel/zero.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/kernel/zero.txt
+++ -	2011-11-15 13:54:29.875772000 +0000
@@ -0,0 +1,37 @@
+dm-zero
+=======
+
+Device-Mapper's "zero" target provides a block-device that always returns
+zero'd data on reads and silently drops writes. This is similar behavior to
+/dev/zero, but as a block-device instead of a character-device.
+
+Dm-zero has no target-specific parameters.
+
+One very interesting use of dm-zero is for creating "sparse" devices in
+conjunction with dm-snapshot. A sparse device reports a device-size larger
+than the amount of actual storage space available for that device. A user can
+write data anywhere within the sparse device and read it back like a normal
+device. Reads to previously unwritten areas will return a zero'd buffer. When
+enough data has been written to fill up the actual storage space, the sparse
+device is deactivated. This can be very useful for testing device and
+filesystem limitations.
+
+To create a sparse device, start by creating a dm-zero device that's the
+desired size of the sparse device. For this example, we'll assume a 10TB
+sparse device.
+
+TEN_TERABYTES=`expr 10 \* 1024 \* 1024 \* 1024 \* 2`   # 10 TB in sectors
+echo "0 $TEN_TERABYTES zero" | dmsetup create zero1
+
+Then create a snapshot of the zero device, using any available block-device as
+the COW device. The size of the COW device will determine the amount of real
+space available to the sparse device. For this example, we'll assume /dev/sdb1
+is an available 10GB partition.
+
+echo "0 $TEN_TERABYTES snapshot /dev/mapper/zero1 /dev/sdb1 p 128" | \
+   dmsetup create sparse1
+
+This will create a 10TB sparse device called /dev/mapper/sparse1 that has
+10GB of actual storage space available. If more than 10GB of data is written
+to this device, it will start returning I/O errors.
+


