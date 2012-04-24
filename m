From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Apr 2012 12:13:34 -0000
Subject: LVM2 ./WHATS_NEW man/lvs.8.in
Message-ID: <20120424121334.27518.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-24 12:13:32

Modified files:
	.              : WHATS_NEW 
	man            : lvs.8.in 

Log message:
	Update some lvs column names
	
	Fix thin_pool -> pool_lv
	Add more fields supported by thin provisioning.
	Keep fields alphabetically sorted for easier lookup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2387&r2=1.2388
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/WHATS_NEW	2012/04/24 00:51:26	1.2387
+++ LVM2/WHATS_NEW	2012/04/24 12:13:29	1.2388
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Update and correct lvs man page with supported column names.
   Handle replacement of an active device that goes missing with an error device.
   Change change raid1 segtype always to request a flush when suspending.
   Add udev info and context to lvmdump.
--- LVM2/man/lvs.8.in	2012/04/11 12:42:10	1.21
+++ LVM2/man/lvs.8.in	2012/04/24 12:13:31	1.22
@@ -75,11 +75,46 @@
 Use \fB\-o help\fP to view the full list of columns available.
 .IP
 Column names include:
-lv_uuid, lv_name, lv_path, lv_attr, lv_major, lv_minor, lv_read_ahead, lv_kernel_major,
-lv_kernel_minor, lv_kernel_read_ahead, lv_size, seg_count, origin, origin_size,
-snap_percent, copy_percent, move_pv, convert_lv, lv_tags, mirror_log, thin_pool, modules,
-segtype, stripes, stripesize, regionsize, chunksize, seg_start, seg_start_pe,
-seg_size, seg_tags, seg_pe_ranges, devices.
+chunk_size,
+convert_lv,
+copy_percent,
+data_lv,
+devices,
+lv_attr,
+lv_host,
+lv_kernel_major,
+lv_kernel_minor,
+lv_kernel_read_ahead,
+lv_major,
+lv_minor,
+lv_name,
+lv_path,
+lv_read_ahead,
+lv_size,
+lv_tags,
+lv_time,
+lv_uuid,
+metadata_lv,
+mirror_log,
+modules,
+move_pv,
+origin,
+origin_size,
+pool_lv,
+region_size,
+segtype,
+seg_count,
+seg_pe_ranges,
+seg_size,
+seg_start,
+seg_start_pe,
+seg_tags,
+snap_percent,
+stripes,
+stripe_size,
+thin_count,
+transaction_id,
+zero.
 .IP
 With \fB\-\-segments\fP, any "seg_" prefixes are optional;
 otherwise any "lv_" prefixes are optional. Columns mentioned in


