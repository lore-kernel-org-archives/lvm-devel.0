From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2009 12:47:15 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_vg.c
Message-ID: <20090724124715.21481.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-24 12:47:15

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_vg.c 

Log message:
	Add lvm_list_vg_names and lvm_list_vg_ids liblvm functions.
	
	These functions provide the capability of enumerating all vgnames and
	vgids in the system.  They do not do a scan of the system.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/liblvm/.exported_symbols	2009/07/23 23:40:05	1.6
+++ LVM2/liblvm/.exported_symbols	2009/07/24 12:47:15	1.7
@@ -18,3 +18,5 @@
 lvm_errmsg
 lvm_vg_list_pvs
 lvm_vg_list_lvs
+lvm_list_vg_names
+lvm_list_vg_ids
--- LVM2/liblvm/lvm.h	2009/07/23 23:40:05	1.10
+++ LVM2/liblvm/lvm.h	2009/07/24 12:47:15	1.11
@@ -44,6 +44,11 @@
 	lv_t *lv;
 } lv_list_t;
 
+struct lvm_str_list {
+	struct dm_list list;
+	const char *str;
+};
+
 /**
  * Return a list of LV handles for a given VG handle.
  *
@@ -256,4 +261,30 @@
  */
 struct dm_list *lvm_vg_list_pvs(vg_t *vg);
 
+/**
+ * Return a list of VG names or VG uuids in the system.
+ *
+ * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
+ * To process the list, use the dm_list iterator functions.  For example:
+ *      vg_t *vg;
+ *      struct dm_list *vgnames;
+ *      struct lvm_str_list *strl;
+ *
+ *      vgnames = lvm_list_vg_names(libh);
+ *	dm_list_iterate_items(strl, vgnames) {
+ *		vgname = strl->str;
+ *              vg = lvm_vg_open(libh, vgname, "r");
+ *              // do something with vg
+ *              lvm_vg_close(vg);
+ *      }
+ *
+ *
+ * \return  A list of struct lvm_str_list
+ *          If no VGs exist on the system, NULL is returned.
+ * FIXME: handle list memory cleanup
+ */
+struct dm_list *lvm_list_vg_names(lvm_t libh);
+struct dm_list *lvm_list_vg_ids(lvm_t libh);
+
+
 #endif /* _LIB_LVM_H */
--- LVM2/liblvm/lvm_vg.c	2009/07/23 23:40:05	1.6
+++ LVM2/liblvm/lvm_vg.c	2009/07/24 12:47:15	1.7
@@ -188,3 +188,13 @@
 	name[NAME_LEN] = '\0';
 	return name;
 }
+
+struct dm_list *lvm_list_vg_names(lvm_t libh)
+{
+	return get_vgnames((struct cmd_context *)libh, 0);
+}
+
+struct dm_list *lvm_list_vg_ids(lvm_t libh)
+{
+	return get_vgids((struct cmd_context *)libh, 0);
+}


