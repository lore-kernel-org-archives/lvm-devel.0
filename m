From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:09:33 -0000
Subject: LVM2/lib/report properties.c
Message-ID: <20100930140933.18531.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:09:33

Modified files:
	lib/report     : properties.c 

Log message:
	Add pv 'get' functions for all pv properties.
	
	Add 'get' functions for all pv properties.
	Multiply by SECTOR_SIZE for pv properties pv_mda_free, pv_mda_size,
	pe_start, pv_size, pv_free, pv_used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/lib/report/properties.c	2010/09/30 14:08:58	1.6
+++ LVM2/lib/report/properties.c	2010/09/30 14:09:33	1.7
@@ -57,37 +57,37 @@
 }
 
 /* PV */
-#define _pv_fmt_get _not_implemented
+GET_PV_STR_PROPERTY_FN(pv_fmt, pv_fmt_dup(pv))
 #define _pv_fmt_set _not_implemented
-#define _pv_uuid_get _not_implemented
+GET_PV_STR_PROPERTY_FN(pv_uuid, pv_uuid_dup(pv))
 #define _pv_uuid_set _not_implemented
-#define _dev_size_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(dev_size, SECTOR_SIZE * pv_dev_size(pv))
 #define _dev_size_set _not_implemented
-#define _pv_name_get _not_implemented
+GET_PV_STR_PROPERTY_FN(pv_name, pv_name_dup(pv))
 #define _pv_name_set _not_implemented
-#define _pv_mda_free_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_mda_free, SECTOR_SIZE * pv_mda_free(pv))
 #define _pv_mda_free_set _not_implemented
-#define _pv_mda_size_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_mda_size, SECTOR_SIZE * pv_mda_size(pv))
 #define _pv_mda_size_set _not_implemented
-#define _pe_start_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pe_start, SECTOR_SIZE * pv->pe_start)
 #define _pe_start_set _not_implemented
-#define _pv_size_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_size, SECTOR_SIZE * pv_size_field(pv))
 #define _pv_size_set _not_implemented
-#define _pv_free_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_free, SECTOR_SIZE * pv_free(pv))
 #define _pv_free_set _not_implemented
-#define _pv_used_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_used, SECTOR_SIZE * pv_used(pv))
 #define _pv_used_set _not_implemented
-#define _pv_attr_get _not_implemented
+GET_PV_STR_PROPERTY_FN(pv_attr, pv_attr_dup(pv->vg->vgmem, pv))
 #define _pv_attr_set _not_implemented
-#define _pv_pe_count_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_pe_count, pv->pe_count)
 #define _pv_pe_count_set _not_implemented
-#define _pv_pe_alloc_count_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_pe_alloc_count, pv->pe_alloc_count)
 #define _pv_pe_alloc_count_set _not_implemented
-#define _pv_tags_get _not_implemented
+GET_PV_STR_PROPERTY_FN(pv_tags, pv_tags_dup(pv))
 #define _pv_tags_set _not_implemented
-#define _pv_mda_count_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_mda_count, pv_mda_count(pv))
 #define _pv_mda_count_set _not_implemented
-#define _pv_mda_used_count_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
 #define _pv_mda_used_count_set _not_implemented
 
 /* LV */


