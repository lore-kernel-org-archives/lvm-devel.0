From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jan 2010 14:37:12 -0000
Subject: LVM2 ./WHATS_NEW lib/report/report.c
Message-ID: <20100107143712.25368.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-07 14:37:12

Modified files:
	.              : WHATS_NEW 
	lib/report     : report.c 

Log message:
	Use offsetof() macro and avoid defining dummy static union for FIELD() macro.
	Makes it compilable by clang compiler.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1367&r2=1.1368
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/WHATS_NEW	2010/01/06 13:27:06	1.1367
+++ LVM2/WHATS_NEW	2010/01/07 14:37:11	1.1368
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Use offsetof() macro for FIELD() macro in lib/report/report.c.
   Rename mirror_device_fault_policy to mirror_image_fault policy.
   Remove empty PV devices if lvconvert --repair is using defined policies.
   Use fixed buffer to prevent stack overflow in persistent filter dump.
--- LVM2/lib/report/report.c	2009/10/31 17:26:14	1.106
+++ LVM2/lib/report/report.c	2010/01/07 14:37:12	1.107
@@ -24,6 +24,8 @@
 #include "str_list.h"
 #include "lvmcache.h"
 
+#include <stddef.h> /* offsetof() */
+
 struct lvm_report_object {
 	struct volume_group *vg;
 	struct logical_volume *lv;
@@ -32,17 +34,6 @@
 	struct pv_segment *pvseg;
 };
 
-/*
- * For macro use
- */
-static union {
-	struct physical_volume _pv;
-	struct logical_volume _lv;
-	struct volume_group _vg;
-	struct lv_segment _seg;
-	struct pv_segment _pvseg;
-} _dummy;
-
 static char _alloc_policy_char(alloc_policy_t alloc)
 {
 	switch (alloc) {
@@ -1156,9 +1147,17 @@
 
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
-#define FIELD(type, strct, sorttype, head, field, width, func, id, desc) {type, sorttype, (off_t)((uintptr_t)&_dummy._ ## strct.field - (uintptr_t)&_dummy._ ## strct), width, id, head, &_ ## func ## _disp, desc},
+#define FIELD(type, strct, sorttype, head, field, width, func, id, desc) \
+	{type, sorttype, offsetof(type_ ## strct, field), width, \
+	 id, head, &_ ## func ## _disp, desc},
+
+typedef struct physical_volume type_pv;
+typedef struct logical_volume type_lv;
+typedef struct volume_group type_vg;
+typedef struct lv_segment type_seg;
+typedef struct pv_segment type_pvseg;
 
-static struct dm_report_field_type _fields[] = {
+static const struct dm_report_field_type _fields[] = {
 #include "columns.h"
 {0, 0, 0, 0, "", "", NULL, NULL},
 };


