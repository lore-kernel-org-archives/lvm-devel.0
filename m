From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 23 Apr 2015 17:40:45 +0000 (UTC)
Subject: master - libdm: Add DM_INTERNAL_SUSPEND_FLAG.
Message-ID: <20150423174045.3389061086@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19066191877029a1fe376a7d4a657e0dba1dd13d
Commit:        19066191877029a1fe376a7d4a657e0dba1dd13d
Parent:        95da21cc18d87ba7ae921b54abe5f622d12abb31
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 23 18:39:04 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 23 18:39:04 2015 +0100

libdm: Add DM_INTERNAL_SUSPEND_FLAG.

Still needs to be reported by dmsetup.
---
 WHATS_NEW_DM          |    1 +
 libdm/misc/dm-ioctl.h |   11 ++++++++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5d168f1..c6a1619 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.96 - 
 =================================
+  Add DM_INTERNAL_SUSPEND_FLAG to dm-ioctl.h.
   Install blkdeactivate script and its man page with make install_device-mapper.
 
 Version 1.02.95 - 15th March 2015
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index 01a2b9e..cdb0c4c 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001 - 2003 Sistina Software (UK) Limited.
- * Copyright (C) 2004 - 2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004 - 2015 Red Hat, Inc. All rights reserved.
  *
  * This file is released under the LGPL.
  */
@@ -269,9 +269,9 @@ enum {
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	27
+#define DM_VERSION_MINOR	31
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2013-10-30)"
+#define DM_VERSION_EXTRA	"-ioctl (2015-03-12)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -354,4 +354,9 @@ enum {
  */
 #define DM_DEFERRED_REMOVE		(1 << 17) /* In/Out */
 
+/*
+ * If set, the device is suspended internally.
+ */
+#define DM_INTERNAL_SUSPEND_FLAG	(1 << 18) /* Out */
+
 #endif				/* _LINUX_DM_IOCTL_H */


