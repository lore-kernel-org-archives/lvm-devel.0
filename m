From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 20 Sep 2011 14:56:42 +0200
Subject: [PATCH 3/7][retry remove] Add new "dm_set_sysfs_dir" fn to libdm to set the sysfs directory used in the system
Message-ID: <4E788D8A.30008@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 libdm/libdevmapper.h |    6 ++++++
 libdm/libdm-common.c |   33 +++++++++++++++++++++++++--------
 2 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 628d7da..ae39262 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -256,6 +256,12 @@ int dm_set_dev_dir(const char *dir);
 const char *dm_dir(void);
 
 /*
+ * Configure sysfs directory
+ */
+int dm_set_sysfs_dir(const char *dir);
+const char *dm_sysfs_dir(void);
+
+/*
  * Determine whether a major number belongs to device-mapper or not.
  */
 int dm_is_dm_major(uint32_t major);
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 0aacd1f..7517fb1 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -58,6 +58,7 @@ union semun
 #endif
 
 static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
+static char _sysfs_dir[PATH_MAX] = "";
 
 static int _verbose = 0;
 static int _suspended_dev_counter = 0;
@@ -1008,32 +1009,48 @@ void update_devs(void)
 	_pop_node_ops();
 }
 
-int dm_set_dev_dir(const char *dev_dir)
+static int _canonicalize_and_set_dir(const char *src, const char *suffix, size_t max_len, char *dir)
 {
 	size_t len;
 	const char *slash;
-	if (*dev_dir != '/') {
-		log_debug("Invalid dev_dir value, %s: "
-			  "not an absolute name.", dev_dir);
+
+	if (*src != '/') {
+		log_debug("Invalid directory value, %s: "
+			  "not an absolute name.", src);
 		return 0;
 	}
 
-	len = strlen(dev_dir);
-	slash = dev_dir[len-1] == '/' ? "" : "/";
+	len = strlen(src);
+	slash = src[len-1] == '/' ? "" : "/";
 
-	if (dm_snprintf(_dm_dir, sizeof _dm_dir, "%s%s%s", dev_dir, slash, DM_DIR) < 0) {
-		log_debug("Invalid dev_dir value, %s: name too long.", dev_dir);
+	if (dm_snprintf(dir, max_len, "%s%s%s", src, slash, suffix ? suffix : "") < 0) {
+		log_debug("Invalid directory value, %s: name too long.", src);
 		return 0;
 	}
 
 	return 1;
 }
 
+int dm_set_dev_dir(const char *dev_dir)
+{
+	return _canonicalize_and_set_dir(dev_dir, DM_DIR, sizeof _dm_dir, _dm_dir);
+}
+
 const char *dm_dir(void)
 {
 	return _dm_dir;
 }
 
+int dm_set_sysfs_dir(const char *sysfs_dir)
+{
+	return _canonicalize_and_set_dir(sysfs_dir, NULL, sizeof _sysfs_dir, _sysfs_dir);
+}
+
+const char *dm_sysfs_dir(void)
+{
+	return _sysfs_dir;
+}
+
 int dm_mknodes(const char *name)
 {
 	struct dm_task *dmt;


