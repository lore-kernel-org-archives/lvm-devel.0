From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Jan 2009 17:10:45 -0000
Subject: LVM2 ./WHATS_NEW man/lvs.8.in man/pvs.8.in man ...
Message-ID: <20090120171045.376.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-01-20 17:10:44

Modified files:
	.              : WHATS_NEW 
	man            : lvs.8.in pvs.8.in vgs.8.in 

Log message:
	Add --nameprefixes to pvs, vgs, lvs man pages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1021&r2=1.1022
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/WHATS_NEW	2009/01/15 14:44:48	1.1021
+++ LVM2/WHATS_NEW	2009/01/20 17:10:44	1.1022
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Add --nameprefixes and --rows to pvs, vgs, lvs man pages.
   Fix fsadm failure with block size != 1K.
   Fix pvs segfault when run with orphan PV and some VG fields.
   Display a 'dev_size' of zero for missing devices in reports.
--- LVM2/man/lvs.8.in	2009/01/20 16:55:24	1.4
+++ LVM2/man/lvs.8.in	2009/01/20 17:10:44	1.5
@@ -4,7 +4,7 @@
 .SH SYNOPSIS
 .B lvs
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
+[\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-P|\-\-partial] [\-\-rows] [\-\-segments]
@@ -20,6 +20,11 @@
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
+.I \-\-nameprefixes
+Add an "LVM2_" prefix plus the field name to the output.  Useful
+with --noheadings to produce a list of field=value pairs that can
+be used to set environment variables (for example, in \fBudev (7)\fP rules).
+.TP
 .I \-\-noheadings
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
--- LVM2/man/pvs.8.in	2009/01/20 16:55:24	1.5
+++ LVM2/man/pvs.8.in	2009/01/20 17:10:44	1.6
@@ -4,7 +4,7 @@
 .SH SYNOPSIS
 .B pvs
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
+[\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-\-rows]
@@ -20,6 +20,11 @@
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
+.I \-\-nameprefixes
+Add an "LVM2_" prefix plus the field name to the output.  Useful
+with --noheadings to produce a list of field=value pairs that can
+be used to set environment variables (for example, in \fBudev (7)\fP rules).
+.TP
 .I \-\-noheadings
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
--- LVM2/man/vgs.8.in	2009/01/20 16:55:24	1.5
+++ LVM2/man/vgs.8.in	2009/01/20 17:10:44	1.6
@@ -4,7 +4,7 @@
 .SH SYNOPSIS
 .B vgs
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
+[\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-P|\-\-partial] [\-\-rows]
@@ -20,6 +20,11 @@
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
+.I \-\-nameprefixes
+Add an "LVM2_" prefix plus the field name to the output.  Useful
+with --noheadings to produce a list of field=value pairs that can
+be used to set environment variables (for example, in \fBudev (7)\fP rules).
+.TP
 .I \-\-noheadings
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.


