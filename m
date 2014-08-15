From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 15 Aug 2014 12:47:06 +0000 (UTC)
Subject: master - libdm: Add DM_DEFERRED_REMOVE to dm-ioctl.h.
Message-ID: <20140815124706.B03CC60F22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a7682cbc982004e880a740d61ca5d12f0caf769
Commit:        8a7682cbc982004e880a740d61ca5d12f0caf769
Parent:        8740ecfa6492d149637a2f23d3bd7328863f0a78
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 15 13:45:55 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 15 13:45:55 2014 +0100

libdm: Add DM_DEFERRED_REMOVE to dm-ioctl.h.

---
 WHATS_NEW_DM          |    1 +
 libdm/misc/dm-ioctl.h |   17 ++++++++++++++---
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index cf74aca..41aa89d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.89 -
 =================================
+  Update dm-ioctl.h to include DM_DEFERRED_REMOVE flag.
   Add support for selection to match string list subset, recognize { } operator.
   Fix string list selection with '[value]' to not match list that's superset.
   Fix string list selection to match whole words only, not prefixes.
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index 76316b0..01a2b9e 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001 - 2003 Sistina Software (UK) Limited.
- * Copyright (C) 2004 - 2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004 - 2014 Red Hat, Inc. All rights reserved.
  *
  * This file is released under the LGPL.
  */
@@ -269,9 +269,9 @@ enum {
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	24
+#define DM_VERSION_MINOR	27
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2013-01-15)"
+#define DM_VERSION_EXTRA	"-ioctl (2013-10-30)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -343,4 +343,15 @@ enum {
  */
 #define DM_DATA_OUT_FLAG		(1 << 16) /* Out */
 
+/*
+ * If set with DM_DEV_REMOVE or DM_REMOVE_ALL this indicates that if
+ * the device cannot be removed immediately because it is still in use
+ * it should instead be scheduled for removal when it gets closed.
+ *
+ * On return from DM_DEV_REMOVE, DM_DEV_STATUS or other ioctls, this
+ * flag indicates that the device is scheduled to be removed when it
+ * gets closed.
+ */
+#define DM_DEFERRED_REMOVE		(1 << 17) /* In/Out */
+
 #endif				/* _LINUX_DM_IOCTL_H */


