From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 11 May 2010 08:36:09 -0400
Subject: [PATCH 5/6] Add lvm2app interfaces to lookup a vgname from a pvid and pvname.
In-Reply-To: <1273581370-13528-5-git-send-email-dwysocha@redhat.com>
References: <1273581370-13528-1-git-send-email-dwysocha@redhat.com>
	<1273581370-13528-2-git-send-email-dwysocha@redhat.com>
	<1273581370-13528-3-git-send-email-dwysocha@redhat.com>
	<1273581370-13528-4-git-send-email-dwysocha@redhat.com>
	<1273581370-13528-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1273581370-13528-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

lvm2app forces applications to start with a volume group name,
open the volume group, then operate on individual pvs.  In some
cases the application may want to start with a device name rather
than the volume group name.  Today, if an application wants to
do this, it must iterate through all the volume groups to find
the volume group that the specific device is attached to.
These new interfaces allow the application to avoid such overhead.
Bump the lvm2app version number to 3.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 VERSION                  |    2 +-
 liblvm/.exported_symbols |    2 ++
 liblvm/lvm2app.h         |   41 ++++++++++++++++++++++++++++++++++++++++-
 liblvm/lvm_base.c        |   19 +++++++++++++++++++
 4 files changed, 62 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index d1ca44f..718913f 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.65(2)-cvs (2010-04-30)
+2.02.65(3)-cvs (2010-04-30)
diff --git a/liblvm/.exported_symbols b/liblvm/.exported_symbols
index 9b61d45..6f53de3 100644
--- a/liblvm/.exported_symbols
+++ b/liblvm/.exported_symbols
@@ -48,3 +48,5 @@ lvm_list_vg_names
 lvm_list_vg_uuids
 lvm_vg_create_lv_linear
 lvm_vg_remove_lv
+lvm_vgname_from_pvid
+lvm_vgname_from_device
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index ed86665..09455da 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2008,2009,2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -344,6 +344,45 @@ struct dm_list *lvm_list_vg_names(lvm_t libh);
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
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 1b2ed9f..08ef14f 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -17,6 +17,7 @@
 #include "toolcontext.h"
 #include "locking.h"
 #include "lvm-version.h"
+#include "metadata-exported.h"
 
 const char *lvm_library_get_version(void)
 {
@@ -98,3 +99,21 @@ const char *lvm_errmsg(lvm_t libh)
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
-- 
1.6.0.6


