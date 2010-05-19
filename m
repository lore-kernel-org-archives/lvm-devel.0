From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 May 2010 11:53:17 -0000
Subject: LVM2/liblvm .exported_symbols lvm2app.h lvm_base.c
Message-ID: <20100519115317.25417.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-05-19 11:53:12

Modified files:
	liblvm         : .exported_symbols lvm2app.h lvm_base.c 

Log message:
	Add lvm2app interfaces to lookup a vgname from a pvid and pvname.
	
	lvm2app forces applications to start with a volume group name,
	open the volume group, then operate on individual pvs.  In some
	cases the application may want to start with a device name rather
	than the volume group name.  Today, if an application wants to
	do this, it must iterate through all the volume groups to find
	the volume group that the specific device is attached to.
	These new interfaces allow the application to avoid such overhead.
	Bump the lvm2app version number to 3.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/liblvm/.exported_symbols	2010/02/24 18:16:26	1.25
+++ LVM2/liblvm/.exported_symbols	2010/05/19 11:53:12	1.26
@@ -48,3 +48,5 @@
 lvm_list_vg_uuids
 lvm_vg_create_lv_linear
 lvm_vg_remove_lv
+lvm_vgname_from_pvid
+lvm_vgname_from_device
--- LVM2/liblvm/lvm2app.h	2010/04/19 15:22:24	1.15
+++ LVM2/liblvm/lvm2app.h	2010/05/19 11:53:12	1.16
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2008,2009,2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -344,6 +344,45 @@
 struct dm_list *lvm_list_vg_uuids(lvm_t libh);
 
 /**
+ * Return the volume group name given a PV UUID
+ *
+ * \memberof lvm_t
+ *
+ * The memory allocated for the name is tied to the lvm_t handle and will be
+ * released when lvm_quit is called.
+ *
+ * NOTE: This function may scan devices in the system for LVM metadata.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init().
+ *
+ * \return
+ * The volume group name for the given PV UUID.
+ * NULL is returned if the PV UUID is not associated with a volume group.
+ */
+const char *lvm_vgname_from_pvid(lvm_t libh, const char *pvid);
+
+/**
+ * Return the volume group name given a device name
+ *
+ * \memberof lvm_t
+ *
+ * The memory allocated for the name is tied to the lvm_t handle and will be
+ * released when lvm_quit is called.
+ *
+ * NOTE: This function may scan devices in the system for LVM metadata.
+ *
+ * \param   libh
+ * Handle obtained from lvm_init().
+ *
+ * \return
+ * The volume group name for the given device name.
+ * NULL is returned if the device is not an LVM device.
+ *
+ */
+const char *lvm_vgname_from_device(lvm_t libh, const char *device);
+
+/**
  * Open an existing VG.
  *
  * Open a VG for reading or writing.
--- LVM2/liblvm/lvm_base.c	2010/05/06 11:15:55	1.16
+++ LVM2/liblvm/lvm_base.c	2010/05/19 11:53:12	1.17
@@ -17,6 +17,7 @@
 #include "toolcontext.h"
 #include "locking.h"
 #include "lvm-version.h"
+#include "metadata-exported.h"
 
 const char *lvm_library_get_version(void)
 {
@@ -98,3 +99,21 @@
 {
 	return stored_errmsg();
 }
+
+const char *lvm_vgname_from_pvid(lvm_t libh, const char *pvid)
+{
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+	char uuid[64] __attribute((aligned(8)));
+
+	if (!id_read_format(uuid, pvid)) {
+		log_error(INTERNAL_ERROR "Unable to convert uuid");
+		return NULL;
+	}
+	return find_vgname_from_pvid(cmd, uuid);
+}
+
+const char *lvm_vgname_from_device(lvm_t libh, const char *device)
+{
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+	return find_vgname_from_pvname(cmd, device);
+}


