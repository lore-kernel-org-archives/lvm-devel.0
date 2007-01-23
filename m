From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jan 2007 13:08:35 -0000
Subject: LVM2 ./WHATS_NEW man/vgchange.8 man/vgcreate.8 ...
Message-ID: <20070123130835.2457.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-23 13:08:34

Modified files:
	.              : WHATS_NEW 
	man            : vgchange.8 vgcreate.8 
	tools          : commands.h 

Log message:
	Add --clustered to man pages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.550&r2=1.551
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/WHATS_NEW	2007/01/22 15:07:20	1.550
+++ LVM2/WHATS_NEW	2007/01/23 13:08:34	1.551
@@ -1,9 +1,10 @@
 Version 2.02.20 -
 ===================================
+  Add --clustered to man pages.
   Streamline dm_report_field_* interface.
   Change remaining dmeventd terminology 'register' to 'monitor'.
   Update reporting man pages.
-  No longer necessary to specify alignment for report fields.
+  No longer necessary to specify alignment type for report fields.
 
 Version 2.02.19 - 17th January 2007
 ===================================
--- LVM2/man/vgchange.8	2006/08/18 22:35:59	1.11
+++ LVM2/man/vgchange.8	2007/01/23 13:08:34	1.12
@@ -10,6 +10,7 @@
 .RB [ \-A | \-\-autobackup " {" y | n }]
 .RB [ \-a | \-\-available " [e|l] {" y | n }]
 .RB [ \-\-monitor " {" y | n }]
+.RB [ \-c | \-\-clustered " {" y | n }]
 .RB [ \-d | \-\-debug]
 .RB [ \-\-deltag
 .IR Tag ]
@@ -44,12 +45,12 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
-.BR \-A ", " \-\-autobackup { y | n }
+.BR \-A ", " \-\-autobackup " " { y | n }
 Controls automatic backup of metadata after the change.  See
 .B vgcfgbackup (8).
 Default is yes.
 .TP
-.BR \-a ", " \-\-available [e|l] { y | n }
+.BR \-a ", " \-\-available " " [e|l] { y | n }
 Controls the availability of the logical volumes in the volume 
 group for input/output.
 In other words, makes the logical volumes known/unknown to the kernel.
@@ -60,6 +61,14 @@
 Logical volumes with single-host snapshots are always activated
 exclusively because they can only be used on one node at once.
 .TP
+.BR \-c ", " \-\-clustered " " { y | n }
+If clustered locking is enabled, this indicates whether this
+Volume Group is shared with other nodes in the cluster or whether
+it contains only local disks that are not visible on the other nodes.
+If the cluster infrastructure is unavailable on a particular node at a
+particular time, you may still be able to use Volume Groups that
+are not marked as clustered.
+.TP
 .BR \-\-monitor " " { y | n }
 Controls whether or not a mirrored logical volume is monitored by
 dmeventd, if it is installed.
@@ -108,7 +117,7 @@
  
 The 2.4 kernel has a limitation of 2TB per block device.
 .TP
-.BR \-x ", " \-\-resizeable { y | n }
+.BR \-x ", " \-\-resizeable " " { y | n }
 Enables or disables the extension/reduction of this volume group
 with/by physical volumes.
 .SH EXAMPLES
--- LVM2/man/vgcreate.8	2006/04/06 21:15:14	1.6
+++ LVM2/man/vgcreate.8	2007/01/23 13:08:34	1.7
@@ -8,6 +8,7 @@
 .RB [ \-\-alloc 
 .IR AllocationPolicy ]
 .RB [ \-A | \-\-autobackup " {" y | n }]
+.RB [ \-c | \-\-clustered " {" y | n }]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-l | \-\-maxlogicalvolumes
@@ -33,6 +34,14 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.BR \-c ", " \-\-clustered " " { y | n }
+If clustered locking is enabled, this indicates whether this
+Volume Group is shared with other nodes in the cluster or whether
+it contains only local disks that are not visible on the other nodes.
+If the cluster infrastructure is unavailable on a particular node at a
+particular time, you may still be able to use Volume Groups that
+are not marked as clustered.
+.TP
 .BR \-l ", " \-\-maxlogicalvolumes " " \fIMaxLogicalVolumes\fR
 Sets the maximum number of logical volumes allowed in this
 volume group. 
--- LVM2/tools/commands.h	2007/01/09 23:22:31	1.93
+++ LVM2/tools/commands.h	2007/01/23 13:08:34	1.94
@@ -657,7 +657,7 @@
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[--addtag Tag] " "\n"
    "\t[--alloc AllocationPolicy] " "\n"
-   "\t[-c|--clustered] " "\n"
+   "\t[-c|--clustered {y|n}] " "\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|--help]" "\n"
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"


