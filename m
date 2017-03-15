From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Wed, 15 Mar 2017 19:23:49 -0400
Subject: master - man: Minor clarifications and grammar corrections for lvmraid.7
Message-ID: <201703152323.v2FNNngc012028@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=849ab38e3cd6d612d55a3457f5ce94779afb6cbc
Commit:        849ab38e3cd6d612d55a3457f5ce94779afb6cbc
Parent:        7b6ee130cc5cf0e466d9b91b7b7726267575d310
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Mar 15 18:19:29 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Mar 15 18:19:29 2017 -0500

man:  Minor clarifications and grammar corrections for lvmraid.7

---
 man/lvmraid.7_main |   53 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 29 insertions(+), 24 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index dc07f2e..d738cf8 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -20,7 +20,7 @@ from the Linux kernel.  DM is used to create and manage visible LVM
 devices, and MD is used to place data on physical devices.
 
 LVM creates hidden LVs (dm devices) layered between the visible LV and
-physical devices.  LVs in that middle layers are called sub LVs.
+physical devices.  LVs in the middle layers are called sub LVs.
 For LVM raid, a sub LV pair to store data and metadata (raid superblock
 and bitmap) is created per raid image/leg (see lvs command examples below).
 
@@ -74,7 +74,8 @@ data that is written to one device before moving to the next.
 .P
 
 \fIPVs\fP specifies the devices to use.  If not specified, lvm will choose
-\fINumber\fP devices, one for each stripe.
+\fINumber\fP devices, one for each stripe based on the number of PVs
+available or supplied.
 
 .SS raid1
 
@@ -116,8 +117,9 @@ minimum number of devices required is 3.
 .HP
 .B \-\-stripes
 specifies the number of devices to use for LV data.  This does not include
-the extra device lvm adds for storing parity blocks.  \fINumber\fP stripes
-requires \fINumber\fP+1 devices.  \fINumber\fP must be 2 or more.
+the extra device lvm adds for storing parity blocks.  A raid4 LV with
+\fINumber\fP stripes requires \fINumber\fP+1 devices.  \fINumber\fP must
+be 2 or more.
 
 .HP
 .B \-\-stripesize
@@ -149,8 +151,9 @@ from a single device.  The minimum number of devices required is 3.
 .HP
 .B \-\-stripes
 specifies the number of devices to use for LV data.  This does not include
-the extra device lvm adds for storing parity blocks.  \fINumber\fP stripes
-requires \fINumber\fP+1 devices.  \fINumber\fP must be 2 or more.
+the extra device lvm adds for storing parity blocks.  A raid5 LV with
+\fINumber\fP stripes requires \fINumber\fP+1 devices.  \fINumber\fP must
+be 2 or more.
 
 .HP
 .B \-\-stripesize
@@ -186,8 +189,9 @@ number of devices required is 5.
 .HP
 .B \-\-stripes
 specifies the number of devices to use for LV data.  This does not include
-the extra two devices lvm adds for storing parity blocks.  \fINumber\fP
-stripes requires \fINumber\fP+2 devices.  \fINumber\fP must be 3 or more.
+the extra two devices lvm adds for storing parity blocks.  A raid6 LV with
+\fINumber\fP stripes requires \fINumber\fP+2 devices.  \fINumber\fP must be
+3 or more.
 
 .HP
 .B \-\-stripesize
@@ -252,8 +256,8 @@ less tolerant of device failures.
 
 .SH Synchronization
 
-Synchronization makes all the devices in a RAID LV consistent with each
-other.
+Synchronization is the process that makes all the devices in a RAID LV
+consistent with each other.
 
 In a RAID1 LV, all mirror images should have the same data.  When a new
 mirror image is added, or a mirror image is missing data, then images need
@@ -285,7 +289,7 @@ following command, where "image synced" means sync is complete:
 
 .SS Scrubbing
 
-Scrubbing is a full scan/synchronization of the RAID LV requested by a user.
+Scrubbing is a full scan of the RAID LV requested by a user.
 Scrubbing can find problems that are missed by partial synchronization.
 
 Scrubbing assumes that RAID metadata and bitmaps may be inaccurate, so it
@@ -367,15 +371,15 @@ not know which data is correct.  The result may be consistent but
 incorrect data.  When two different blocks of data must be made
 consistent, it chooses the block from the device that would be used during
 RAID intialization.  However, if the PV holding corrupt data is known,
-lvchange \-\-rebuild can be used to reconstruct the data on the bad
-device.
+lvchange \-\-rebuild can be used in place of scrubbing to reconstruct the
+data on the bad device.
 
 Future developments might include:
 
 Allowing a user to choose the correct version of data during repair.
 
 Using a majority of devices to determine the correct version of data to
-use in a three-way RAID1 or RAID6 LV.
+use in a 3-way RAID1 or RAID6 LV.
 
 Using a checksumming device to pin-point when and where an error occurs,
 allowing it to be rewritten.
@@ -387,7 +391,7 @@ An LV is often a combination of other hidden LVs called SubLVs.  The
 SubLVs either use physical devices, or are built from other SubLVs
 themselves.  SubLVs hold LV data blocks, RAID parity blocks, and RAID
 metadata.  SubLVs are generally hidden, so the lvs \-a option is required
-display them:
+to display them:
 
 .B lvs -a -o name,segtype,devices
 
@@ -559,8 +563,8 @@ RAID6 LVs can tolerate losing two devices without LV data loss.
 
 .IP \[bu] 3
 RAID10 is variable, and depends on which devices are lost.  It can
-tolerate losing all but one device in a single raid1 mirror without
-LV data loss.
+tolerate losing all but one device in a raid1 set, where each stripe
+is composed of a raid1 set, without LV data loss.
 
 .P
 
@@ -621,7 +625,7 @@ tolerate the number of missing devices without LV data loss.
 .br
 The LV is always activated, even if portions of the LV data are missing
 because of the missing device(s).  This should only be used to perform
-recovery or repair operations.
+extreme recovery or repair operations.
 
 .BR lvm.conf (5)
 .B activation/activation_mode
@@ -635,7 +639,7 @@ lvmconfig --type default activation/activation_mode
 
 .SS Replacing Devices
 
-Devices in a RAID LV can be replaced with other devices in the VG.  When
+Devices in a RAID LV can be replaced by other devices in the VG.  When
 replacing devices that are no longer visible on the system, use lvconvert
 \-\-repair.  When replacing devices that are still visible, use lvconvert
 \-\-replace.  The repair command will attempt to restore the same number
@@ -709,8 +713,9 @@ replace failed devices.
 .B allocate
 .br
 dmeventd automatically attempts to repair the LV using spare devices
-in the VG.  Note that even a transient failure is handled as a permanent
-failure; a new device is allocated and full synchronization is started.
+in the VG.  Note that even a transient failure is treated as a permanent
+failure under this setting.  A new device is allocated and full
+synchronization is started.
 
 The specific command run by dmeventd to warn or repair is:
 .br
@@ -720,8 +725,8 @@ The specific command run by dmeventd to warn or repair is:
 
 .SS Corrupted Data
 
-Data on a device can be corrupted due to hardware errors, without the
-device ever being disconnected, and without any fault in the software.
+Data on a device can be corrupted due to hardware errors without the
+device ever being disconnected or there being any fault in the software.
 This should be rare, and can be detected (see \fBScrubbing\fP).
 
 
@@ -1023,7 +1028,7 @@ stripes.
 When changing the RAID layout or stripe size, no new SubLVs (MetaLVs or
 DataLVs) need to be allocated, but DataLVs are extended by a small amount
 (typically 1 extent).  The extra space allows blocks in a stripe to be
-updated safely, and not corrupted in case of a crash.  If a crash occurs,
+updated safely, and not be corrupted in case of a crash.  If a crash occurs,
 reshaping can just be restarted.
 
 (If blocks in a stripe were updated in place, a crash could leave them


