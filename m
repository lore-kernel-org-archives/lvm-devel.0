From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 11:32:43 -0000
Subject: LVM2 ./WHATS_NEW lib/config/defaults.h
Message-ID: <20120125113243.26975.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 11:32:42

Modified files:
	.              : WHATS_NEW 
	lib/config     : defaults.h 

Log message:
	Update verbose lvs  to print metadata_percent info
	
	Update lvs  -o fields in WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2238&r2=1.2239
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/WHATS_NEW	2012/01/25 09:00:57	1.2238
+++ LVM2/WHATS_NEW	2012/01/25 11:32:41	1.2239
@@ -1,5 +1,10 @@
 Version 2.02.89 - 
 ==================================
+  Thin pools have segment fields thin_count, zero, transaction_id.
+  Each new created LV volume has creation lv_time and lv_host.
+  Print data_percent and metadata_percent for verbose lvs.
+  Thin pool support lvs data_percent, metadata_percent, data/metadata_lv.
+  Thin volumes support lvs options data_percent, pool_lv.
   Update lv_info to use -real layer for origin_only LVs.
   Add lv_thin_pool_transaction_id to read the transaction_id value.
   Use suspend|resume_origin_only when up-converting RAID, as mirrors do.
--- LVM2/lib/config/defaults.h	2012/01/20 16:59:59	1.94
+++ LVM2/lib/config/defaults.h	2012/01/25 11:32:41	1.95
@@ -155,7 +155,7 @@
 #define DEFAULT_SEGS_COLS "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
 #define DEFAULT_PVSEGS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
 
-#define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid"
+#define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid"
 #define DEFAULT_VGS_COLS_VERB "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid"
 #define DEFAULT_PVS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
 #define DEFAULT_SEGS_COLS_VERB "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"


