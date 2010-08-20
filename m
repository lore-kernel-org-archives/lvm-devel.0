From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2010 12:45:09 -0000
Subject: LVM2/lib/report properties.c
Message-ID: <20100820124509.26938.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-08-20 12:45:09

Modified files:
	lib/report     : properties.c 

Log message:
	Add implmentation for simple numeric 'get' property functions.
	
	Add 'get' functions based on the simple macro function definition for a
	numeric property.
	
	Add 'get' functions for the following: _vg_extent_count_get,
	_vg_free_count_get, _max_lv_get, _max_pv_get, _pv_count_get,
	_lv_count_get, _snap_count_get, _vg_seqno_get, _vg_size_get,
	_vg_free_get, vg_mda_*.
	
	For size functions, multiply by SECTOR_SIZE to return the value in bytes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/lib/report/properties.c	2010/08/20 12:44:58	1.1
+++ LVM2/lib/report/properties.c	2010/08/20 12:45:09	1.2
@@ -113,41 +113,41 @@
 #define _vg_name_set _not_implemented
 #define _vg_attr_get _not_implemented
 #define _vg_attr_set _not_implemented
-#define _vg_size_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
 #define _vg_size_set _not_implemented
-#define _vg_free_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
 #define _vg_free_set _not_implemented
 #define _vg_sysid_get _not_implemented
 #define _vg_sysid_set _not_implemented
-#define _vg_extent_size_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_extent_size, vg->extent_size)
 #define _vg_extent_size_set _not_implemented
-#define _vg_extent_count_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_extent_count, vg->extent_count)
 #define _vg_extent_count_set _not_implemented
-#define _vg_free_count_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_free_count, vg->free_count)
 #define _vg_free_count_set _not_implemented
-#define _max_lv_get _not_implemented
+GET_NUM_PROPERTY_FN(max_lv, vg->max_lv)
 #define _max_lv_set _not_implemented
-#define _max_pv_get _not_implemented
+GET_NUM_PROPERTY_FN(max_pv, vg->max_pv)
 #define _max_pv_set _not_implemented
-#define _pv_count_get _not_implemented
+GET_NUM_PROPERTY_FN(pv_count, vg->pv_count)
 #define _pv_count_set _not_implemented
-#define _lv_count_get _not_implemented
+GET_NUM_PROPERTY_FN(lv_count, (vg_visible_lvs(vg)))
 #define _lv_count_set _not_implemented
-#define _snap_count_get _not_implemented
+GET_NUM_PROPERTY_FN(snap_count, (snapshot_count(vg)))
 #define _snap_count_set _not_implemented
-#define _vg_seqno_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_seqno, vg->seqno)
 #define _vg_seqno_set _not_implemented
 #define _vg_tags_get _not_implemented
 #define _vg_tags_set _not_implemented
-#define _vg_mda_count_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_mda_count, (vg_mda_count(vg)))
 #define _vg_mda_count_set _not_implemented
-#define _vg_mda_used_count_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_mda_used_count, (vg_mda_used_count(vg)))
 #define _vg_mda_used_count_set _not_implemented
-#define _vg_mda_free_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_mda_free, (vg_mda_free(vg)))
 #define _vg_mda_free_set _not_implemented
-#define _vg_mda_size_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_mda_size, (SECTOR_SIZE * vg_mda_size(vg)))
 #define _vg_mda_size_set _not_implemented
-#define _vg_mda_copies_get _not_implemented
+GET_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
 #define _vg_mda_copies_set _not_implemented
 
 /* LVSEG */


