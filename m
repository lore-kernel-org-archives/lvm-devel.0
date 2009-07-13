From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 13 Jul 2009 00:12:36 -0400
Subject: [PATCH 3/5] Add lvm_vg_* APIs to create and modify VGs.
In-Reply-To: <1247458358-24590-3-git-send-email-dwysocha@redhat.com>
References: <1247458358-24590-1-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-2-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1247458358-24590-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add some liblvm APIs for VGs.  Most of these APIs simply call into the internal
liblvm library.  Ideally we should call the liblvm functions directly from
the tools.  However, until we convert more of the code to liblvm functions,
things like the cmd_context will get in the way.  For now just implement the
liblvm functions as wrappers around the internal functions, with a little
error checking and return code handling.

The following APIs are implemented:
lvm_vg_create, lvm_vg_extend, lvm_vg_set_extent_size, lvm_vg_write,
lvm_vg_remove, lvm_vg_close.

Still TODO:
- cleanup error handling by using lvm_errno() and related APIs
- cleanup naming / clarify which functions commit to disk vs not
- implement more 'set' functions
- decide on 'set' / 'change' nomenclature

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 liblvm/Makefile.in |    3 +-
 liblvm/lvm.h       |   66 ++++++++++++++++++++++++++++++++++++++++
 liblvm/vg.c        |   84 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 152 insertions(+), 1 deletions(-)
 create mode 100644 liblvm/vg.c

diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index fdd2ecc..5895c0c 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -17,7 +17,8 @@ top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
 SOURCES =\
-	lvm_base.c
+	lvm_base.c \
+	vg.c
 
 LIB_NAME = liblvm2app
 LIB_VERSION = $(LIB_VERSION_LVM)
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 4e71e15..982a22b 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -68,5 +68,71 @@ void lvm_destroy(lvm_t libh);
  */
 int lvm_reload_config(lvm_t libh);
 
+/**
+ * Create a VG with default parameters.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ *
+ * \return  A VG handle with error code set appropriately.  Use
+ *          vg_read_error() to determine success or failure.
+ */
+vg_t *lvm_vg_create(lvm_t libh, const char *vg_name);
+
+/**
+ * Extend a VG by adding a device.
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
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create.
+ *
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_write(vg_t *vg);
+
+/**
+ * Remove a VG from the system, committing to the disks.
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
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create.
+ *
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_vg_close(vg_t *vg);
 
 #endif /* _LIB_LVM_H */
diff --git a/liblvm/vg.c b/liblvm/vg.c
new file mode 100644
index 0000000..10b9d08
--- /dev/null
+++ b/liblvm/vg.c
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
-- 
1.6.0.6


