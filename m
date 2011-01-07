From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 Jan 2011 12:17:34 +0100
Subject: [PATCH 6/8] Add internal fs cookie
In-Reply-To: <cover.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
Message-ID: <c1ecd1ab7967504239b8258ad0bb2517fa4314a5.1294398815.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add functions for handling internal lvm cookie used for
all dm_tree operations until fs_unlock is called.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/fs.c |   22 +++++++++++++++++++++-
 lib/activate/fs.h |    2 ++
 2 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 1523115..cbe823a 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -26,6 +26,12 @@
 #include <limits.h>
 #include <dirent.h>
 
+/*
+ * Library cookie to combine multiple fs transactions.
+ * Supports to wait for udev device settle only when needed.
+ */
+static uint32_t _fs_cookie = DM_COOKIE_AUTO_CREATE;
+
 static int _mk_dir(const char *dev_dir, const char *vg_name)
 {
 	char vg_path[PATH_MAX];
@@ -396,7 +402,21 @@ int fs_rename_lv(struct logical_volume *lv, const char *dev,
 void fs_unlock(void)
 {
 	if (!memlock()) {
+		/* Wait for all processed udev devices */
+		if (!dm_udev_wait(_fs_cookie))
+			stack;
+		_fs_cookie = DM_COOKIE_AUTO_CREATE; /* Reset cookie */
 		dm_lib_release();
 		_pop_fs_ops();
 	}
 }
+
+uint32_t fs_get_cookie(void)
+{
+	return _fs_cookie;
+}
+
+void fs_set_cookie(uint32_t cookie)
+{
+	_fs_cookie = cookie;
+}
diff --git a/lib/activate/fs.h b/lib/activate/fs.h
index 28b2c73..695c529 100644
--- a/lib/activate/fs.h
+++ b/lib/activate/fs.h
@@ -30,5 +30,7 @@ int fs_del_lv_byname(const char *dev_dir, const char *vg_name,
 int fs_rename_lv(struct logical_volume *lv, const char *dev, 
 		 const char *old_vgname, const char *old_lvname);
 void fs_unlock(void);
+uint32_t fs_get_cookie(void);
+void fs_set_cookie(uint32_t cookie);
 
 #endif
-- 
1.7.3.4


