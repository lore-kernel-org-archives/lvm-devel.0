From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:08:58 -0000
Subject: LVM2/lib/report properties.c
Message-ID: <20100930140858.18001.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:08:58

Modified files:
	lib/report     : properties.c 

Log message:
	Add 'get' functions for vg fields.
	
	Add 'get' functions based on generic macros for VG, PV, and LV.
	Add 'get' functions for vg string fields, vg_name, vg_fmt, vg_sysid,
	vg_uuid, vg_attr, and vg_tags, and all numeric fields.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/report/properties.c	2010/09/30 14:08:46	1.5
+++ LVM2/lib/report/properties.c	2010/09/30 14:08:58	1.6
@@ -135,19 +135,19 @@
 #define _modules_set _not_implemented
 
 /* VG */
-#define _vg_fmt_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_fmt, vg_fmt_dup(vg))
 #define _vg_fmt_set _not_implemented
-#define _vg_uuid_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_uuid, vg_uuid_dup(vg))
 #define _vg_uuid_set _not_implemented
-#define _vg_name_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_name, vg_name_dup(vg))
 #define _vg_name_set _not_implemented
-#define _vg_attr_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_attr, vg_attr_dup(vg->vgmem, vg))
 #define _vg_attr_set _not_implemented
 GET_VG_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
 #define _vg_size_set _not_implemented
 GET_VG_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
 #define _vg_free_set _not_implemented
-#define _vg_sysid_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_sysid, vg_system_id_dup(vg))
 #define _vg_sysid_set _not_implemented
 GET_VG_NUM_PROPERTY_FN(vg_extent_size, vg->extent_size)
 #define _vg_extent_size_set _not_implemented
@@ -167,7 +167,7 @@
 #define _snap_count_set _not_implemented
 GET_VG_NUM_PROPERTY_FN(vg_seqno, vg->seqno)
 #define _vg_seqno_set _not_implemented
-#define _vg_tags_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_tags, vg_tags_dup(vg))
 #define _vg_tags_set _not_implemented
 GET_VG_NUM_PROPERTY_FN(vg_mda_count, (vg_mda_count(vg)))
 #define _vg_mda_count_set _not_implemented


