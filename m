From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Mar 2016 15:05:17 +0000 (UTC)
Subject: master - coverity: fix some issues reported by coverity for recent code
Message-ID: <20160322150517.7A22961055@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94f78e0183e2517199e19d0473a7d5480660db0a
Commit:        94f78e0183e2517199e19d0473a7d5480660db0a
Parent:        3d26d283ea7234ee3e4499b53f185696e0c5e15c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 22 16:03:51 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 22 16:03:55 2016 +0100

coverity: fix some issues reported by coverity for recent code

---
 lib/device/dev-cache.c  |   19 ++++++++++---------
 lib/metadata/metadata.c |   15 ++++++++++-----
 2 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 06438d9..c0267a9 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -366,6 +366,7 @@ static int _get_sysfs_value(const char *path, char *buf, size_t buf_size)
 {
 	FILE *fp;
 	size_t len;
+	int r = 0;
 
 	if (!(fp = fopen(path, "r"))) {
 		log_sys_error("fopen", path);
@@ -374,23 +375,23 @@ static int _get_sysfs_value(const char *path, char *buf, size_t buf_size)
 
 	if (!fgets(buf, buf_size, fp)) {
 		log_sys_error("fgets", path);
-		if (fclose(fp))
-			log_sys_error("fclose", path);
-		return 0;
+		goto out;
 	}
 
 	if (!(len = strlen(buf)) || (len == 1 && buf[0] == '\n')) {
 		log_error("_get_sysfs_value: %s: no value", path);
-		return 0;
+		goto out;
 	}
 
 	if (buf[len - 1] == '\n')
 		buf[len - 1] = '\0';
 
+	r = 1;
+out:
 	if (fclose(fp))
 		log_sys_error("fclose", path);
 
-	return 1;
+	return r;
 }
 
 static int _get_dm_uuid_from_sysfs(char *buf, size_t buf_size, int major, int minor)
@@ -427,14 +428,14 @@ static struct dm_list *_get_or_add_list_by_index_key(struct dm_hash_table *idx,
 	return list;
 }
 
-static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev_name)
+static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *devname)
 {
 	char path[PATH_MAX];
 	char buf[PATH_MAX];
 	int major, minor;
 
-	if (dm_snprintf(path, sizeof(path), "%sblock/%s/dev", dm_sysfs_dir(), dev_name) < 0) {
-		log_error("_get_device_for_non_dm_dev: %s: dm_snprintf failed", dev_name);
+	if (dm_snprintf(path, sizeof(path), "%sblock/%s/dev", dm_sysfs_dir(), devname) < 0) {
+		log_error("_get_device_for_non_dm_dev: %s: dm_snprintf failed", devname);
 		return NULL;
 	}
 
@@ -442,7 +443,7 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 		return_NULL;
 
 	if (sscanf(buf, "%d:%d", &major, &minor) != 2) {
-		log_error("_get_device_for_non_dm_dev: %s: failed to get major and minor number", dev_name);
+		log_error("_get_device_for_non_dm_dev: %s: failed to get major and minor number", devname);
 		return NULL;
 	}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2c5ede5..ecdb5af 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4600,8 +4600,10 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 			if (!found_inconsistent) {
 				dm_pool_begin_object(mem, 32);
 				found_inconsistent = 1;
-			} else
-				dm_pool_grow_object(mem, DEV_LIST_DELIM, sizeof(DEV_LIST_DELIM) - 1);
+			} else {
+				if (!dm_pool_grow_object(mem, DEV_LIST_DELIM, sizeof(DEV_LIST_DELIM) - 1))
+					goto_bad;
+			}
 			if (!dm_pool_grow_object(mem, dev_name(dev), 0))
 				goto_bad;
 		}
@@ -4610,7 +4612,8 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 	if (!found_inconsistent)
 		return 1;
 
-	dm_pool_grow_object(mem, "\0", 1);
+	if (!dm_pool_grow_object(mem, "\0", 1))
+		goto_bad;
 	used_devnames = dm_pool_end_object(mem);
 
 	found_inconsistent = 0;
@@ -4628,7 +4631,8 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 						dm_pool_begin_object(mem, 32);
 						found_inconsistent = 1;
 					} else {
-						dm_pool_grow_object(mem, DEV_LIST_DELIM, sizeof(DEV_LIST_DELIM) - 1);
+						if (!dm_pool_grow_object(mem, DEV_LIST_DELIM, sizeof(DEV_LIST_DELIM) - 1))
+							goto_bad;
 					}
 					if (!dm_pool_grow_object(mem, dev_name(dev), 0))
 						goto bad;
@@ -4638,7 +4642,8 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 	}
 
 	if (found_inconsistent) {
-		dm_pool_grow_object(mem, "\0", 1);
+		if (!dm_pool_grow_object(mem, "\0", 1))
+			goto_bad;
 		assumed_devnames = dm_pool_end_object(mem);
 	}
 


