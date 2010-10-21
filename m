From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Oct 2010 18:51:18 -0000
Subject: LVM2/lib/report properties.c properties.h
Message-ID: <20101021185118.18632.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-21 18:51:17

Modified files:
	lib/report     : properties.c properties.h 

Log message:
	Add lv_get_property() internal lvm function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/lib/report/properties.c	2010/10/21 14:49:43	1.20
+++ LVM2/lib/report/properties.c	2010/10/21 18:51:16	1.21
@@ -267,6 +267,12 @@
 	return 1;
 }
 
+int lv_get_property(const struct logical_volume *lv,
+		    struct lvm_property_type *prop)
+{
+	return _get_property(lv, prop, LVS);
+}
+
 int vg_get_property(const struct volume_group *vg,
 		    struct lvm_property_type *prop)
 {
--- LVM2/lib/report/properties.h	2010/10/21 14:49:43	1.3
+++ LVM2/lib/report/properties.h	2010/10/21 18:51:17	1.4
@@ -32,6 +32,8 @@
 	int (*set) (void *obj, struct lvm_property_type *prop);
 };
 
+int lv_get_property(const struct logical_volume *lv,
+		    struct lvm_property_type *prop);
 int vg_get_property(const struct volume_group *vg,
 		    struct lvm_property_type *prop);
 int pv_get_property(const struct physical_volume *pv,


