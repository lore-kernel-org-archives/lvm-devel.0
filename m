From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Nov 2011 12:16:54 -0000
Subject: LVM2 ./WHATS_NEW man/lvs.8.in
Message-ID: <20111108121654.22364.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-08 12:16:53

Modified files:
	.              : WHATS_NEW 
	man            : lvs.8.in 

Log message:
	Update  lvs man page style.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2179&r2=1.2180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2011/11/07 11:01:53	1.2179
+++ LVM2/WHATS_NEW	2011/11/08 12:16:53	1.2180
@@ -15,7 +15,7 @@
   Make move_lv_segment non-static function and use dm_list function.
   Pass exclusive LV locks to all nodes in the cluster.
   Improve lvcreate man documentation of the chunksize option.
-  Improve man page style for lvcreate.
+  Improve man page style for lvcreate, lvs.
   Avoid recursive calls to dmeventd in its LVM plugins.
   Log dev name now returned to kernel for registering during cmirror CTR.
   Fix lv_info open_count test for disabled verify_udev_operations (2.02.86).
--- LVM2/man/lvs.8.in	2011/09/23 19:21:53	1.17
+++ LVM2/man/lvs.8.in	2011/11/08 12:16:53	1.18
@@ -3,24 +3,40 @@
 lvs \- report information about logical volumes
 .SH SYNOPSIS
 .B lvs
-[\-a|\-\-all]
-[\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
-[\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
-[\-o|\-\-options [+]Field[,Field]]
-[\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-P|\-\-partial] [\-\-rows] [\-\-segments]
-[\-\-separator Separator]
-[\-\-unbuffered]
-[\-\-units hHbBsSkKmMgGtTpPeE]
-[\-\-unquoted]
-[\-v|\-\-verbose] 
-[\-\-version] [VolumeGroupName [VolumeGroupName...]]
+.RB [ \-a | \-\-all ]
+.RB [ \-\-aligned ]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-? | \-\-help ]
+.RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-nameprefixes ]
+.RB [ \-\-noheadings ]
+.RB [ \-\-nosuffix ]
+.RB [ \-o | \-\-options
+.RI [ + ] Field [, Field ]]
+.RB [ \-O | \-\-sort
+.RI [ + | - ] Key1 [,[ + | - ] Key2 [,...]]]
+.RB [ \-P | \-\-partial ]
+.RB [ \-\-rows ]
+.RB [ \-\-segments ]
+.RB [ \-\-separator
+.IR Separator ]
+.RB [ \-\-unbuffered ]
+.RB [ \-\-units
+.IR hHbBsSkKmMgGtTpPeE ]
+.RB [ \-\-unquoted ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-version ]
+.RI [ VolumeGroupName
+.RI [ VolumeGroupName ...]]
+
 .SH DESCRIPTION
 lvs produces formatted output about logical volumes.
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See
+.BR lvm (8)
+for common options.
 .TP
-.I \-\-all
+.B \-\-all
 Include information in the output about internal Logical Volumes that
 are components of normally-accessible Logical Volumes, such as mirrors,
 but which are not independently accessible (e.g. not mountable).
@@ -29,23 +45,25 @@
 --mirrorlog disk', this option will reveal three internal Logical
 Volumes, with suffixes mimage_0, mimage_1, and mlog.
 .TP
-.I \-\-aligned
+.B \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
-.I \-\-nameprefixes
+.B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
 with --noheadings to produce a list of field=value pairs that can
-be used to set environment variables (for example, in \fBudev (7)\fP rules).
+be used to set environment variables (for example, in 
+.BR udev (7)
+rules).
 .TP
-.I \-\-noheadings
+.B \-\-noheadings
 Suppress the headings line that is normally the first line of output.
 Useful if grepping the output.
 .TP
-.I \-\-nosuffix
+.B \-\-nosuffix
 Suppress the suffix on output sizes.  Use with \-\-units (except h and H)
 if processing the output.
 .TP
-.I \-o, \-\-options
+.BR \-o ", " \-\-options
 Comma-separated ordered list of columns.  Precede the list with '+' to append
 to the default selection of columns instead of replacing it.
 .IP
@@ -62,7 +80,8 @@
 seg_size, seg_tags, seg_pe_ranges, devices.
 .IP
 With \-\-segments, any "seg_" prefixes are optional; otherwise any "lv_"
-prefixes are optional.  Columns mentioned in \fBvgs (8)\fP 
+prefixes are optional.  Columns mentioned in
+.BR vgs (8)
 can also be chosen.
 .IP
 The lv_attr bits are: 
@@ -79,7 +98,8 @@
 .IP 3 3
 Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
 This is capitalised if the volume is currently locked against allocation
-changes, for example during \fBpvmove\fP (8).
+changes, for example during
+.BR pvmove (8).
 .IP 4 3
 fixed (m)inor
 .IP 5 3
@@ -99,29 +119,29 @@
 Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
 .RE
 .TP
-.I \-\-segments
+.B \-\-segments
 Use default columns that emphasize segment information.
 .TP
-.I \-O, \-\-sort
+.BR \-O ", " \-\-sort
 Comma-separated ordered list of columns to sort by.  Replaces the default
 selection. Precede any column with - for a reverse sort on that column.
 .TP
-.I \-\-rows
+.B \-\-rows
 Output columns as rows.
 .TP
-.I \-\-separator Separator
+.B \-\-separator \fISeparator
 String to use to separate each column.  Useful if grepping the output.
 .TP
-.I \-\-unbuffered
+.B \-\-unbuffered
 Produce output immediately without sorting or aligning the columns properly.
 .TP
-.I \-\-units hHbBsSkKmMgGtTpPeE
+.B \-\-units \fIhHbBsSkKmMgGtTpPeE
 All sizes are output in these units: (h)uman-readable, (b)ytes, (s)ectors,
 (k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  
 Capitalise to use multiples of 1000 (S.I.) instead of 1024.  Can also specify 
 custom units e.g. \-\-units 3M
 .TP
-.I \-\-unquoted
+.B \-\-unquoted
 When used with --nameprefixes, output values in the field=value pairs are not quoted.
 .SH SEE ALSO
 .BR lvm (8),


