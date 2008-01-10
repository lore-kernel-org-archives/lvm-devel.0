From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jan 2008 19:25:08 -0000
Subject: LVM2 ./WHATS_NEW lib/config/defaults.h
Message-ID: <20080110192508.1366.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-10 19:25:07

Modified files:
	.              : WHATS_NEW 
	lib/config     : defaults.h 

Log message:
	Add lv_convert field to default lvs output.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.755&r2=1.756
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2008/01/09 15:55:44	1.755
+++ LVM2/WHATS_NEW	2008/01/10 19:25:07	1.756
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Add new lv_convert field to lvs output.
   Print warning when lvm tools are running as non-root.
   Add snapshot dmeventd library (enables dmeventd snapshot monitoring).
   Prevent pvcreate from overwriting MDA-less PVs belonging to active VGs.
--- LVM2/lib/config/defaults.h	2007/12/14 21:53:01	1.35
+++ LVM2/lib/config/defaults.h	2008/01/10 19:25:07	1.36
@@ -103,13 +103,13 @@
 #define DEFAULT_REP_HEADINGS 1
 #define DEFAULT_REP_SEPARATOR " "
 
-#define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,origin,snap_percent,move_pv,mirror_log,copy_percent"
+#define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,origin,snap_percent,move_pv,mirror_log,copy_percent,lv_convert"
 #define DEFAULT_VGS_COLS "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
 #define DEFAULT_PVS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
 #define DEFAULT_SEGS_COLS "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
 #define DEFAULT_PVSEGS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
 
-#define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,origin,snap_percent,move_pv,copy_percent,mirror_log,lv_uuid"
+#define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,origin,snap_percent,move_pv,copy_percent,mirror_log,lv_convert,lv_uuid"
 #define DEFAULT_VGS_COLS_VERB "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid"
 #define DEFAULT_PVS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
 #define DEFAULT_SEGS_COLS_VERB "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"


