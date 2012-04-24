From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Apr 2012 12:14:19 -0000
Subject: LVM2/man lvs.8.in
Message-ID: <20120424121419.28567.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-24 12:14:17

Modified files:
	man            : lvs.8.in 

Log message:
	Sort lvs options by alphabet

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/man/lvs.8.in	2012/04/24 12:13:31	1.22
+++ LVM2/man/lvs.8.in	2012/04/24 12:14:17	1.23
@@ -3,8 +3,8 @@
 lvs \- report information about logical volumes
 .SH SYNOPSIS
 .B lvs
-.RB [ \-a | \-\-all ]
 .RB [ \-\-aligned ]
+.RB [ \-a | \-\-all ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-? | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
@@ -17,9 +17,9 @@
 .RI [ + | \- ] Key1 [,[ + | \- ] Key2 [,...]]]
 .RB [ \-P | \-\-partial ]
 .RB [ \-\-rows ]
-.RB [ \-\-segments ]
 .RB [ \-\-separator
 .IR Separator ]
+.RB [ \-\-segments ]
 .RB [ \-\-unbuffered ]
 .RB [ \-\-units
 .IR hHbBsSkKmMgGtTpPeE ]
@@ -36,6 +36,9 @@
 .BR lvm (8)
 for common options.
 .TP
+.B \-\-aligned
+Use with \fB\-\-separator\fP to align the output columns.
+.TP
 .B \-\-all
 Include information in the output about internal Logical Volumes that
 are components of normally-accessible Logical Volumes, such as mirrors,
@@ -46,9 +49,6 @@
 , this option will reveal three internal Logical
 Volumes, with suffixes mimage_0, mimage_1, and mlog.
 .TP
-.B \-\-aligned
-Use with \fB\-\-separator\fP to align the output columns.
-.TP
 .B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
 with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
@@ -65,8 +65,8 @@
 (except h and H) if processing the output.
 .TP
 .BR \-o ", " \-\-options
-Comma-separated ordered list of columns.  Precede the list with '+' to append
-to the default selection of columns instead of replacing it.
+Comma-separated ordered list of columns.  Precede the list with '\fI+\fP'
+to append to the default selection of columns instead of replacing it.
 .IP
 Use \fB\-o lv_all\fP to select all logical volume columns,
 and \fB\-o seg_all\fP
@@ -134,7 +134,7 @@
 Permissions: (w)riteable, (r)ead-only, (R)ead-only activation of non-read-only
 volume
 .IP 3 3
-Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
+Allocation policy:  (a)nywhere, (c)ontiguous, (i)nherited, c(l)ing, (n)ormal
 This is capitalised if the volume is currently locked against allocation
 changes, for example during
 .BR pvmove (8).
@@ -158,9 +158,6 @@
 Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
 .RE
 .TP
-.B \-\-segments
-Use default columns that emphasize segment information.
-.TP
 .BR \-O ", " \-\-sort
 Comma-separated ordered list of columns to sort by.  Replaces the default
 selection. Precede any column with '\fI\-\fP' for a reverse sort on that column.
@@ -168,6 +165,9 @@
 .B \-\-rows
 Output columns as rows.
 .TP
+.B \-\-segments
+Use default columns that emphasize segment information.
+.TP
 .B \-\-separator \fISeparator
 String to use to separate each column.  Useful if grepping the output.
 .TP


