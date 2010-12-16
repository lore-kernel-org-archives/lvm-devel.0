From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:56:19 +0100
Subject: [PATCH 1/3] Add internal fs cookie
In-Reply-To: <cover.1292496056.git.zkabelac@redhat.com>
References: <cover.1292496056.git.zkabelac@redhat.com>
Message-ID: <a320108b1a04c51bbb5867ed321b0375f0e2c091.1292496056.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add functions for handling internal lvm cookie used for
all dm_tree operations until fs_unlock is called.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/fs.c |   15 +++++++++++++++
 lib/activate/fs.h |    2 ++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 1523115..e74bbb3 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -26,6 +26,8 @@
 #include <limits.h>
 #include <dirent.h>
 
+static uint32_t _fs_cookie;
+
 static int _mk_dir(const char *dev_dir, const char *vg_name)
 {
 	char vg_path[PATH_MAX];
@@ -396,7 +398,20 @@ int fs_rename_lv(struct logical_volume *lv, const char *dev,
 void fs_unlock(void)
 {
 	if (!memlock()) {
+		if (!dm_udev_wait(_fs_cookie))
+			stack;
+		_fs_cookie = 0;
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
1.7.3.3


