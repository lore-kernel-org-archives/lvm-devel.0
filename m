From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 14 Sep 2017 12:54:33 -0400
Subject: master - kernel: Refresh dm-ioctl.h
Message-ID: <201709141654.v8EGsX6b003691@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=29834b6e918e4b3774fd82aec0cfd2cbb5d162bb
Commit:        29834b6e918e4b3774fd82aec0cfd2cbb5d162bb
Parent:        71dbe0fe26937137cb0b2ef00cbbef4a729d4e94
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Sep 14 17:50:56 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Sep 14 17:50:56 2017 +0100

kernel: Refresh dm-ioctl.h

Adds DM_DEV_ARM_POLL
---
 libdm/misc/dm-ioctl.h |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index cdb0c4c..79f574c 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001 - 2003 Sistina Software (UK) Limited.
- * Copyright (C) 2004 - 2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004 - 2017 Red Hat, Inc. All rights reserved.
  *
  * This file is released under the LGPL.
  */
@@ -242,7 +242,8 @@ enum {
 	/* Added later */
 	DM_LIST_VERSIONS_CMD,
 	DM_TARGET_MSG_CMD,
-	DM_DEV_SET_GEOMETRY_CMD
+	DM_DEV_SET_GEOMETRY_CMD,
+	DM_DEV_ARM_POLL_CMD,
 };
 
 #define DM_IOCTL 0xfd
@@ -257,6 +258,7 @@ enum {
 #define DM_DEV_SUSPEND   _IOWR(DM_IOCTL, DM_DEV_SUSPEND_CMD, struct dm_ioctl)
 #define DM_DEV_STATUS    _IOWR(DM_IOCTL, DM_DEV_STATUS_CMD, struct dm_ioctl)
 #define DM_DEV_WAIT      _IOWR(DM_IOCTL, DM_DEV_WAIT_CMD, struct dm_ioctl)
+#define DM_DEV_ARM_POLL  _IOWR(DM_IOCTL, DM_DEV_ARM_POLL_CMD, struct dm_ioctl)
 
 #define DM_TABLE_LOAD    _IOWR(DM_IOCTL, DM_TABLE_LOAD_CMD, struct dm_ioctl)
 #define DM_TABLE_CLEAR   _IOWR(DM_IOCTL, DM_TABLE_CLEAR_CMD, struct dm_ioctl)
@@ -269,9 +271,9 @@ enum {
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	31
+#define DM_VERSION_MINOR	36
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2015-03-12)"
+#define DM_VERSION_EXTRA	"-ioctl (2017-06-09)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */


