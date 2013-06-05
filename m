From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:43 +0000 (UTC)
Subject: dev-mornfall-lvmcache - ioctl: add DM_DATA_OUT_FLAG to dm-ioctl.h
Message-ID: <20130605120343.4E7176116D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d96b854ac054aafc8a9981016faefb9f122fccbb
Commit:        d96b854ac054aafc8a9981016faefb9f122fccbb
Parent:        fca5acd072a9ab4899a76e421c714ca14df3e516
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri May 17 17:06:40 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri May 17 17:06:40 2013 +0100

ioctl: add DM_DATA_OUT_FLAG to dm-ioctl.h

---
 libdm/misc/dm-ioctl.h |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index 1cf66fe..dae2bcb 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001 - 2003 Sistina Software (UK) Limited.
- * Copyright (C) 2004 - 2012 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004 - 2013 Red Hat, Inc. All rights reserved.
  *
  * This file is released under the LGPL.
  */
@@ -269,9 +269,9 @@ enum {
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	23
+#define DM_VERSION_MINOR	24
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2012-07-25)"
+#define DM_VERSION_EXTRA	"-ioctl (2013-01-15)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -338,4 +338,9 @@ enum {
  */
 #define DM_SECURE_DATA_FLAG		(1 << 15) /* In */
 
+/*
+ * If set, a message generated output data.
+ */
+#define DM_DATA_OUT_FLAG		(1 << 16) /* Out */
+
 #endif				/* _LINUX_DM_IOCTL_H */


