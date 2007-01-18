From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Jan 2007 22:33:25 -0000
Subject: LVM2 ./WHATS_NEW man/lvs.8 man/pvs.8 man/vgs.8
Message-ID: <20070118223325.11011.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-18 22:33:24

Modified files:
	.              : WHATS_NEW 
	man            : lvs.8 pvs.8 vgs.8 

Log message:
	Update reporting man pages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.547&r2=1.548
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2007/01/18 17:48:29	1.547
+++ LVM2/WHATS_NEW	2007/01/18 22:33:24	1.548
@@ -1,5 +1,6 @@
 Version 2.02.20 -
 ===================================
+  Update reporting man pages.
   No longer necessary to specify alignment for report fields.
 
 Version 2.02.19 - 17th January 2007
--- LVM2/man/lvs.8	2006/05/11 20:17:17	1.4
+++ LVM2/man/lvs.8	2007/01/18 22:33:24	1.5
@@ -35,11 +35,13 @@
 lv_size, seg_count, origin, snap_percent,
 copy_percent, move_pv, lv_tags,
 segtype, stripes,
-stripesize, chunksize, seg_start, seg_size, seg_tags, devices.
+stripesize, chunksize, seg_start, seg_size, seg_tags, devices,
+regionsize, mirror_log, modules.
 .IP
 With \-\-segments, any "seg_" prefixes are optional; otherwise any "lv_"
 prefixes are optional.  Columns mentioned in \fBvgs (8)\fP 
 can also be chosen.
+Use \fb-o help\fP to view the full list of fields available.
 .IP
 The lv_attr bits are: 
 .RS
--- LVM2/man/pvs.8	2004/11/12 15:59:08	1.2
+++ LVM2/man/pvs.8	2007/01/18 22:33:24	1.3
@@ -31,9 +31,16 @@
 Comma-separated ordered list of columns.  Precede the list with '+' to append
 to the default selection of columns.  Column names are: pv_fmt, pv_uuid,
 pv_size, dev_size, pv_free, pv_used, pv_name, pv_attr, pv_pe_count, 
-pv_pe_alloc_count, pv_tags.
-The "pv_" prefix is optional.  Columns mentioned in \fBvgs (8)\fP can also
+pv_pe_alloc_count, pv_tags, pvseg_start, pvseg_size, pe_start.
+With --segments, any "pvseg_" prefixes are optional; otherwise any
+"pv_" prefixes are optional.  Columns mentioned in \fBvgs (8)\fP can also
 be chosen. The pv_attr bits are: (a)llocatable and e(x)ported.
+Use \fb-o help\fP to view the full list of fields available.
+.TP
+.I \-\-segments
+Produces one line of output for each contiguous allocation of space on each
+Physical Volume, showing the start (pvseg_start) and length (pvseg_size) in
+units of physical extents.
 .TP
 .I \-O, \-\-sort
 Comma-separated ordered list of columns to sort by.  Replaces the default
--- LVM2/man/vgs.8	2005/08/15 23:34:11	1.3
+++ LVM2/man/vgs.8	2007/01/18 22:33:24	1.4
@@ -38,6 +38,7 @@
 or \fBlvs (8)\fP can also be chosen, but columns cannot be taken from both
 at the same time.  The vg_attr bits are: (w)riteable, (r)eadonly, 
 resi(z)eable, e(x)ported, (p)artial and (c)lustered.
+Use \fb-o help\fP to view the full list of fields available.
 .TP
 .I \-O, \-\-sort
 Comma-separated ordered list of columns to sort by.  Replaces the default


