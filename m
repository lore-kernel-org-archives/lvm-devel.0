From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jun 2009 17:09:35 -0000
Subject: LVM2/man lvs.8.in pvs.8.in vgs.8.in
Message-ID: <20090615170935.19787.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-06-15 17:09:34

Modified files:
	man            : lvs.8.in pvs.8.in vgs.8.in 

Log message:
	Cleanup pvs, vgs, and lvs "-o" section in man pages (rhbz 500861).
	
	http://bugzilla.redhat.com/show_bug.cgi?id=500861
	- Update list of fields/columns for each command (a few missing).
	- Update list order to match "-o help" output (easier to verify field list)
	- Add "{pv|vg|lv}_all" description.
	- Move "-o help" sentence above column/field list.
	
	New sample man page for lvs (pvs and vgs are similar):
	-o, --options
	Comma-separated ordered list of columns.  Precede the list  with  ???+???  to  append  to  the
	default selection of columns instead of replacing it.
	
	Use  -o  lv_all to select all logical volume columns, and -o seg_all to select all logical
	segment columns.
	
	Use -o help to view the full list of columns available.
	
	Column names  include:  lv_uuid,  lv_name,  lv_attr,  lv_major,  lv_minor,  lv_read_ahead,
	lv_kernel_major,  lv_kernel_minor,  lv_kernel_read_ahead, lv_size, seg_count, origin, ori-
	gin_size, snap_percent, copy_percent, move_pv, convert_lv, lv_tags,  mirror_log,  modules,
	segtype,  stripes,  stripesize,  regionsize, chunksize, seg_start, seg_start_pe, seg_size,
	seg_tags, seg_pe_ranges, devices.
	
	With --segments, any "seg_" prefixes  are  optional;  otherwise  any  "lv_"  prefixes  are
	optional.  Columns mentioned in vgs (8) can also be chosen.
	
	The lv_attr bits are:

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/man/lvs.8.in	2009/04/25 01:18:00	1.7
+++ LVM2/man/lvs.8.in	2009/06/15 17:09:32	1.8
@@ -36,18 +36,22 @@
 .TP
 .I \-o, \-\-options
 Comma-separated ordered list of columns.  Precede the list with '+' to append
-to the default selection of columns instead of replacing it.  Column names are: 
-lv_uuid, lv_name, lv_attr, lv_major, lv_minor, lv_kernel_major, lv_kernel_minor,
-lv_size, seg_count, origin, snap_percent,
-copy_percent, move_pv, lv_tags, origin_size,
-segtype, stripes,
-stripesize, chunksize, seg_start, seg_size, seg_tags, devices,
-regionsize, mirror_log, modules.
+to the default selection of columns instead of replacing it.
+.IP
+Use \fb-o lv_all\fP to select all logical volume columns, and \fb-o seg_all\fP to select all
+logical segment columns.
+.IP
+Use \fb-o help\fP to view the full list of columns available.
+.IP
+Column names include:
+lv_uuid, lv_name, lv_attr, lv_major, lv_minor, lv_read_ahead, lv_kernel_major, lv_kernel_minor,
+lv_kernel_read_ahead, lv_size, seg_count, origin, origin_size, snap_percent, copy_percent, move_pv,
+convert_lv, lv_tags, mirror_log, modules, segtype, stripes, stripesize, regionsize, chunksize, seg_start,
+seg_start_pe, seg_size, seg_tags, seg_pe_ranges, devices.
 .IP
 With \-\-segments, any "seg_" prefixes are optional; otherwise any "lv_"
 prefixes are optional.  Columns mentioned in \fBvgs (8)\fP 
 can also be chosen.
-Use \fb-o help\fP to view the full list of fields available.
 .IP
 The lv_attr bits are: 
 .RS
--- LVM2/man/pvs.8.in	2009/01/20 17:39:08	1.8
+++ LVM2/man/pvs.8.in	2009/06/15 17:09:32	1.9
@@ -36,14 +36,20 @@
 .TP
 .I \-o, \-\-options
 Comma-separated ordered list of columns.  Precede the list with '+' to append
-to the default selection of columns.  Column names are: pv_fmt, pv_uuid,
-pv_size, dev_size, pv_free, pv_used, pv_name, pv_attr, pv_pe_count, 
-pv_pe_alloc_count, pv_tags, pvseg_start, pvseg_size, pe_start,
-pv_mda_count, pv_mda_free, and pv_mda_size.
+to the default selection of columns.
+.IP
+Use \fb-o pv_all\fP to select all physical volume columns, and \fb-o pvseg_all\fP
+to select all physical segment columns.
+.IP
+Use \fb-o help\fP to view the full list of columns available.
+.IP
+Column names include: pv_fmt, pv_uuid, dev_size, pv_name, pv_mda_free,
+pv_mda_size, pe_start, pv_size, pv_free, pv_used, pv_attr, pv_pe_count,
+pv_pe_alloc_count, pv_tags, pv_mda_count, pvseg_start, and pvseg_size.
+.IP
 With --segments, any "pvseg_" prefixes are optional; otherwise any
 "pv_" prefixes are optional.  Columns mentioned in \fBvgs (8)\fP can also
 be chosen. The pv_attr bits are: (a)llocatable and e(x)ported.
-Use \fb-o help\fP to view the full list of fields available.
 .TP
 .I \-\-segments
 Produces one line of output for each contiguous allocation of space on each
--- LVM2/man/vgs.8.in	2009/01/20 17:39:08	1.7
+++ LVM2/man/vgs.8.in	2009/06/15 17:09:32	1.8
@@ -36,14 +36,20 @@
 .TP
 .I \-o, \-\-options
 Comma-separated ordered list of columns.  Precede the list with '+' to append
-to the default selection of columns.  Column names are: vg_fmt, vg_uuid,
-vg_name, vg_attr, vg_size, vg_free, vg_sysid, vg_extent_size, vg_extent_count,
-vg_free_count, max_lv, max_pv, pv_count, lv_count, snap_count, vg_seqno,
-vg_tags, vg_mda_count, vg_mda_free, and vg_mda_size.
+to the default selection of columns.
+.IP
+Use \fb-o vg_all\fP to select all volume group columns.
+.IP
+Use \fb-o help\fP to view the full list of columns available.
+.IP
+Column names include: vg_fmt, vg_uuid, vg_name, vg_attr, vg_size, vg_free,
+vg_sysid, vg_extent_size, vg_extent_count, vg_free_count, max_lv, max_pv,
+pv_count, lv_count, snap_count, vg_seqno, vg_tags, vg_mda_count, vg_mda_free,
+and vg_mda_size.
+.IP
 Any "vg_" prefixes are optional.  Columns mentioned in either \fBpvs (8)\fP 
 or \fBlvs (8)\fP can also be chosen, but columns cannot be taken from both
 at the same time.  
-Use \fb-o help\fP to view the full list of fields available.
 .IP
 The vg_attr bits are:
 .RS


