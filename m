From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 03:02:15 -0000
Subject: LVM2/liblvm Makefile.in lvm.h lvm_vg.c
Message-ID: <20090714030215.24194.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 03:02:14

Modified files:
	liblvm         : Makefile.in lvm.h 
Added files:
	liblvm         : lvm_vg.c 

Log message:
	Add lvm_vg_* APIs to create and modify VGs.
	
	Add some liblvm APIs for VGs.  Most of these APIs simply call into the internal
	liblvm library.  Ideally we should call the liblvm functions directly from
	the tools.  However, until we convert more of the code to liblvm functions,
	things like the cmd_context will get in the way.  For now just implement the
	liblvm functions as wrappers around the internal functions, with a little
	error checking and return code handling.  We put all these vg APIs into a
	new file, lvm_vg.c
	
	The following APIs are implemented:
	lvm_vg_create, lvm_vg_extend, lvm_vg_set_extent_size, lvm_vg_write,
	lvm_vg_remove, lvm_vg_close.
	
	Still TODO:
	- cleanup error handling by using lvm_errno() and related APIs
	- cleanup naming / clarify which functions commit to disk vs not
	- implement more 'set' functions
	- decide on 'set' / 'change' nomenclature
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

/cvs/lvm2/LVM2/liblvm/lvm_vg.c,v  -->  standard output
revision 1.1
--- LVM2/liblvm/lvm_vg.c
+++ -	2009-07-14 03:02:14.864108000 +0000
@@ -0,0 +1,84 @@
+/*
+ * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "lvm.h"
+#include "toolcontext.h"
+#include "metadata-exported.h"
+#include "archiver.h"
+#include "locking.h"
+
+vg_t *lvm_vg_create(lvm_t libh, const char *vg_name)
+{
+	return vg_create((struct cmd_context *)libh, vg_name);
+}
+
+int lvm_vg_extend(vg_t *vg, const char *device)
+{
+	if (vg_read_error(vg))
+		goto_bad;
+
+	return vg_extend(vg, 1, (char **) &device);
+bad:
+	return 0;
+}
+
+int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)
+{
+	if (vg_read_error(vg))
+		goto_bad;
+
+	return vg_set_extent_size(vg, new_size);
+bad:
+	return 0;
+}
+
+int lvm_vg_write(vg_t *vg)
+{
+	if (vg_read_error(vg))
+		goto_bad;
+
+	if (!archive(vg)) {
+		goto_bad;
+	}
+
+	/* Store VG on disk(s) */
+	if (!vg_write(vg) || !vg_commit(vg)) {
+		goto_bad;
+	}
+	return 1;
+bad:
+	return 0;
+}
+
+int lvm_vg_close(vg_t *vg)
+{
+	if (vg_read_error(vg))
+		goto_bad;
+
+	unlock_and_release_vg(vg->cmd, vg, vg->name);
+	return 1;
+bad:
+	return 0;
+}
+
+int lvm_vg_remove(vg_t *vg)
+{
+	if (vg_read_error(vg))
+		goto_bad;
+
+	return vg_remove_single(vg);
+bad:
+	return 0;
+}
--- LVM2/liblvm/Makefile.in	2009/05/22 14:45:00	1.6
+++ LVM2/liblvm/Makefile.in	2009/07/14 03:02:14	1.7
@@ -17,7 +17,8 @@
 VPATH = @srcdir@
 
 SOURCES =\
-	lvm_base.c
+	lvm_base.c \
+	lvm_vg.c
 
 LIB_NAME = liblvm2app
 LIB_VERSION = $(LIB_VERSION_LVM)
--- LVM2/liblvm/lvm.h	2009/07/14 03:00:31	1.2
+++ LVM2/liblvm/lvm.h	2009/07/14 03:02:14	1.3
@@ -42,6 +42,9 @@
 /**
  * Create a LVM handle.
  *
+ * Once all LVM operations have been completed, use lvm_destroy to release
+ * the handle and any associated resources.
+ *
  * \param   system_dir
  *          Set an alternative LVM system directory. Use NULL to use the 
  *          default value. If the environment variable LVM_SYSTEM_DIR is set, 
@@ -68,5 +71,99 @@
  */
 int lvm_reload_config(lvm_t libh);
 
+/**
+ * Create a VG with default parameters.
+ *
+ * This API requires calling lvm_vg_write to commit the change to disk.
+ * Upon success, other APIs may be used to set non-default parameters.
+ * For example, to set a non-default extent size, use lvm_vg_set_extent_size.
+ * Next, to add physical storage devices to the volume group, use
+ * lvm_vg_extend for each device.
+ * Once all parameters are set appropriately and all devices are added to the
+ * VG, use lvm_vg_write to commit the new VG to disk, and lvm_vg_close to
+ * release the VG handle.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ *
+ * \return  A VG handle with error code set appropriately.
+ * FIXME: Update error handling description after errno and logging patches
+ */
+vg_t *lvm_vg_create(lvm_t libh, const char *vg_name);
+
+/**
+ * Extend a VG by adding a device.
+ *
+ * This API requires calling lvm_vg_write to commit the change to disk.
+ * After successfully adding a device, use lvm_vg_write to commit the new VG
+ * to disk.  Upon failure, retry the operation or release the VG handle with
+ * lvm_vg_close.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create.
+ *
+ * \param   device
+ *          Name of device to add to VG.
+ *
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_extend(vg_t *vg, const char *device);
+
+/**
+ * Set the extent size of a VG.
+ *
+ * This API requires calling lvm_vg_write to commit the change to disk.
+ * After successfully setting a new extent size, use lvm_vg_write to commit
+ * the new VG to disk.  Upon failure, retry the operation or release the VG
+ * handle with lvm_vg_close.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create.
+ *
+ * \param   new_size
+ *          New extent size to set (in sectors).
+ *
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
+
+/**
+ * Write a VG to disk.
+ *
+ * This API commits the VG to disk.
+ * Upon failure, retry the operation and/or release the VG handle with
+ * lvm_vg_close.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create.
+ *
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_write(vg_t *vg);
+
+/**
+ * Remove a VG from the system.
+ *
+ * This API commits the change to disk and does not require calling
+ * lvm_vg_write.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create.
+ *
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_remove(vg_t *vg);
+
+/**
+ * Close a VG opened with lvm_vg_create
+ *
+ * This API releases a VG handle and any resources associated with the handle.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create.
+ *
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_close(vg_t *vg);
 
 #endif /* _LIB_LVM_H */


