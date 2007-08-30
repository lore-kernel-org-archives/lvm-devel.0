From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Aug 2007 19:34:20 -0000
Subject: LVM2 ./WHATS_NEW man/lvconvert.8 man/lvcreate. ...
Message-ID: <20070830193420.24093.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-08-30 19:34:19

Modified files:
	.              : WHATS_NEW 
	man            : lvconvert.8 lvcreate.8 
	tools          : lvconvert.c lvcreate.c 

Log message:
	Avoid error when --corelog is provided without --mirrorlog. (2.02.28)
	Correct --mirrorlog argument name in man pages (not --log).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.699&r2=1.700
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/WHATS_NEW	2007/08/30 18:53:32	1.699
+++ LVM2/WHATS_NEW	2007/08/30 19:34:18	1.700
@@ -1,6 +1,8 @@
 Version 2.02.29 -
 ==================================
-  Clear MIRROR_NOTSYNCED lv flag when converting from mirror to linear.
+  Avoid error when --corelog is provided without --mirrorlog. (2.02.28)
+  Correct --mirrorlog argument name in man pages (not --log).
+  Clear MIRROR_NOTSYNCED LV flag when converting from mirror to linear.
   Modify lvremove to prompt for removal if LV active on other cluster nodes.
   Add '-f' to vgremove to force removal of VG even if LVs exist.
   
--- LVM2/man/lvconvert.8	2007/08/24 21:01:52	1.8
+++ LVM2/man/lvconvert.8	2007/08/30 19:34:19	1.9
@@ -47,7 +47,7 @@
 time the device is activated - perhaps, for example, after every reboot.
 .TP
 .I \-\-corelog
-The optional argument "--corelog" is the same as specifying "--log core".
+The optional argument "--corelog" is the same as specifying "--mirrorlog core".
 .TP
 .I \-R, \-\-regionsize MirrorLogRegionSize
 A mirror is divided into regions of this size (in MB), and the mirror log
@@ -71,12 +71,12 @@
 converts the linear logical volume "vg00/lvol1" to
 a two-way mirror logical volume.
 
-"lvconvert --log core vg00/lvol1"
+"lvconvert --mirrorlog core vg00/lvol1"
 .br
 converts a mirror with a disk log to a
 mirror with an in-memory log.
 
-"lvconvert --log disk vg00/lvol1"
+"lvconvert --mirrorlog disk vg00/lvol1"
 .br
 converts a mirror with an in-memory log
 to a mirror with a disk log.
--- LVM2/man/lvcreate.8	2007/08/24 21:01:52	1.17
+++ LVM2/man/lvcreate.8	2007/08/30 19:34:19	1.18
@@ -102,7 +102,7 @@
 by copying the data from the first device again each time the
 device is activated, for example, after every reboot.
 
-The optional argument --corelog is equivalent to --log core.
+The optional argument --corelog is equivalent to --mirrorlog core.
 
 .TP
 .I \-n, \-\-name LogicalVolumeName
@@ -161,7 +161,7 @@
 require 3 devices - two for the mirror devices and one for the disk
 log.
 
-"lvcreate -m1 --log core -L 500M vg00" tries to create a mirror logical volume
+"lvcreate -m1 --mirrorlog core -L 500M vg00" tries to create a mirror logical volume
 with 2 sides with a useable size of 500 MiB.  This operation would
 require 2 devices - the log is "in-memory".
 
--- LVM2/tools/lvconvert.c	2007/08/29 20:19:11	1.39
+++ LVM2/tools/lvconvert.c	2007/08/30 19:34:19	1.40
@@ -275,7 +275,8 @@
 	if (arg_count(cmd, corelog_ARG))
 		corelog = 1;
 
-	mirrorlog = arg_str_value(cmd, mirrorlog_ARG, DEFAULT_MIRRORLOG);
+	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
+				  corelog ? "core" : DEFAULT_MIRRORLOG);
 	if (!strcmp("disk", mirrorlog)) {
 		if (corelog) {
 			log_error("--mirrorlog disk and --corelog "
--- LVM2/tools/lvcreate.c	2007/08/22 14:38:18	1.143
+++ LVM2/tools/lvcreate.c	2007/08/30 19:34:19	1.144
@@ -288,7 +288,9 @@
 	if (arg_count(cmd, corelog_ARG))
 		lp->corelog = 1;
 
-	mirrorlog = arg_str_value(cmd, mirrorlog_ARG, DEFAULT_MIRRORLOG);
+	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
+				  lp->corelog ? "core" : DEFAULT_MIRRORLOG);
+
 	if (!strcmp("disk", mirrorlog)) {
 		if (lp->corelog) {
 			log_error("--mirrorlog disk and --corelog "


