From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 22 Jul 2013 18:03:10 +0000 (UTC)
Subject: master - Man Pages: Update man pages to reflect changes to various RAID options
Message-ID: <20130722180310.C2D6C6130D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb5a6a0d1a867aa793e68f99c9a01027b182af65
Commit:        eb5a6a0d1a867aa793e68f99c9a01027b182af65
Parent:        f6ded62291682e40c7976d27e48915d9d1538940
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jul 22 13:02:32 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jul 22 13:02:32 2013 -0500

Man Pages:  Update man pages to reflect changes to various RAID options

Some of the names for various RAID options have been changed and the man
pages need to reflect it.
lvcreate:
	from: minrecoveryrate	to: [raid]minrecoveryrate
	from: maxrecoveryrate	to: [raid]maxrecoveryrate
	* plus better clarity on what the arg to these options is
	  specifying

lvchange:
	from: minrecoveryrate   to: [raid]minrecoveryrate
	from: maxrecoveryrate   to: [raid]maxrecoveryrate
	* plus better clarity on what the arg to these options is
	  specifying
	from: syncaction        to: [raid]syncaction
	from: writebehind	to  [raid]writebehind
	* plus change arg from BehindCount to IO/count
	from: writemostly	to: [raid]writemostly
	* plus addition to document [:{t|n|y}] option
lvs:
	from: mismatches	to: raid_mismatch_count
	from: sync_action	to: raid_sync_action
	add : raid_min|max_recovery_rate, raid_write_behind
---
 man/lvchange.8.in |   68 +++++++++++++++++++++++++++-------------------------
 man/lvcreate.8.in |   20 +++++++-------
 man/lvs.8.in      |    7 ++++-
 3 files changed, 50 insertions(+), 45 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 3b6c574..ea8a6ef 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -31,12 +31,16 @@ lvchange \- change attributes of a logical volume
 .RI { y | n }]
 .RB [ \-\-poll
 .RI { y | n }]
-.RB [ \-\-maxrecoveryrate
+.RB [ \-\-[raid]maxrecoveryrate
 .IR Rate ]
-.RB [ \-\-minrecoveryrate
+.RB [ \-\-[raid]minrecoveryrate
 .IR Rate ]
-.RB [ \-\-syncaction
+.RB [ \-\-[raid]syncaction
 .RI { check | repair }]
+.RB [ \-\-[raid]writebehind
+.IR IOCount ]
+.RB [ \-\-[raid]writemostly
+.IR PhysicalVolume[:{t|n|y}] ]
 .RB [ \-\-sysinit ]
 .RB [ \-\-noudevsync ]
 .RB [ \-M | \-\-persistent
@@ -51,8 +55,6 @@ lvchange \- change attributes of a logical volume
 .RB [ \-\-refresh ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
-.RB [ \-\-writebehind BehindCount ]
-.RB [ \-\-writemostly PhysicalVolume ]
 .RB [ \-Z | \-\-zero
 .RI { y | n }]
 .I LogicalVolumePath
@@ -138,19 +140,19 @@ process from its last checkpoint.  However, it may not be appropriate to
 immediately poll a logical volume when it is activated, use
 \fB\-\-poll n\fP to defer and then \fB\-\-poll y\fP to restart the process.
 .TP
-.IR \fB\-\-maxrecoveryrate " " \fIRate [ bBsSkKmMgG ]
+.IR \fB\-\-[raid]maxrecoveryrate " " \fIRate [ bBsSkKmMgG ]
 Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
-is specified as a size/sec/device.  If no suffix is given, then
-kiB/sec/device is assumed.  Setting the recovery rate to 0 means
-it will be unbounded.
+is specified as an amount per second for each device in the array.
+If no suffix is given, then kiB/sec/device is assumed.  Setting the
+recovery rate to 0 means it will be unbounded.
 .TP
-.IR \fB\-\-minrecoveryrate " " \fIRate [ bBsSkKmMgG ]
+.IR \fB\-\-[raid]minrecoveryrate " " \fIRate [ bBsSkKmMgG ]
 Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
-is specified as a size/sec/device.  If no suffix is given, then
-kiB/sec/device is assumed.  Setting the recovery rate to 0 means
-it will be unbounded.
+is specified as an amount per second for each device in the array.
+If no suffix is given, then kiB/sec/device is assumed.  Setting the
+recovery rate to 0 means it will be unbounded.
 .TP
-.BR \-\-syncaction " {" \fIcheck | \fIrepair }
+.BR \-\-[raid]syncaction " {" \fIcheck | \fIrepair }
 This argument is used to initiate various RAID synchronization operations.
 The \fIcheck\fP and \fIrepair\fP options provide a way to check the
 integrity of a RAID logical volume (often referred to as "scrubbing").
@@ -162,6 +164,25 @@ If \fIrepair\fP is used, the discrepancies will be corrected as they are
 encountered.  The 'lvs' command can be used to show the number of
 discrepancies found or repaired.
 .TP
+.BR \-\-[raid]writebehind " IOCount"
+Specify the maximum number of outstanding writes that are allowed to
+devices in a RAID1 logical volume that are marked as \fIwrite-mostly\fP.
+Once this value is exceeded, writes become synchronous (i.e. all writes
+to the constituent devices must complete before the array signals the
+write has completed).  Setting the value to zero clears the preference
+and allows the system to choose the value arbitrarily.
+.TP
+.BR \-\-[raid]writemostly " PhysicalVolume[:{t|y|n}]"
+Mark a device in a RAID1 logical volume as \fIwrite-mostly\fP.  All reads
+to these drives will be avoided unless absolutely necessary.  This keeps
+the number of I/Os to the drive to a minimum.  The default behavior is to
+set the write-mostly attribute for the specified physical volume in the
+logical volume.  It is possible to also remove the write-mostly flag by
+appending a ":n" to the physical volume or to toggle the value by specifying
+":t".  The \fI--writemostly\fP argument can be specified more than one time
+in a single command; making it possible to toggle the write-mostly attributes
+for all the physical volumes in a logical volume at once.
+.TP
 .B \-\-sysinit
 Indicates that \fBlvchange\fP(8) is being invoked from early system
 initialisation scripts (e.g. rc.sysinit or an initrd),
@@ -210,25 +231,6 @@ This is not necessary in normal operation, but may be useful
 if something has gone wrong or if you're doing clustering
 manually without a clustered lock manager.
 .TP
-.BR \-\-writebehind " BehindCount"
-Specify the maximum number of outstanding writes that are allowed to
-devices in a RAID 1 logical volume that are marked as \fIwrite-mostly\fP.
-Once this value is exceeded, writes become synchronous (i.e. all writes
-to the constituent devices must complete before the array signals the
-write has completed).  Setting the value to zero clears the preference
-and allows the system to choose the value arbitrarily.
-.TP
-.BR \-\-writemostly " PhysicalVolume[:{t|y|n}]"
-Mark a device in a RAID1 logical volume as \fIwrite-mostly\fP.  All reads
-to these drives will be avoided unless absolutely necessary.  This keeps
-the number of I/Os to the drive to a minimum.  The default behavior is to
-set the write-mostly attribute for the specified physical volume in the
-logical volume.  It is possible to also remove the write-mostly flag by
-appending a ":n" to the physical volume or to toggle the value by specifying
-":t".  The \fI--writemostly\fP argument can be specified more than one time
-in a single command; making it possible to toggle the write-mostly attributes
-for all the physical volumes in a logical volume at once.
-.TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
 Set zeroing mode for thin pool. Note: already provisioned blocks from pool
 in non-zero mode are not cleared in unwritten parts when setting zero to
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index ecbf363..681ff68 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -22,9 +22,9 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-\-ignoremonitoring ]
 .RB [ \-\-monitor
 .RI { y | n }]
-.RB [ \-\-maxrecoveryrate
+.RB [ \-\-[raid]maxrecoveryrate
 .IR Rate ]
-.RB [ \-\-minrecoveryrate
+.RB [ \-\-[raid]minrecoveryrate
 .IR Rate ]
 .RB [ \-i | \-\-stripes
 .IR Stripes
@@ -265,17 +265,17 @@ Sets the name for the new logical volume.
 Without this option a default name of "lvol#" will be generated where
 # is the LVM internal number of the logical volume.
 .TP
-.IR \fB\-\-maxrecoveryrate " " \fIRate [ bBsSkKmMgG ]
+.IR \fB\-\-[raid]maxrecoveryrate " " \fIRate [ bBsSkKmMgG ]
 Sets the maximum recovery rate for a RAID logical volume.  \fIRate\fP
-is specified as a size/sec/device.  If no suffix is given, then
-kiB/sec/device is assumed.  Setting the recovery rate to 0 means
-it will be unbounded.
+is specified as an amount per second for each device in the array.
+If no suffix is given, then kiB/sec/device is assumed.  Setting the
+recovery rate to 0 means it will be unbounded.
 .TP
-.IR \fB\-\-minrecoveryrate " " \fIRate [ bBsSkKmMgG ]
+.IR \fB\-\-[raid]minrecoveryrate " " \fIRate [ bBsSkKmMgG ]
 Sets the minimum recovery rate for a RAID logical volume.  \fIRate\fP
-is specified as a size/sec/device.  If no suffix is given, then
-kiB/sec/device is assumed.  Setting the recovery rate to 0 means
-it will be unbounded.
+is specified as an amount per second for each device in the array.
+If no suffix is given, then kiB/sec/device is assumed.  Setting the
+recovery rate to 0 means it will be unbounded.
 .TP
 .B \-\-noudevsync
 Disables udev synchronisation. The
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 4da4370..8f97dc2 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -98,12 +98,16 @@ lv_time,
 lv_uuid,
 metadata_lv,
 mirror_log,
-mismatches,
 modules,
 move_pv,
 origin,
 origin_size,
 pool_lv,
+raid_max_recovery_rate,
+raid_min_recovery_rate,
+raid_mismatch_count,
+raid_sync_action,
+raid_write_behind,
 region_size,
 segtype,
 seg_count,
@@ -115,7 +119,6 @@ seg_tags,
 snap_percent,
 stripes,
 stripe_size,
-sync_action,
 sync_percent,
 thin_count,
 transaction_id,


