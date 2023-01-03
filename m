From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue,  3 Jan 2023 15:10:18 +0000 (GMT)
Subject: main - doc: fix typos in documentation
Message-ID: <20230103151018.DE80B3858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aec5e573afe610070eb2c6bed675d2a7c0efc7e8
Commit:        aec5e573afe610070eb2c6bed675d2a7c0efc7e8
Parent:        118145b07249d96f4f61521bb1daf04cc8d4c1e9
Author:        Samanta Navarro <ferivoz@riseup.net>
AuthorDate:    Fri Dec 30 11:52:49 2022 +0000
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jan 3 16:09:58 2023 +0100

doc: fix typos in documentation

Typos found with codespell.
---
 TESTING                       |  2 +-
 conf/example.conf.in          | 12 ++++++------
 doc/kernel/cache-policies.txt |  2 +-
 doc/kernel/crypt.txt          |  4 ++--
 doc/kernel/integrity.txt      |  2 +-
 doc/kernel/verity.txt         |  2 +-
 doc/lvm2-raid.txt             | 10 +++++-----
 doc/lvm_fault_handling.txt    | 10 +++++-----
 doc/lvmpolld_overview.txt     |  2 +-
 doc/tagging.txt               |  2 +-
 doc/udev_assembly.txt         |  2 +-
 libdm/make.tmpl.in            |  2 +-
 make.tmpl.in                  |  2 +-
 man/dmeventd.8_main           |  6 +++---
 man/dmsetup.8_main            |  2 +-
 man/dmstats.8_main            | 24 ++++++++++++------------
 man/lvchange.8_pregen         |  2 +-
 man/lvconvert.8_des           |  2 +-
 man/lvconvert.8_pregen        |  2 +-
 man/lvcreate.8_pregen         |  2 +-
 man/lvmcache.7_main           | 10 +++++-----
 man/lvmdevices.8_des          |  2 +-
 man/lvmdevices.8_pregen       |  2 +-
 man/lvmreport.7_main          |  6 +++---
 man/vgcfgrestore.8_des        |  2 +-
 man/vgcfgrestore.8_pregen     |  2 +-
 man/vgchange.8_pregen         |  2 +-
 udev/69-dm-lvm-metad.rules.in |  2 +-
 28 files changed, 61 insertions(+), 61 deletions(-)

diff --git a/TESTING b/TESTING
index 57932f56a..3c1e3afc6 100644
--- a/TESTING
+++ b/TESTING
@@ -24,7 +24,7 @@ You MUST disable (or mask) any LVM daemons:
 For running cluster tests, we are using singlenode locking. Pass
 `--with-clvmd=singlenode` to configure.
 
-NOTE: This is useful only for testing, and should not be used in produciton
+NOTE: This is useful only for testing, and should not be used in production
 code.
 
 To run D-Bus daemon tests, existing D-Bus session is required.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 10810d8b8..923d238e4 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -757,7 +757,7 @@ allocation {
 	# vdo_max_discard = 1
 
 	# Configuration option allocation/vdo_pool_header_size.
-	# Specified the emptry header size in KiB at the front and end of vdo pool device.
+	# Specified the empty header size in KiB at the front and end of vdo pool device.
 	# This configuration option has an automatic default value.
 	# vdo_pool_header_size = 512
 }
@@ -936,7 +936,7 @@ backup {
 	# archive = 1
 
 	# Configuration option backup/archive_dir.
-	# Location of the metdata archive files.
+	# Location of the metadata archive files.
 	# Remember to back up this directory regularly!
 	# This configuration option has an automatic default value.
 	# archive_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@"
@@ -1463,13 +1463,13 @@ activation {
 
 	# Configuration option activation/reserved_stack.
 	# Stack size in KiB to reserve for use while devices are suspended.
-	# Insufficent reserve risks I/O deadlock during device suspension.
+	# Insufficient reserve risks I/O deadlock during device suspension.
 	# This configuration option has an automatic default value.
 	# reserved_stack = 64
 
 	# Configuration option activation/reserved_memory.
 	# Memory size in KiB to reserve for use while devices are suspended.
-	# Insufficent reserve risks I/O deadlock during device suspension.
+	# Insufficient reserve risks I/O deadlock during device suspension.
 	# This configuration option has an automatic default value.
 	# reserved_memory = 8192
 
@@ -1604,7 +1604,7 @@ activation {
 	# This includes LVs that have the following segment types:
 	# raid1, raid4, raid5*, and raid6*.
 	# If a device in the LV fails, the policy determines the steps
-	# performed by dmeventd automatically, and the steps perfomed by the
+	# performed by dmeventd automatically, and the steps performed by the
 	# manual command lvconvert --repair --use-policies.
 	# Automatic handling requires dmeventd to be monitoring the LV.
 	#
@@ -1628,7 +1628,7 @@ activation {
 	# (copies) and a mirror log. A disk log ensures that a mirror LV does
 	# not need to be re-synced (all copies made the same) every time a
 	# machine reboots or crashes. If a device in the LV fails, this policy
-	# determines the steps perfomed by dmeventd automatically, and the steps
+	# determines the steps performed by dmeventd automatically, and the steps
 	# performed by the manual command lvconvert --repair --use-policies.
 	# Automatic handling requires dmeventd to be monitoring the LV.
 	#
diff --git a/doc/kernel/cache-policies.txt b/doc/kernel/cache-policies.txt
index d3ca8af21..1436dbc6e 100644
--- a/doc/kernel/cache-policies.txt
+++ b/doc/kernel/cache-policies.txt
@@ -67,7 +67,7 @@ the entries (each hotspot block covers a larger area than a single
 cache block).
 
 All this means smq uses ~25bytes per cache block.  Still a lot of
-memory, but a substantial improvement nontheless.
+memory, but a substantial improvement nonetheless.
 
 Level balancing:
 mq placed entries in different levels of the multiqueue structures
diff --git a/doc/kernel/crypt.txt b/doc/kernel/crypt.txt
index 3b3e1de21..df18572f9 100644
--- a/doc/kernel/crypt.txt
+++ b/doc/kernel/crypt.txt
@@ -35,7 +35,7 @@ Parameters: <cipher> <key> <iv_offset> <device path> \
         capi:authenc(hmac(sha256),xts(aes))-random
         capi:rfc7539(chacha20,poly1305)-random
 
-    The /proc/crypto contains a list of curently loaded crypto modes.
+    The /proc/crypto contains a list of currently loaded crypto modes.
 
 <key>
     Key used for encryption. It is encoded either as a hexadecimal number
@@ -81,7 +81,7 @@ Parameters: <cipher> <key> <iv_offset> <device path> \
 
 <#opt_params>
     Number of optional parameters. If there are no optional parameters,
-    the optional paramaters section can be skipped or #opt_params can be zero.
+    the optional parameters section can be skipped or #opt_params can be zero.
     Otherwise #opt_params is the number of following arguments.
 
     Example of optional parameters section:
diff --git a/doc/kernel/integrity.txt b/doc/kernel/integrity.txt
index 03a3b956a..0822de802 100644
--- a/doc/kernel/integrity.txt
+++ b/doc/kernel/integrity.txt
@@ -120,7 +120,7 @@ journal_crypt:algorithm(:key)	(the key is optional)
 	"salsa20", "ctr(aes)" or "ecb(arc4)").
 
 	The journal contains history of last writes to the block device,
-	an attacker reading the journal could see the last sector nubmers
+	an attacker reading the journal could see the last sector numbers
 	that were written. From the sector numbers, the attacker can infer
 	the size of files that were written. To protect against this
 	situation, you can encrypt the journal.
diff --git a/doc/kernel/verity.txt b/doc/kernel/verity.txt
index 89fd8f9a2..9822f1d61 100644
--- a/doc/kernel/verity.txt
+++ b/doc/kernel/verity.txt
@@ -65,7 +65,7 @@ Construction Parameters
 
 <#opt_params>
     Number of optional parameters. If there are no optional parameters,
-    the optional paramaters section can be skipped or #opt_params can be zero.
+    the optional parameters section can be skipped or #opt_params can be zero.
     Otherwise #opt_params is the number of following arguments.
 
     Example of optional parameters section:
diff --git a/doc/lvm2-raid.txt b/doc/lvm2-raid.txt
index a6f091543..a3226f230 100644
--- a/doc/lvm2-raid.txt
+++ b/doc/lvm2-raid.txt
@@ -37,7 +37,7 @@ segment type.  The available RAID types are:
 	"raid6_nr" - RAID6 Rotating parity N with data restart
 	"raid6_nc" - RAID6 Rotating parity N with data continuation
 The exception to 'no shorthand options' will be where the RAID implementations
-can displace traditional tagets.  This is the case with 'mirror' and 'raid1'.
+can displace traditional targets.  This is the case with 'mirror' and 'raid1'.
 In this case, "mirror_segtype_default" - found under the "global" section in
 lvm.conf - can be set to "mirror" or "raid1".  The segment type inferred when
 the '-m' option is used will be taken from this setting.  The default segment
@@ -104,7 +104,7 @@ and 4 devices for RAID 6/10.
 
 lvconvert should work exactly as it does now when dealing with mirrors -
 even if(when) we switch to MD RAID1.  Of course, there are no plans to
-allow the presense of the metadata area to be configurable (e.g. --corelog).
+allow the presence of the metadata area to be configurable (e.g. --corelog).
 It will be simple enough to detect if the LV being up/down-converted is
 new or old-style mirroring.
 
@@ -120,7 +120,7 @@ RAID4 to RAID5 or RAID5 to RAID6.
 Line 02/03/04:
 These are familiar options - all of which would now be available as options
 for change.  (However, it'd be nice if we didn't have regionsize in there.
-It's simple on the kernel side, but is just an extra - often unecessary -
+It's simple on the kernel side, but is just an extra - often unnecessary -
 parameter to many functions in the LVM codebase.)
 
 Line 05:
@@ -375,8 +375,8 @@ the slot.  Even the names of the images will be renamed to properly reflect
 their index in the array.  Unlike the "mirror" segment type, you will never have
 an image named "*_rimage_1" occupying the index position 0.
 
-As with adding images, removing images holds off on commiting LVM metadata
-until all possible changes have been made.  This reduces the likelyhood of bad
+As with adding images, removing images holds off on committing LVM metadata
+until all possible changes have been made.  This reduces the likelihood of bad
 intermediate stages being left due to a failure of operation or machine crash.
 
 RAID1 '--splitmirrors', '--trackchanges', and '--merge' operations
diff --git a/doc/lvm_fault_handling.txt b/doc/lvm_fault_handling.txt
index 53b447eac..196b782db 100644
--- a/doc/lvm_fault_handling.txt
+++ b/doc/lvm_fault_handling.txt
@@ -87,7 +87,7 @@ are as follows:
   /etc/lvm/lvm.conf.  Once this operation is complete, the logical volumes
   will be consistent.  However, the volume group will still be inconsistent -
   due to the refernced-but-missing device/PV - and operations will still be
-  restricted to the aformentioned actions until either the device is
+  restricted to the aforementioned actions until either the device is
   restored or 'vgreduce --removemissing' is run.
 
 Device Revival (transient failures):
@@ -135,9 +135,9 @@ If a mirror is not 'in-sync', a read failure will produce an I/O error.
 This error will propagate all the way up to the applications above the
 logical volume (e.g. the file system).  No automatic intervention will
 take place in this case either.  It is up to the user to decide what
-can be done/salvaged in this senario.  If the user is confident that the
+can be done/salvaged in this scenario.  If the user is confident that the
 images of the mirror are the same (or they are willing to simply attempt
-to retreive whatever data they can), 'lvconvert' can be used to eliminate
+to retrieve whatever data they can), 'lvconvert' can be used to eliminate
 the failed image and proceed.
 
 Mirror resynchronization errors:
@@ -191,11 +191,11 @@ command are set in the LVM configuration file.  They are:
   3-way mirror fails, the mirror will be converted to a 2-way mirror.
   The "allocate" policy takes the further action of trying to replace
   the failed image using space that is available in the volume group.
-  Replacing a failed mirror image will incure the cost of
+  Replacing a failed mirror image will incur the cost of
   resynchronizing - degrading the performance of the mirror.  The
   default policy for handling an image failure is "remove".  This
   allows the mirror to still function, but gives the administrator the
-  choice of when to incure the extra performance costs of replacing
+  choice of when to incur the extra performance costs of replacing
   the failed image.
 
 RAID logical volume device failures are handled differently from the "mirror"
diff --git a/doc/lvmpolld_overview.txt b/doc/lvmpolld_overview.txt
index 8c66e5e1a..ecff2eb81 100644
--- a/doc/lvmpolld_overview.txt
+++ b/doc/lvmpolld_overview.txt
@@ -63,7 +63,7 @@ classical snapshot merge, thin snapshot merge.
 
 The second store is suited only for pvmove --abort operations in-progress. Both
 stores are independent and identical LVs (pvmove /dev/sda3 and pvmove --abort /dev/sda3)
-can be run concurently from lvmpolld point of view (on lvm2 side the consistency is
+can be run concurrently from lvmpolld point of view (on lvm2 side the consistency is
 guaranteed by lvm2 locking mechanism).
 
 Locking order
diff --git a/doc/tagging.txt b/doc/tagging.txt
index b66e0ecd3..95ee02d83 100644
--- a/doc/tagging.txt
+++ b/doc/tagging.txt
@@ -126,7 +126,7 @@ Usage Examples
   followed by 'vgchange -ay vg2'
   
   
-  Option (ii) - localised admin & configuation
+  Option (ii) - localised admin & configuration
   (i.e. each host holds *locally* which classes of volumes to activate)
     # Add @database tag to vg1's metadata
     vgchange --addtag @database vg1
diff --git a/doc/udev_assembly.txt b/doc/udev_assembly.txt
index 618640273..45af41209 100644
--- a/doc/udev_assembly.txt
+++ b/doc/udev_assembly.txt
@@ -35,7 +35,7 @@ VGs from PVs as they appear, and at the same time collect information on what is
 already available. A command, pvscan --cache is expected to be used to
 implement udev rules. It is relatively easy to make this command print out a
 list of VGs (and possibly LVs) that have been made available by adding any
-particular device to the set of visible devices. In othe words, udev says "hey,
+particular device to the set of visible devices. In other words, udev says "hey,
 /dev/sdb just appeared", calls pvscan --cache, which talks to lvmetad, which
 says "cool, that makes vg0 complete". Pvscan takes this info and prints it out,
 and the udev rule can then somehow decide whether anything needs to be done
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 095fb028a..92dc715d2 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -262,7 +262,7 @@ endif
 # end of fPIC protection
 endif
 
-# Combination of DEBUG_POOL and DEBUG_ENFORCE_POOL_LOCKING is not suppored.
+# Combination of DEBUG_POOL and DEBUG_ENFORCE_POOL_LOCKING is not supported.
 #DEFS += -DDEBUG_POOL
 # Default pool locking is using the crc checksum. With mprotect memory
 # enforcing compilation faulty memory write could be easily found.
diff --git a/make.tmpl.in b/make.tmpl.in
index 869b87e12..e942893a0 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -301,7 +301,7 @@ ifeq ("@BUILD_DMEVENTD@", "yes")
   DMEVENT_LIBS = -L$(top_builddir)/daemons/dmeventd -ldevmapper-event -L$(interfacebuilddir) -ldevmapper
 endif
 
-# Combination of DEBUG_POOL and DEBUG_ENFORCE_POOL_LOCKING is not suppored.
+# Combination of DEBUG_POOL and DEBUG_ENFORCE_POOL_LOCKING is not supported.
 #DEFS += -DDEBUG_POOL
 # Default pool locking is using the crc checksum. With mprotect memory
 # enforcing compilation faulty memory write could be easily found.
diff --git a/man/dmeventd.8_main b/man/dmeventd.8_main
index c03605d9c..77b07e4d8 100644
--- a/man/dmeventd.8_main
+++ b/man/dmeventd.8_main
@@ -103,7 +103,7 @@ when it's been filled above configured threshold
 \fBactivation/thin_pool_autoextend_threshold\fP.
 If the command fails, dmeventd thin plugin will keep
 retrying execution with increasing time delay between
-retries upto 42 minutes.
+retries up to 42 minutes.
 User may also configure external command to support more advanced
 maintenance operations of a thin pool.
 Such external command can e.g. remove some unneeded snapshots,
@@ -133,7 +133,7 @@ when it's been filled above the configured threshold
 \fBactivation/vdo_pool_autoextend_threshold\fP.
 If the command fails, dmeventd vdo plugin will keep
 retrying execution with increasing time delay between
-retries upto 42 minutes.
+retries up to 42 minutes.
 User may also configure external command to support more advanced
 maintenance operations of a VDO pool.
 Such external command can e.g. remove some unneeded space
@@ -166,7 +166,7 @@ actual usage of VDO pool data volume. Variable is not set when error event
 is processed.
 .TP
 .B LVM_RUN_BY_DMEVENTD
-Variable is set by thin and vdo plugin to prohibit recursive interation
+Variable is set by thin and vdo plugin to prohibit recursive interaction
 with dmeventd by any executed lvm2 command from
 a thin_command, vdo_command environment.
 .
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 6260396e6..2c8095667 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -572,7 +572,7 @@ See below for more information on the table format.
 .B --udevcookie \fIcookie
 Use cookie for udev synchronisation.
 Note: Same cookie should be used for same type of operations i.e. creation of
-multiple different devices. It's not adviced to combine different
+multiple different devices. It's not advised to combine different
 operations on the single device.
 .
 .TP
diff --git a/man/dmstats.8_main b/man/dmstats.8_main
index 4f9a9fc7f..eb160751b 100644
--- a/man/dmstats.8_main
+++ b/man/dmstats.8_main
@@ -292,7 +292,7 @@ region identifier.
 .
 .TP
 .B --area
-When peforming a list or report, include objects of type area in the
+When performing a list or report, include objects of type area in the
 results.
 .
 .TP
@@ -317,7 +317,7 @@ argument is zero reports will continue to repeat until interrupted.
 .
 .TP
 .B --group
-When peforming a list or report, include objects of type group in the
+When performing a list or report, include objects of type group in the
 results.
 .
 .TP
@@ -389,7 +389,7 @@ region as a comma separated list of latency values. Latency values are
 given in nanoseconds. An optional unit suffix of
 .BR ns , us , ms ,
 or \fBs\fP may be given after each value to specify units of
-nanoseconds, microseconds, miliseconds or seconds respectively.
+nanoseconds, microseconds, milliseconds or seconds respectively.
 .
 .TP
 .B --histogram
@@ -456,7 +456,7 @@ default program ID for dmstats-managed regions is "dmstats".
 .
 .TP
 .B --region
-When peforming a list or report, include objects of type region in the
+When performing a list or report, include objects of type region in the
 results.
 .
 .TP
@@ -530,7 +530,7 @@ Produce additional output.
 .HP
 .CMD_CLEAR
 .br
-Instructs the kernel to clear statistics counters for the speficied
+Instructs the kernel to clear statistics counters for the specified
 regions (with the exception of in-flight IO counters).
 .
 .HP
@@ -556,10 +556,10 @@ configured interval duration) on the final bin.
 .sp
 Latencies are given in nanoseconds. An optional unit suffix of ns, us,
 ms, or s may be given after each value to specify units of nanoseconds,
-microseconds, miliseconds or seconds respectively, so for example, 10ms
+microseconds, milliseconds or seconds respectively, so for example, 10ms
 is equivalent to 10000000. Latency values with a precision of less than
-one milisecond can only be used when precise timestamps are enabled: if
-\fB--precise\fP is not given and values less than one milisecond are
+one millisecond can only be used when precise timestamps are enabled: if
+\fB--precise\fP is not given and values less than one millisecond are
 used it will be enabled automatically.
 .sp
 An optional \fBprogram_id\fP or \fBuser_data\fP string may be associated
@@ -627,7 +627,7 @@ group.
 The list of regions to be grouped is specified with \fB--regions\fP
 and an optional alias may be assigned with \fB--alias\fP. The set of
 regions is given as a comma-separated list of region identifiers. A
-continuous range of identifers spanning from \fBR1\fP to \fBR2\fP may
+continuous range of identifiers spanning from \fBR1\fP to \fBR2\fP may
 be expressed as '\fBR1\fP-\fBR2\fP'.
 .sp
 Regions that have a histogram configured can be grouped: in this case
@@ -711,7 +711,7 @@ that were previously created with \fB--filemap\fP, either directly,
 or by starting the monitoring daemon, \fBdmfilemapd\fP.
 .sp
 This will add and remove regions to reflect changes in the allocated
-extents of the file on-disk, since the time that it was crated or last
+extents of the file on-disk, since the time that it was created or last
 updated.
 .sp
 Use of this command is not normally needed since the \fBdmfilemapd\fP
@@ -1090,13 +1090,13 @@ bounds.
 .B hist_bounds
 A list of the histogram boundary values for the current statistics area
 in order of ascending latency value.  The values are expressed in whole
-units of seconds, miliseconds, microseconds or nanoseconds with a suffix
+units of seconds, milliseconds, microseconds or nanoseconds with a suffix
 indicating the unit.
 .TP
 .B hist_ranges
 A list of the histogram bin ranges for the current statistics area in
 order of ascending latency value.  The values are expressed as
-"LOWER-UPPER" in whole units of seconds, miliseconds, microseconds or
+"LOWER-UPPER" in whole units of seconds, milliseconds, microseconds or
 nanoseconds with a suffix indicating the unit.
 .TP
 .B hist_bins
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 90aec5483..3f613482e 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -745,7 +745,7 @@ See \fBlvmraid\fP(7) for more information.
 .br
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
-automated maintenance for the LV in reponse to specific events.
+automated maintenance for the LV in response to specific events.
 See \fBdmeventd\fP(8) for more information.
 .
 .HP
diff --git a/man/lvconvert.8_des b/man/lvconvert.8_des
index f36135f21..1bc3dfa11 100644
--- a/man/lvconvert.8_des
+++ b/man/lvconvert.8_des
@@ -23,7 +23,7 @@ The
 type is equivalent to the
 .B striped
 type when one stripe exists.
-In that case, the types can sometimes be used interchangably.
+In that case, the types can sometimes be used interchangeably.
 .P
 In most cases, the
 .B mirror
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 1e5582bf9..035ae4246 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -196,7 +196,7 @@ The
 type is equivalent to the
 .B striped
 type when one stripe exists.
-In that case, the types can sometimes be used interchangably.
+In that case, the types can sometimes be used interchangeably.
 .P
 In most cases, the
 .B mirror
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index cde896b7a..528a9db9c 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -1176,7 +1176,7 @@ See \fBlvmraid\fP(7) for more information.
 .br
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
-automated maintenance for the LV in reponse to specific events.
+automated maintenance for the LV in response to specific events.
 See \fBdmeventd\fP(8) for more information.
 .
 .HP
diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index fdb375083..965e1cbdd 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -73,7 +73,7 @@ using dm-writecache (with cachevol):
 .P
 # lvconvert --type writecache --cachevol fast vg/main
 .P
-For more alteratives see:
+For more alternatives see:
 .br
 dm-cache command shortcut
 .br
@@ -252,7 +252,7 @@ when selecting the writecache cachevol size and the writecache block size.
 .P
 .IP \[bu] 2
 writecache block size 4096: each 100 GiB of writecache cachevol uses
-slighly over 2 GiB of system memory.
+slightly over 2 GiB of system memory.
 .IP \[bu] 2
 writecache block size 512: each 100 GiB of writecache cachevol uses
 a little over 16 GiB of system memory.
@@ -311,11 +311,11 @@ read requests.
 .TP
 autocommit_blocks = <count>
 When the application writes this amount of blocks without issuing the
-FLUSH request, the blocks are automatically commited.
+FLUSH request, the blocks are automatically committed.
 .
 .TP 
 autocommit_time = <milliseconds>
-The data is automatically commited if this time passes and no FLUSH
+The data is automatically committed if this time passes and no FLUSH
 request is received.
 .
 .TP
@@ -478,7 +478,7 @@ cache, in which small reads and writes cause large sections of an LV to be
 stored in the cache. It can also require increasing migration threshold
 which defaults to 2048 sectors (1 MiB). Lvm2 ensures migration threshold is
 at least 8 chunks in size. This may in some cases result in very
-high bandwidth load of transfering data between the cache LV and its
+high bandwidth load of transferring data between the cache LV and its
 cache origin LV. However, choosing a chunk size that is too small
 can result in more overhead trying to manage the numerous chunks that
 become mapped into the cache.  Overhead can include both excessive CPU
diff --git a/man/lvmdevices.8_des b/man/lvmdevices.8_des
index 289aad466..4e7e39aef 100644
--- a/man/lvmdevices.8_des
+++ b/man/lvmdevices.8_des
@@ -96,7 +96,7 @@ is used for loop devices, the backing file name repored by sysfs.
 the device name is used if no other type applies.
 .P
 
-The default choice for device ID type can be overriden using lvmdevices
+The default choice for device ID type can be overridden using lvmdevices
 --addev --deviceidtype <type>.  If the specified type is available for the
 device it will be used, otherwise the device will be added using the type
 that would otherwise be chosen.
diff --git a/man/lvmdevices.8_pregen b/man/lvmdevices.8_pregen
index 86fe7e015..0af1dbe07 100644
--- a/man/lvmdevices.8_pregen
+++ b/man/lvmdevices.8_pregen
@@ -163,7 +163,7 @@ is used for loop devices, the backing file name repored by sysfs.
 the device name is used if no other type applies.
 .P
 
-The default choice for device ID type can be overriden using lvmdevices
+The default choice for device ID type can be overridden using lvmdevices
 --addev --deviceidtype <type>.  If the specified type is available for the
 device it will be used, otherwise the device will be added using the type
 that would otherwise be chosen.
diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index 0015cdce7..49c254846 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -1197,7 +1197,7 @@ But let's still use the original "," character for list_item_separator
 for subsequent examples.
 .P
 Format for any of time values displayed in reports can be configured with
-\fBreport/time_format\fP configuretion setting. By default complete date
+\fBreport/time_format\fP configuration setting. By default complete date
 and time is displayed, including timezone.
 .P
 .nf
@@ -1302,11 +1302,11 @@ binary_values_as_numeric=1
 .SS Changing output format
 .
 LVM can output reports in different formats - use \fBreport/output_format\fP
-configuration setting (or \fB--reportformat\fP command line option) to swith
+configuration setting (or \fB--reportformat\fP command line option) to switch
 the report output format.
 
 .P
-Currently, LVM supports these outpout formats:
+Currently, LVM supports these output formats:
 .RS
 - \fB"basic"\fP (all the examples we used above used this format),
 .br
diff --git a/man/vgcfgrestore.8_des b/man/vgcfgrestore.8_des
index dbc9aee16..10aa460c6 100644
--- a/man/vgcfgrestore.8_des
+++ b/man/vgcfgrestore.8_des
@@ -1,6 +1,6 @@
 vgcfgrestore restores the metadata of a VG from a text back up file
 produced by \fBvgcfgbackup\fP. This writes VG metadata onto the devices
-specifed in back up file.
+specified in back up file.
 .P
 A back up file can be specified with \fB--file\fP.  If no backup file is
 specified, the most recent one is used. Use \fB--list\fP for a list of
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index d9d4a2a76..76be536a1 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -63,7 +63,7 @@ vgcfgrestore \(em Restore volume group configuration
 .
 vgcfgrestore restores the metadata of a VG from a text back up file
 produced by \fBvgcfgbackup\fP. This writes VG metadata onto the devices
-specifed in back up file.
+specified in back up file.
 .P
 A back up file can be specified with \fB--file\fP.  If no backup file is
 specified, the most recent one is used. Use \fB--list\fP for a list of
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 7fa1cbb10..5ab59204d 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -684,7 +684,7 @@ See \fBlvm.conf\fP(5) for more information about profiles.
 .br
 Start (yes) or stop (no) monitoring an LV with dmeventd.
 dmeventd monitors kernel events for an LV, and performs
-automated maintenance for the LV in reponse to specific events.
+automated maintenance for the LV in response to specific events.
 See \fBdmeventd\fP(8) for more information.
 .
 .HP
diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index a2384f2af..aec13f039 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -87,7 +87,7 @@ LABEL="systemd_background"
 #
 # In this case, we simply set up the dependency between the device and the pvscan
 # job using SYSTEMD_ALIAS (which sets up a simplified device identifier that
-# allows using "BindsTo" in the sytemd unit file) and SYSTEMD_WANTS (which tells
+# allows using "BindsTo" in the systemd unit file) and SYSTEMD_WANTS (which tells
 # systemd to start the pvscan job once the device is ready).
 # We need to set these variables for both "add" and "change" events, otherwise
 # systemd may loose information about the device/unit dependencies.

