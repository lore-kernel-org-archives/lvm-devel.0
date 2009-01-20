From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Jan 2009 17:39:08 -0000
Subject: LVM2 ./WHATS_NEW man/lvs.8.in man/pvs.8.in man ...
Message-ID: <20090120173908.26573.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-01-20 17:39:08

Modified files:
	.              : WHATS_NEW 
	man            : lvs.8.in pvs.8.in vgs.8.in 

Log message:
	Add --unquoted to pvs, vgs, lvs man pages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1022&r2=1.1023
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2009/01/20 17:10:44	1.1022
+++ LVM2/WHATS_NEW	2009/01/20 17:39:07	1.1023
@@ -1,6 +1,6 @@
 Version 2.02.44 - 
 ====================================
-  Add --nameprefixes and --rows to pvs, vgs, lvs man pages.
+  Add --nameprefixes, --unquoted, --rows to pvs, vgs, lvs man pages.
   Fix fsadm failure with block size != 1K.
   Fix pvs segfault when run with orphan PV and some VG fields.
   Display a 'dev_size' of zero for missing devices in reports.
--- LVM2/man/lvs.8.in	2009/01/20 17:10:44	1.5
+++ LVM2/man/lvs.8.in	2009/01/20 17:39:08	1.6
@@ -10,6 +10,7 @@
 [\-P|\-\-partial] [\-\-rows] [\-\-segments]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
+[\-\-unquoted]
 [\-v|\-\-verbose] 
 [\-\-version] [VolumeGroupName [VolumeGroupName...]]
 .SH DESCRIPTION
@@ -90,6 +91,9 @@
 (k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes.  Capitalise to use multiples
 of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
 \-\-units 3M
+.TP
+.I \-\-unquoted
+When used with --nameprefixes, output values in the field=value pairs are not quoted.
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvdisplay (8),
--- LVM2/man/pvs.8.in	2009/01/20 17:27:11	1.7
+++ LVM2/man/pvs.8.in	2009/01/20 17:39:08	1.8
@@ -10,6 +10,7 @@
 [\-\-rows] [\-\-segments]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
+[\-\-unquoted]
 [\-v|\-\-verbose] 
 [\-\-version] [PhysicalVolume [PhysicalVolume...]]
 .SH DESCRIPTION
@@ -67,6 +68,9 @@
 (k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes.  Capitalise to use multiples
 of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
 \-\-units 3M
+.TP
+.I \-\-unquoted
+When used with --nameprefixes, output values in the field=value pairs are not quoted.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvdisplay (8),
--- LVM2/man/vgs.8.in	2009/01/20 17:10:44	1.6
+++ LVM2/man/vgs.8.in	2009/01/20 17:39:08	1.7
@@ -10,6 +10,7 @@
 [\-P|\-\-partial] [\-\-rows]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
+[\-\-unquoted]
 [\-v|\-\-verbose] 
 [\-\-version] [VolumeGroupName [VolumeGroupName...]]
 .SH DESCRIPTION
@@ -78,6 +79,9 @@
 (k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes.  Capitalise to use multiples
 of 1000 (S.I.) instead of 1024.  Can also specify custom (u)nits e.g.
 \-\-units 3M
+.TP
+.I \-\-unquoted
+When used with --nameprefixes, output values in the field=value pairs are not quoted.
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgdisplay (8),


