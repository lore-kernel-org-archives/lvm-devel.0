From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 21 Apr 2009 12:57:33 -0000
Subject: LVM2 ./WHATS_NEW lib/report/columns.h tools/to ...
Message-ID: <20090421125733.21379.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-21 12:57:32

Modified files:
	.              : WHATS_NEW 
	lib/report     : columns.h 
	tools          : toollib.c 

Log message:
	Fix pvs -a for segmented output
	
	# pvs -a -o devices
	Volume group name (null) has invalid characters
	Skipping volume group (null)
	
	...
	_pvsegs_sub_single creates fake vg, we need to check
	that pv is real here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1087&r2=1.1088
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149

--- LVM2/WHATS_NEW	2009/04/16 10:16:14	1.1087
+++ LVM2/WHATS_NEW	2009/04/21 12:57:31	1.1088
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix pvs -a output to not read volume groups from non-PV devices.
   Add MMC (mmcblk) device type to filters.
   Introduce memory pools per volume group (to reduce memory for large VGs).
   Add memory pool leaks detection.
--- LVM2/lib/report/columns.h	2009/02/25 23:31:06	1.31
+++ LVM2/lib/report/columns.h	2009/04/21 12:57:32	1.32
@@ -89,7 +89,7 @@
 FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, "seg_size", "Size of segment in current units.")
 FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, "seg_tags", "Tags, if any.")
 FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, "seg_pe_ranges", "Ranges of Physical Extents of underlying devices in command line format.")
-FIELD(SEGS, seg, STR, "Devices", list, 5, devices, "devices", "Underlying devices used with starting extent numbers.")
+FIELD(SEGS, seg, STR, "Devices", list, 7, devices, "devices", "Underlying devices used with starting extent numbers.")
 
 FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, "pvseg_start", "Physical Extent number of start of segment.")
 FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, "pvseg_size", "Number of extents in segment.")
--- LVM2/tools/toollib.c	2009/04/10 10:01:38	1.148
+++ LVM2/tools/toollib.c	2009/04/21 12:57:32	1.149
@@ -376,7 +376,7 @@
 	int ret;
 	struct volume_group *old_vg = vg;
 
-	if (!vg && !is_orphan(pv)) {
+	if (is_pv(pv) && !vg && !is_orphan(pv)) {
 		vg_name = pv_vg_name(pv);
 
 		if (!(vg = vg_lock_and_read(cmd, vg_name, NULL, LCK_VG_READ,


