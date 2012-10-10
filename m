From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Oct 2012 15:18:20 +0000 (UTC)
Subject: master - libdm: add dm_task_get_uuid_mangled/unmangled
Message-ID: <20121010151820.5A96A2432@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=12f5c3f726823d13be561645935d0f77c1334e95
Commit:        12f5c3f726823d13be561645935d0f77c1334e95
Parent:        b0f48b9533b9fd13aaf0ad1bca4cbf68330e60b8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 10 16:59:47 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 10 16:59:47 2012 +0200

libdm: add dm_task_get_uuid_mangled/unmangled

Just like we already have existing mangling support for
device-mapper names, we need exactly the same for device-mapper
UUIDs as their character whitelist is wider than what udev supports.

In case udev is used to create entries in /dev based on UUIDs
and these UUIDs contain characters not supported by udev,
we'll end up with incorrect /dev content for such devices.
So we need to mangle them to a form that is supported by udev.

The mangling used for UUIDs follows the mangling used for names
(that is already supported and used throughout). That means,
setting the name mangling mode via dm_set_name_mangling_mode
affects mangling used for UUIDs in exactly the same manner.
It would be useless to add a new and separate
dm_set_uuid_mangling_mode fn, we'll reuse existing interface.
---
 libdm/ioctl/libdm-iface.c |    5 ---
 libdm/libdevmapper.h      |   18 ++++++++--
 libdm/libdm-common.c      |   87 ++++++++++++++++++++++++++++++++++++---------
 3 files changed, 85 insertions(+), 25 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 526ec3f..3166c06 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -681,11 +681,6 @@ uint32_t dm_task_get_read_ahead(const struct dm_task *dmt, uint32_t *read_ahead)
 				       MINOR(dmt->dmi.v4->dev), read_ahead);
 }
 
-const char *dm_task_get_uuid(const struct dm_task *dmt)
-{
-	return (dmt->dmi.v4->uuid);
-}
-
 struct dm_deps *dm_task_get_deps(struct dm_task *dmt)
 {
 	return (struct dm_deps *) (((char *) dmt->dmi.v4) +
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 6d24102..70862f3 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -164,6 +164,16 @@ struct dm_versions {
 int dm_get_library_version(char *version, size_t size);
 int dm_task_get_driver_version(struct dm_task *dmt, char *version, size_t size);
 int dm_task_get_info(struct dm_task *dmt, struct dm_info *dmi);
+
+/*
+ * This function returns dm device's UUID based on the value
+ * of the mangling mode set during preceding dm_task_run call:
+ *   - unmangled name for DM_STRING_MANGLING_{AUTO, HEX},
+ *   - name without any changes for DM_STRING_MANGLING_NONE.
+ *
+ * To get mangled or unmangled form of the name directly, use
+ * dm_task_get_uuid_mangled or dm_task_get_uuid_unmangled function.
+ */
 const char *dm_task_get_uuid(const struct dm_task *dmt);
 
 struct dm_deps *dm_task_get_deps(struct dm_task *dmt);
@@ -297,18 +307,20 @@ typedef enum {
 } dm_string_mangling_t;
 
 /*
- * Set/get mangling mode used for device-mapper names.
+ * Set/get mangling mode used for device-mapper names and uuids.
  */
 int dm_set_name_mangling_mode(dm_string_mangling_t name_mangling);
 dm_string_mangling_t dm_get_name_mangling_mode(void);
 
 /*
- * Get mangled/unmangled form of the device-mapper name
+ * Get mangled/unmangled form of the device-mapper name or uuid
  * irrespective of the global setting (set by dm_set_name_mangling_mode).
- * The name returned needs to be freed after use by calling dm_free!
+ * The name or uuid returned needs to be freed after use by calling dm_free!
  */
 char *dm_task_get_name_mangled(const struct dm_task *dmt);
 char *dm_task_get_name_unmangled(const struct dm_task *dmt);
+char *dm_task_get_uuid_mangled(const struct dm_task *dmt);
+char *dm_task_get_uuid_unmangled(const struct dm_task *dmt);
 
 /*
  * Configure the device-mapper directory
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 982fd3e..b990ded 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -582,18 +582,51 @@ const char *dm_task_get_name(const struct dm_task *dmt)
 	return (dmt->dmi.v4->name);
 }
 
+static char *_task_get_string_mangled(const char *str, const char *str_name,
+				      char *buf, size_t buf_size,
+				      dm_string_mangling_t mode)
+{
+	char *rs;
+	int r;
+
+	if ((r = mangle_string(str, str_name, strlen(str), buf, buf_size, mode)) < 0)
+		return NULL;
+
+	if (!(rs = r ? dm_strdup(buf) : dm_strdup(str)))
+		log_error("_task_get_string_mangled: dm_strdup failed");
+
+	return rs;
+}
+
+static char *_task_get_string_unmangled(const char *str, const char *str_name,
+					char *buf, size_t buf_size,
+					dm_string_mangling_t mode)
+{
+	char *rs;
+	int r = 0;
+
+	/*
+	 * Unless the mode used is 'none', the string
+	 * is *already* unmangled on ioctl return!
+	 */
+	if (mode == DM_STRING_MANGLING_NONE &&
+	    (r = unmangle_string(str, str_name, strlen(str), buf, buf_size, mode)) < 0)
+		return NULL;
+
+	if (!(rs = r ? dm_strdup(buf) : dm_strdup(str)))
+		log_error("_task_get_string_unmangled: dm_strdup failed");
+
+	return rs;
+}
+
 char *dm_task_get_name_mangled(const struct dm_task *dmt)
 {
 	const char *s = dm_task_get_name(dmt);
 	char buf[DM_NAME_LEN];
-	char *rs = NULL;
-	int r;
+	char *rs;
 
-	if ((r = mangle_string(s, "name", strlen(s), buf, sizeof(buf),
-			       dm_get_name_mangling_mode())) < 0)
+	if (!(rs = _task_get_string_mangled(s, "name", buf, sizeof(buf), dm_get_name_mangling_mode())))
 		log_error("Failed to mangle device name \"%s\".", s);
-	else if (!(rs = r ? dm_strdup(buf) : dm_strdup(s)))
-		log_error("dm_task_get_name_mangled: dm_strdup failed");
 
 	return rs;
 }
@@ -602,19 +635,39 @@ char *dm_task_get_name_unmangled(const struct dm_task *dmt)
 {
 	const char *s = dm_task_get_name(dmt);
 	char buf[DM_NAME_LEN];
-	char *rs = NULL;
-	int r = 0;
+	char *rs;
 
-	/*
-	 * Unless the mode used is 'none', the name
-	 * is *already* unmangled on ioctl return!
-	 */
-	if (dm_get_name_mangling_mode() == DM_STRING_MANGLING_NONE &&
-	    (r = unmangle_string(s, "name", strlen(s), buf, sizeof(buf),
-				 dm_get_name_mangling_mode())) < 0)
+	if (!(rs = _task_get_string_unmangled(s, "name", buf, sizeof(buf), dm_get_name_mangling_mode())))
 		log_error("Failed to unmangle device name \"%s\".", s);
-	else if (!(rs = r ? dm_strdup(buf) : dm_strdup(s)))
-		log_error("dm_task_get_name_unmangled: dm_strdup failed");
+
+	return rs;
+}
+
+const char *dm_task_get_uuid(const struct dm_task *dmt)
+{
+	return (dmt->dmi.v4->uuid);
+}
+
+char *dm_task_get_uuid_mangled(const struct dm_task *dmt)
+{
+	const char *s = dm_task_get_uuid(dmt);
+	char buf[DM_UUID_LEN];
+	char *rs;
+
+	if (!(rs = _task_get_string_mangled(s, "UUID", buf, sizeof(buf), dm_get_name_mangling_mode())))
+		log_error("Failed to mangle device uuid \"%s\".", s);
+
+	return rs;
+}
+
+char *dm_task_get_uuid_unmangled(const struct dm_task *dmt)
+{
+	const char *s = dm_task_get_uuid(dmt);
+	char buf[DM_UUID_LEN];
+	char *rs;
+
+	if (!(rs = _task_get_string_unmangled(s, "UUID", buf, sizeof(buf), dm_get_name_mangling_mode())))
+		log_error("Failed to unmangle device uuid \"%s\".", s);
 
 	return rs;
 }


