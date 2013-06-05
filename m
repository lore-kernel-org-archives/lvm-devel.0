From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:02:36 +0000 (UTC)
Subject: dev-mornfall-lvmcache - man: lvextend --use-policies
Message-ID: <20130605120236.8157D613BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f7de58e96a2ba84bf2590465ee9f5f7929cb74d
Commit:        3f7de58e96a2ba84bf2590465ee9f5f7929cb74d
Parent:        f84f12a6a3edaac5220699dd9c6937139429d852
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 24 23:41:05 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 25 17:33:24 2013 +0200

man: lvextend --use-policies

Add missing man info.
---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |    2 +-
 man/lvextend.8.in  |   29 ++++++++++++++++++-----------
 3 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5c97eff..27ebcec 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Document lvextend --use-policies option in man.
   Fix creation and removal of clustered snapshot.
   Fix clvmd caching of metadata when suspending inactive volumes.
   Find newest timestamp of merged config files.
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index d22994e..d7300d8 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -284,7 +284,7 @@ Repair a mirror after suffering a disk failure. The mirror will be brought back
 into a consistent state.  By default, the original number of mirrors will be
 restored if possible.  Specify \fB\-y\fP on the command line to skip
 the prompts. Use \fB\-f\fP if you do not want any replacement.
-Additionally, you may use \fB\-\-use-policies\fP to use the device
+Additionally, you may use \fB\-\-use\-policies\fP to use the device
 replacement policy specified in \fBlvm.conf\fP(5),
 viz. activation/mirror_log_fault_policy or
 activation/mirror_device_fault_policy.
diff --git a/man/lvextend.8.in b/man/lvextend.8.in
index ee62a2f..c51a9dc 100644
--- a/man/lvextend.8.in
+++ b/man/lvextend.8.in
@@ -9,7 +9,7 @@ lvextend \- extend the size of a logical volume
 .RI { y | n }]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
-.RB [ \-\-noudevsync]
+.RB [ \-f | \-\-force ]
 .RB [ \-i | \-\-stripes
 .I Stripes
 .RB [ \-I | \-\-stripesize
@@ -19,9 +19,10 @@ lvextend \- extend the size of a logical volume
 |
 .BR \-L | \-\-size
 .RI [ + ] LogicalVolumeSize [ bBsSkKmMgGtTpPeE ]}
-.RB [ \-f | \-\-force ]
 .RB [ \-n | \-\-nofsck ]
+.RB [ \-\-noudevsync]
 .RB [ \-r | \-\-resizefs ]
+.RB [ \-\-use\-policies ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .I LogicalVolumePath
@@ -37,12 +38,8 @@ volume use
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
 .TP
-.B \-\-noudevsync
-Disable udev synchronisation. The
-process will not wait for notification from udev.
-It will continue irrespective of any possible udev processing
-in the background.  You should only use this if udev is not running
-or has rules that ignore the devices LVM2 creates.
+.BR \-f ", " \-\-force
+Proceed with size extension without prompting.
 .TP
 .IR \fB\-l ", " \fB\-\-extents " [" + ] LogicalExtentsNumber [ % { VG | LV | PVS | FREE | ORIGIN }]
 Extend or set the logical volume size in units of logical extents.
@@ -77,17 +74,26 @@ use a single value throughout.
 .br
 StripeSize must be 2^n (n = 2 to 9)
 .TP
-.BR \-f ", " \-\-force
-Proceed with size extension without prompting.
-.TP
 .BR \-n ", " \-\-nofsck
 Do not perform fsck before extending filesystem when filesystem
 requires it. You may need to use \fB\-\-force\fR to proceed with
 this option.
 .TP
+.B \-\-noudevsync
+Disable udev synchronisation. The
+process will not wait for notification from udev.
+It will continue irrespective of any possible udev processing
+in the background.  You should only use this if udev is not running
+or has rules that ignore the devices LVM2 creates.
+.TP
 .BR \-r ", " \-\-resizefs
 Resize underlying filesystem together with the logical volume using
 \fBfsadm\fR(8).
+.TP
+.B \-\-use\-policies
+Resizes the logical volume according to configured policy. See
+\fBlvm.conf\fR(5) for some details.
+
 .SH Examples
 Extends the size of the logical volume "vg01/lvol10" by 54MiB on physical
 volume /dev/sdk3. This is only possible if /dev/sdk3 is a member of
@@ -109,6 +115,7 @@ Extends a logical volume "vg01/lvol01" by 16MiB using physical extents
 .SH SEE ALSO
 .BR fsadm (8),
 .BR lvm (8),
+.BR lvm.conf (5),
 .BR lvcreate (8),
 .BR lvconvert (8),
 .BR lvreduce (8),


