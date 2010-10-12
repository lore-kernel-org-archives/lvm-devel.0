From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2010 16:11:21 -0000
Subject: LVM2/lib/report properties.c
Message-ID: <20101012161121.23199.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-12 16:11:20

Modified files:
	lib/report     : properties.c 

Log message:
	Add some lv 'get' functions that require no refactoring.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Reviewed-By: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/lib/report/properties.c	2010/09/30 14:09:45	1.8
+++ LVM2/lib/report/properties.c	2010/10/12 16:11:20	1.9
@@ -97,17 +97,17 @@
 #define _pv_mda_used_count_set _not_implemented_set
 
 /* LV */
-#define _lv_uuid_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
 #define _lv_uuid_set _not_implemented_set
 #define _lv_name_get _not_implemented_get
 #define _lv_name_set _not_implemented_set
 #define _lv_path_get _not_implemented_get
 #define _lv_path_set _not_implemented_set
-#define _lv_attr_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(lv_attr, lv_attr_dup(lv->vg->vgmem, lv))
 #define _lv_attr_set _not_implemented_set
-#define _lv_major_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_major, lv->major)
 #define _lv_major_set _not_implemented_set
-#define _lv_minor_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_minor, lv->minor)
 #define _lv_minor_set _not_implemented_set
 #define _lv_read_ahead_get _not_implemented_get
 #define _lv_read_ahead_set _not_implemented_set
@@ -117,9 +117,9 @@
 #define _lv_kernel_minor_set _not_implemented_set
 #define _lv_kernel_read_ahead_get _not_implemented_get
 #define _lv_kernel_read_ahead_set _not_implemented_set
-#define _lv_size_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_size, lv->size * SECTOR_SIZE)
 #define _lv_size_set _not_implemented_set
-#define _seg_count_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(seg_count, dm_list_size(&lv->segments))
 #define _seg_count_set _not_implemented_set
 #define _origin_get _not_implemented_get
 #define _origin_set _not_implemented_set
@@ -133,7 +133,7 @@
 #define _move_pv_set _not_implemented_set
 #define _convert_lv_get _not_implemented_get
 #define _convert_lv_set _not_implemented_set
-#define _lv_tags_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
 #define _lv_tags_set _not_implemented_set
 #define _mirror_log_get _not_implemented_get
 #define _mirror_log_set _not_implemented_set


