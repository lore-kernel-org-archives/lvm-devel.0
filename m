From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2010 12:44:17 -0000
Subject: LVM2/lib/report columns.h report.c
Message-ID: <20100820124417.25964.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-08-20 12:44:17

Modified files:
	lib/report     : columns.h report.c 

Log message:
	Remove explicit double quotes from columns.h 'id' entries.
	
	The 'id' entries in columns.h are the report field names.  Since these are
	unique, we'd like to use them in generation of 'get' / 'set' functions.
	As a step towards using them for this purpose, remove the explicit double
	quotes and use the macro '#' character to add the double quotes back when
	placing them into the '_fields' array 'id' member.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/lib/report/columns.h	2010/08/20 12:44:03	1.43
+++ LVM2/lib/report/columns.h	2010/08/20 12:44:17	1.44
@@ -60,84 +60,84 @@
 #define FIELD_MODIFIABLE 0x00000001
 
 /* *INDENT-OFF* */
-FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, "lv_uuid", "Unique identifier.", 0)
-FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, "lv_name", "Name.  LVs created for internal use are enclosed in brackets.", 0)
-FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, "lv_path", "Full pathname for LV.", 0)
-FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, "lv_attr", "Various attributes - see man page.", 0)
-FIELD(LVS, lv, NUM, "Maj", major, 3, int32, "lv_major", "Persistent major number or -1 if not persistent.", 0)
-FIELD(LVS, lv, NUM, "Min", minor, 3, int32, "lv_minor", "Persistent minor number or -1 if not persistent.", 0)
-FIELD(LVS, lv, NUM, "Rahead", lvid, 6, lvreadahead, "lv_read_ahead", "Read ahead setting in current units.", 0)
-FIELD(LVS, lv, STR, "KMaj", lvid, 4, lvkmaj, "lv_kernel_major", "Currently assigned major number or -1 if LV is not active.", 0)
-FIELD(LVS, lv, STR, "KMin", lvid, 4, lvkmin, "lv_kernel_minor", "Currently assigned minor number or -1 if LV is not active.", 0)
-FIELD(LVS, lv, NUM, "KRahead", lvid, 7, lvkreadahead, "lv_kernel_read_ahead", "Currently-in-use read ahead setting in current units.", 0)
-FIELD(LVS, lv, NUM, "LSize", size, 5, size64, "lv_size", "Size of LV in current units.", 0)
-FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, "seg_count", "Number of segments in LV.", 0)
-FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, "origin", "For snapshots, the origin device of this LV.", 0)
-FIELD(LVS, lv, NUM, "OSize", lvid, 5, originsize, "origin_size", "For snapshots, the size of the origin device of this LV.", 0)
-FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, "snap_percent", "For snapshots, the percentage full if LV is active.", 0)
-FIELD(LVS, lv, NUM, "Copy%", lvid, 6, copypercent, "copy_percent", "For mirrors and pvmove, current percentage in-sync.", 0)
-FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, "move_pv", "For pvmove, Source PV of temporary LV created by pvmove.", 0)
-FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, "convert_lv", "For lvconvert, Name of temporary LV created by lvconvert.", 0)
-FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, "lv_tags", "Tags, if any.", 0)
-FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, "mirror_log", "For mirrors, the LV holding the synchronisation log.", 0)
-FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, "modules", "Kernel device-mapper modules required for this LV.", 0)
-
-FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, "pv_fmt", "Type of metadata.", 0)
-FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, "pv_uuid", "Unique identifier.", 0)
-FIELD(LABEL, pv, NUM, "DevSize", id, 7, devsize, "dev_size", "Size of underlying device in current units.", 0)
-FIELD(LABEL, pv, STR, "PV", dev, 10, dev_name, "pv_name", "Name.", 0)
-FIELD(LABEL, pv, NUM, "PMdaFree", id, 9, pvmdafree, "pv_mda_free", "Free metadata area space on this device in current units.", 0)
-FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, "pv_mda_size", "Size of smallest metadata area on this device in current units.", 0)
-
-FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, "pe_start", "Offset to the start of data on the underlying device.", 0)
-FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, "pv_size", "Size of PV in current units.", 0)
-FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, "pv_free", "Total amount of unallocated space in current units.", 0)
-FIELD(PVS, pv, NUM, "Used", id, 4, pvused, "pv_used", "Total amount of allocated space in current units.", 0)
-FIELD(PVS, pv, STR, "Attr", status, 4, pvstatus, "pv_attr", "Various attributes - see man page.", 0)
-FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, "pv_pe_count", "Total number of Physical Extents.", 0)
-FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, "pv_pe_alloc_count", "Total number of allocated Physical Extents.", 0)
-FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, "pv_tags", "Tags, if any.", 0)
-FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, "pv_mda_count", "Number of metadata areas on this device.", 0)
-FIELD(PVS, pv, NUM, "#PMdaUse", id, 8, pvmdasused, "pv_mda_used_count", "Number of metadata areas in use on this device.", 0)
-
-FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, "vg_fmt", "Type of metadata.", 0)
-FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, "vg_uuid", "Unique identifier.", 0)
-FIELD(VGS, vg, STR, "VG", name, 4, string, "vg_name", "Name.", 0)
-FIELD(VGS, vg, STR, "Attr", cmd, 5, vgstatus, "vg_attr", "Various attributes - see man page.", 0)
-FIELD(VGS, vg, NUM, "VSize", cmd, 5, vgsize, "vg_size", "Total size of VG in current units.", 0)
-FIELD(VGS, vg, NUM, "VFree", cmd, 5, vgfree, "vg_free", "Total amount of free space in current units.", 0)
-FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, "vg_sysid", "System ID indicating when and where it was created.", 0)
-FIELD(VGS, vg, NUM, "Ext", extent_size, 3, size32, "vg_extent_size", "Size of Physical Extents in current units.", 0)
-FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, "vg_extent_count", "Total number of Physical Extents.", 0)
-FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, "vg_free_count", "Total number of unallocated Physical Extents.", 0)
-FIELD(VGS, vg, NUM, "MaxLV", max_lv, 5, uint32, "max_lv", "Maximum number of LVs allowed in VG or 0 if unlimited.", 0)
-FIELD(VGS, vg, NUM, "MaxPV", max_pv, 5, uint32, "max_pv", "Maximum number of PVs allowed in VG or 0 if unlimited.", 0)
-FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, "pv_count", "Number of PVs.", 0)
-FIELD(VGS, vg, NUM, "#LV", cmd, 3, lvcount, "lv_count", "Number of LVs.", 0)
-FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, "snap_count", "Number of snapshots.", 0)
-FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, "vg_seqno", "Revision number of internal metadata.  Incremented whenever it changes.", 0)
-FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, "vg_tags", "Tags, if any.", 0)
-FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, "vg_mda_count", "Number of metadata areas on this VG.", 0)
-FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, "vg_mda_used_count", "Number of metadata areas in use on this VG.", 0)
-FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, "vg_mda_free", "Free metadata area space for this VG in current units.", 0)
-FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, "vg_mda_size", "Size of smallest metadata area for this VG in current units.", 0)
-FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, "vg_mda_copies", "Target number of in use metadata areas in the VG.", 0)
-
-FIELD(SEGS, seg, STR, "Type", list, 4, segtype, "segtype", "Type of LV segment.", 0)
-FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, "stripes", "Number of stripes or mirror legs.", 0)
-FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, "stripesize", "For stripes, amount of data placed on one device before switching to the next.", 0)
-FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, "stripe_size", "For stripes, amount of data placed on one device before switching to the next.", 0)
-FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, "regionsize", "For mirrors, the unit of data copied when synchronising devices.", 0)
-FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, "region_size", "For mirrors, the unit of data copied when synchronising devices.", 0)
-FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, "chunksize", "For snapshots, the unit of data used when tracking changes.", 0)
-FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, "chunk_size", "For snapshots, the unit of data used when tracking changes.", 0)
-FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, "seg_start", "Offset within the LV to the start of the segment in current units.", 0)
-FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, "seg_start_pe", "Offset within the LV to the start of the segment in physical extents.", 0)
-FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, "seg_size", "Size of segment in current units.", 0)
-FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, "seg_tags", "Tags, if any.", 0)
-FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, "seg_pe_ranges", "Ranges of Physical Extents of underlying devices in command line format.", 0)
-FIELD(SEGS, seg, STR, "Devices", list, 7, devices, "devices", "Underlying devices used with starting extent numbers.", 0)
+FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, lv_uuid, "Unique identifier.", 0)
+FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, lv_name, "Name.  LVs created for internal use are enclosed in brackets.", 0)
+FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV.", 0)
+FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
+FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
+FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
+FIELD(LVS, lv, NUM, "Rahead", lvid, 6, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
+FIELD(LVS, lv, STR, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
+FIELD(LVS, lv, STR, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
+FIELD(LVS, lv, NUM, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
+FIELD(LVS, lv, NUM, "LSize", size, 5, size64, lv_size, "Size of LV in current units.", 0)
+FIELD(LVS, lv, NUM, "#Seg", lvid, 4, lvsegcount, seg_count, "Number of segments in LV.", 0)
+FIELD(LVS, lv, STR, "Origin", lvid, 6, origin, origin, "For snapshots, the origin device of this LV.", 0)
+FIELD(LVS, lv, NUM, "OSize", lvid, 5, originsize, origin_size, "For snapshots, the size of the origin device of this LV.", 0)
+FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
+FIELD(LVS, lv, NUM, "Copy%", lvid, 6, copypercent, copy_percent, "For mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
+FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
+FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
+FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
+FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, modules, "Kernel device-mapper modules required for this LV.", 0)
+
+FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
+FIELD(LABEL, pv, STR, "PV UUID", id, 38, uuid, pv_uuid, "Unique identifier.", 0)
+FIELD(LABEL, pv, NUM, "DevSize", id, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
+FIELD(LABEL, pv, STR, "PV", dev, 10, dev_name, pv_name, "Name.", 0)
+FIELD(LABEL, pv, NUM, "PMdaFree", id, 9, pvmdafree, pv_mda_free, "Free metadata area space on this device in current units.", 0)
+FIELD(LABEL, pv, NUM, "PMdaSize", id, 9, pvmdasize, pv_mda_size, "Size of smallest metadata area on this device in current units.", 0)
+
+FIELD(PVS, pv, NUM, "1st PE", pe_start, 7, size64, pe_start, "Offset to the start of data on the underlying device.", 0)
+FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, pv_size, "Size of PV in current units.", 0)
+FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, pv_free, "Total amount of unallocated space in current units.", 0)
+FIELD(PVS, pv, NUM, "Used", id, 4, pvused, pv_used, "Total amount of allocated space in current units.", 0)
+FIELD(PVS, pv, STR, "Attr", status, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
+FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, pv_pe_count, "Total number of Physical Extents.", 0)
+FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Total number of allocated Physical Extents.", 0)
+FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
+FIELD(PVS, pv, NUM, "#PMda", id, 5, pvmdas, pv_mda_count, "Number of metadata areas on this device.", 0)
+FIELD(PVS, pv, NUM, "#PMdaUse", id, 8, pvmdasused, pv_mda_used_count, "Number of metadata areas in use on this device.", 0)
+
+FIELD(VGS, vg, STR, "Fmt", cmd, 3, vgfmt, vg_fmt, "Type of metadata.", 0)
+FIELD(VGS, vg, STR, "VG UUID", id, 38, uuid, vg_uuid, "Unique identifier.", 0)
+FIELD(VGS, vg, STR, "VG", name, 4, string, vg_name, "Name.", 0)
+FIELD(VGS, vg, STR, "Attr", cmd, 5, vgstatus, vg_attr, "Various attributes - see man page.", 0)
+FIELD(VGS, vg, NUM, "VSize", cmd, 5, vgsize, vg_size, "Total size of VG in current units.", 0)
+FIELD(VGS, vg, NUM, "VFree", cmd, 5, vgfree, vg_free, "Total amount of free space in current units.", 0)
+FIELD(VGS, vg, STR, "SYS ID", system_id, 6, string, vg_sysid, "System ID indicating when and where it was created.", 0)
+FIELD(VGS, vg, NUM, "Ext", extent_size, 3, size32, vg_extent_size, "Size of Physical Extents in current units.", 0)
+FIELD(VGS, vg, NUM, "#Ext", extent_count, 4, uint32, vg_extent_count, "Total number of Physical Extents.", 0)
+FIELD(VGS, vg, NUM, "Free", free_count, 4, uint32, vg_free_count, "Total number of unallocated Physical Extents.", 0)
+FIELD(VGS, vg, NUM, "MaxLV", max_lv, 5, uint32, max_lv, "Maximum number of LVs allowed in VG or 0 if unlimited.", 0)
+FIELD(VGS, vg, NUM, "MaxPV", max_pv, 5, uint32, max_pv, "Maximum number of PVs allowed in VG or 0 if unlimited.", 0)
+FIELD(VGS, vg, NUM, "#PV", pv_count, 3, uint32, pv_count, "Number of PVs.", 0)
+FIELD(VGS, vg, NUM, "#LV", cmd, 3, lvcount, lv_count, "Number of LVs.", 0)
+FIELD(VGS, vg, NUM, "#SN", cmd, 3, snapcount, snap_count, "Number of snapshots.", 0)
+FIELD(VGS, vg, NUM, "Seq", seqno, 3, uint32, vg_seqno, "Revision number of internal metadata.  Incremented whenever it changes.", 0)
+FIELD(VGS, vg, STR, "VG Tags", tags, 7, tags, vg_tags, "Tags, if any.", 0)
+FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, vg_mda_count, "Number of metadata areas on this VG.", 0)
+FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, vg_mda_used_count, "Number of metadata areas in use on this VG.", 0)
+FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, vg_mda_free, "Free metadata area space for this VG in current units.", 0)
+FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, vg_mda_size, "Size of smallest metadata area for this VG in current units.", 0)
+FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 0)
+
+FIELD(SEGS, seg, STR, "Type", list, 4, segtype, segtype, "Type of LV segment.", 0)
+FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, stripes, "Number of stripes or mirror legs.", 0)
+FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, stripesize, "For stripes, amount of data placed on one device before switching to the next.", 0)
+FIELD(SEGS, seg, NUM, "Stripe", stripe_size, 6, size32, stripe_size, "For stripes, amount of data placed on one device before switching to the next.", 0)
+FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, regionsize, "For mirrors, the unit of data copied when synchronising devices.", 0)
+FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, region_size, "For mirrors, the unit of data copied when synchronising devices.", 0)
+FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunksize, "For snapshots, the unit of data used when tracking changes.", 0)
+FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
+FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
+FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, seg_start_pe, "Offset within the LV to the start of the segment in physical extents.", 0)
+FIELD(SEGS, seg, NUM, "SSize", list, 5, segsize, seg_size, "Size of segment in current units.", 0)
+FIELD(SEGS, seg, STR, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
+FIELD(SEGS, seg, STR, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
+FIELD(SEGS, seg, STR, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)
 
-FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, "pvseg_start", "Physical Extent number of start of segment.", 0)
-FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, "pvseg_size", "Number of extents in segment.", 0)
+FIELD(PVSEGS, pvseg, NUM, "Start", pe, 5, uint32, pvseg_start, "Physical Extent number of start of segment.", 0)
+FIELD(PVSEGS, pvseg, NUM, "SSize", len, 5, uint32, pvseg_size, "Number of extents in segment.", 0)
 /* *INDENT-ON* */
--- LVM2/lib/report/report.c	2010/08/20 12:44:03	1.126
+++ LVM2/lib/report/report.c	2010/08/20 12:44:17	1.127
@@ -1197,7 +1197,7 @@
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
 #define FIELD(type, strct, sorttype, head, field, width, func, id, desc, writeable) \
 	{type, sorttype, offsetof(type_ ## strct, field), width, \
-	 id, head, &_ ## func ## _disp, desc},
+	 #id, head, &_ ## func ## _disp, desc},
 
 typedef struct physical_volume type_pv;
 typedef struct logical_volume type_lv;


