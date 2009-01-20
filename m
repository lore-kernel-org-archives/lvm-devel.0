From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Jan 2009 16:55:25 -0000
Subject: LVM2/man lvs.8.in pvs.8.in vgs.8.in
Message-ID: <20090120165525.22297.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-01-20 16:55:25

Modified files:
	man            : lvs.8.in pvs.8.in vgs.8.in 

Log message:
	Add --rows option to pvs, vgs, lvs man pages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/man/lvs.8.in	2008/11/12 15:16:58	1.3
+++ LVM2/man/lvs.8.in	2009/01/20 16:55:24	1.4
@@ -7,7 +7,7 @@
 [\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-P|\-\-partial] [\-\-segments]
+[\-P|\-\-partial] [\-\-rows] [\-\-segments]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
 [\-v|\-\-verbose] 
@@ -71,6 +71,9 @@
 Comma-separated ordered list of columns to sort by.  Replaces the default
 selection. Precede any column with - for a reverse sort on that column.
 .TP
+.I \-\-rows
+Output columns as rows.
+.TP
 .I \-\-separator Separator
 String to use to separate each column.  Useful if grepping the output.
 .TP
--- LVM2/man/pvs.8.in	2009/01/09 22:44:34	1.4
+++ LVM2/man/pvs.8.in	2009/01/20 16:55:24	1.5
@@ -7,6 +7,7 @@
 [\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
+[\-\-rows]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
 [\-v|\-\-verbose] 
@@ -47,6 +48,9 @@
 Comma-separated ordered list of columns to sort by.  Replaces the default
 selection. Precede any column with - for a reverse sort on that column.
 .TP
+.I \-\-rows
+Output columns as rows.
+.TP
 .I \-\-separator Separator
 String to use to separate each column.  Useful if grepping the output.
 .TP
--- LVM2/man/vgs.8.in	2009/01/09 22:44:34	1.4
+++ LVM2/man/vgs.8.in	2009/01/20 16:55:24	1.5
@@ -7,7 +7,7 @@
 [\-\-ignorelockingfailure] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-P|\-\-partial]
+[\-P|\-\-partial] [\-\-rows]
 [\-\-separator Separator] [\-\-unbuffered]
 [\-\-units hsbkmgtHKMGT]
 [\-v|\-\-verbose] 
@@ -59,6 +59,9 @@
 Comma-separated ordered list of columns to sort by.  Replaces the default
 selection. Precede any column with - for a reverse sort on that column.
 .TP
+.I \-\-rows
+Output columns as rows.
+.TP
 .I \-\-separator Separator
 String to use to separate each column.  Useful if grepping the output.
 .TP


