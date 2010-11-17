From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 20:11:29 -0000
Subject: LVM2/lib/report properties.c properties.h
Message-ID: <20101117201129.8427.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 20:11:28

Modified files:
	lib/report     : properties.c properties.h 

Log message:
	Add the macro and specific 'get' functions for pvsegs.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/lib/report/properties.c	2010/11/17 20:08:14	1.24
+++ LVM2/lib/report/properties.c	2010/11/17 20:11:27	1.25
@@ -36,6 +36,8 @@
 	GET_NUM_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
 #define GET_LVSEG_NUM_PROPERTY_FN(NAME, VALUE) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, lv_segment, lvseg)
+#define GET_PVSEG_NUM_PROPERTY_FN(NAME, VALUE) \
+	GET_NUM_PROPERTY_FN(NAME, VALUE, pv_segment, pvseg)
 
 #define SET_NUM_PROPERTY_FN(NAME, SETFN, TYPE, VAR)			\
 static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
@@ -68,6 +70,8 @@
 	GET_STR_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
 #define GET_LVSEG_STR_PROPERTY_FN(NAME, VALUE) \
 	GET_STR_PROPERTY_FN(NAME, VALUE, lv_segment, lvseg)
+#define GET_PVSEG_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, pv_segment, pvseg)
 
 static int _not_implemented_get(const void *obj, struct lvm_property_type *prop)
 {
@@ -237,9 +241,9 @@
 
 
 /* PVSEG */
-#define _pvseg_start_get _not_implemented_get
+GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
 #define _pvseg_start_set _not_implemented_set
-#define _pvseg_size_get _not_implemented_get
+GET_PVSEG_NUM_PROPERTY_FN(pvseg_size, pvseg->len)
 #define _pvseg_size_set _not_implemented_set
 
 
@@ -340,6 +344,12 @@
 	return _get_property(vg, prop, VGS);
 }
 
+int pvseg_get_property(const struct pv_segment *pvseg,
+		       struct lvm_property_type *prop)
+{
+	return _get_property(pvseg, prop, PVSEGS);
+}
+
 int pv_get_property(const struct physical_volume *pv,
 		    struct lvm_property_type *prop)
 {
--- LVM2/lib/report/properties.h	2010/11/17 20:08:14	1.8
+++ LVM2/lib/report/properties.h	2010/11/17 20:11:28	1.9
@@ -39,6 +39,8 @@
 		    struct lvm_property_type *prop);
 int vg_get_property(const struct volume_group *vg,
 		    struct lvm_property_type *prop);
+int pvseg_get_property(const struct pv_segment *pvseg,
+		       struct lvm_property_type *prop);
 int pv_get_property(const struct physical_volume *pv,
 		    struct lvm_property_type *prop);
 int lv_set_property(struct logical_volume *lv,


