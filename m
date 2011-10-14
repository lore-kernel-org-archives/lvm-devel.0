From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 14 Oct 2011 16:59:20 +0200
Subject: [PATCH 3/6][devname mangling] Add core devname mangling support
Message-ID: <4E984E48.60206@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds new libdevmapper functions to support name mangling:

  (set/get mangling for the dm_task separately)
  int dm_task_set_name_mangle(struct dm_task *dmt, dm_string_mangle_t name_mangle)
  dm_string_mangle_t dm_task_get_name_mangle(struct dm_task *dmt)

  (set/get default name mangling globally)
  int dm_set_default_name_mangle(dm_string_mangle_t name_mangle);
  dm_string_mangle_t dm_get_default_name_mangle(void);

Normally, a value defined with "--with-default-name-mangle" during
configure will be used by default. However, if we'd like to override
it in runtime, we can do that by calling dm_set_default_name_mangle.

When calling dm_task_create, this default value is assigned for all
newly created dm tasks.

However, it's sometimes handy to set the mangling for each task separately,
e.g. to switch the name mangling off to prevent double mangle of
already mangled string - like we need to do when we're decoupling a higher
level task into its constituents (e.g. "create" dm_task with table supplied,
decoupled into "create", "load" and "resume" and others).

While calling the dm_task_set_name fn, the name supplied will be mangled
automatically according to the setting stored in dm_task's "name_mangle" field.

As for the mangling, supported whitelist is set to be in sync with udev,
that is:

 0-9
 A-Z
 a-z
 # + - . : = @ _

Peter
---
 libdm/ioctl/libdm-iface.c   |   24 ++++++++
 libdm/ioctl/libdm-targets.h |    1 +
 libdm/libdevmapper.h        |    8 +++
 libdm/libdm-common.c        |  131 +++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 159 insertions(+), 5 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 93cd770..a4a0130 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -814,6 +814,18 @@ int dm_task_retry_remove(struct dm_task *dmt)
 	return 1;
 }
 
+int dm_task_set_name_mangle(struct dm_task *dmt, dm_string_mangle_t name_mangle)
+{
+	dmt->name_mangle = name_mangle;
+
+	return 1;
+}
+
+dm_string_mangle_t dm_task_get_name_mangle(struct dm_task *dmt)
+{
+	return dmt->name_mangle;
+}
+
 int dm_task_query_inactive_table(struct dm_task *dmt)
 {
 	dmt->query_inactive_table = 1;
@@ -1236,6 +1248,9 @@ static int _create_and_load_v4(struct dm_task *dmt)
 		return 0;
 	}
 
+	/* Prevent the name to be mangled twice. */
+	dm_task_set_name_mangle(task, DM_STRING_MANGLE_NONE);
+
 	/* Copy across relevant fields */
 	if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name)) {
 		dm_task_destroy(task);
@@ -1274,6 +1289,9 @@ static int _create_and_load_v4(struct dm_task *dmt)
 		goto revert;
 	}
 
+	/* Prevent the name to be mangled twice. */
+	dm_task_set_name_mangle(task, DM_STRING_MANGLE_NONE);
+
 	/* Copy across relevant fields */
 	if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name)) {
 		dm_task_destroy(task);
@@ -1349,6 +1367,9 @@ static int _reload_with_suppression_v4(struct dm_task *dmt)
 		return 0;
 	}
 
+	/* Prevent the name to be mangled twice. */
+	dm_task_set_name_mangle(task, DM_STRING_MANGLE_NONE);
+
 	/* Copy across relevant fields */
 	if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name)) {
 		dm_task_destroy(task);
@@ -1429,6 +1450,9 @@ static int _check_children_not_suspended_v4(struct dm_task *dmt, uint64_t device
 		task->major = MAJOR(device);
 		task->minor = MINOR(device);
 	} else {
+		/* Prevent the name to be mangled twice. */
+		dm_task_set_name_mangle(task, DM_STRING_MANGLE_NONE);
+
 		if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name))
 			goto out;
 
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index ca08fe8..f13da85 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -64,6 +64,7 @@ struct dm_task {
 	int new_uuid;
 	int secure_data;
 	int retry_remove;
+	dm_string_mangle_t name_mangle;
 	int enable_checks;
 
 	char *uuid;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0598179..89ccf4c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -262,6 +262,14 @@ typedef enum {
 	DM_STRING_MANGLE_HEX	/* always mangle with hex encoding, no matter what the input is */
 } dm_string_mangle_t;
 
+/* Set/get default name mangle type assigned for each newly created dm_task. */
+int dm_set_default_name_mangle(dm_string_mangle_t name_mangle);
+dm_string_mangle_t dm_get_default_name_mangle(void);
+
+/* Set/get name mangle type for a specific dm_task individually. */
+int dm_task_set_name_mangle(struct dm_task *dmt, dm_string_mangle_t name_mangle);
+dm_string_mangle_t dm_task_get_name_mangle(struct dm_task *dmt);
+
 /*
  * Configure the device-mapper directory
  */
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 1237c21..86db846 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -62,6 +62,7 @@ static char _sysfs_dir[PATH_MAX] = "/sys/";
 
 static int _verbose = 0;
 static int _suspended_dev_counter = 0;
+static int _default_name_mangle = DEFAULT_DM_NAME_MANGLE;
 
 #ifdef HAVE_SELINUX_LABEL_H
 static struct selabel_handle *_selabel_handle = NULL;
@@ -197,6 +198,18 @@ int dm_get_suspended_counter(void)
 	return _suspended_dev_counter;
 }
 
+int dm_set_default_name_mangle(dm_string_mangle_t name_mangle)
+{
+	_default_name_mangle = name_mangle;
+
+	return 1;
+}
+
+dm_string_mangle_t dm_get_default_name_mangle(void)
+{
+	return _default_name_mangle;
+}
+
 struct dm_task *dm_task_create(int type)
 {
 	struct dm_task *dmt = dm_zalloc(sizeof(*dmt));
@@ -227,6 +240,7 @@ struct dm_task *dm_task_create(int type)
 	dmt->query_inactive_table = 0;
 	dmt->new_uuid = 0;
 	dmt->secure_data = 0;
+	dmt->name_mangle = _default_name_mangle;
 
 	return dmt;
 }
@@ -277,11 +291,102 @@ static char *_find_dm_name_of_device(dev_t st_rdev)
 	return new_name;
 }
 
+static int _is_whitelisted_char(char c)
+{
+	/*
+	 * Actually, DM supports any character in a device name.
+	 * This whitelist is just for proper integration with udev.
+	 */
+        if ((c >= '0' && c <= '9') ||
+            (c >= 'A' && c <= 'Z') ||
+            (c >= 'a' && c <= 'z') ||
+            strchr("#+-.:=@_", c) != NULL)
+                return 1;
+
+        return 0;
+}
+
+/*
+ * Encode all characters in the input string which are not on a whitelist
+ * with '\xNN' format where NN is the hex value of the character.
+ */
+static int _mangle_dev_name(const char *str, size_t len, char *str_enc, size_t len_enc,
+			    dm_string_mangle_t name_mangle)
+{
+	size_t i, j;
+	int mangled = 0; /* 0 don't know yet, 1 mangled, -1 not mangled */
+
+	if (!str || !str_enc)
+		return 0;
+
+	/* Is there anything to mangle@all? */
+	if (!*str || name_mangle == DM_STRING_MANGLE_NONE) {
+		strcpy(str_enc, str);
+		return 1;
+	}
+
+	for (i = 0, j = 0; str[i]; i++) {
+		if (name_mangle == DM_STRING_MANGLE_AUTO) {
+			/*
+			 * Detect already mangled part of the string and keep it.
+			 * Return error on mixture of mangled/not mangled!
+			 */
+			if (str[i] == '\\' && str[i+1] == 'x') {
+				if ((len - i < 4) || (mangled == -1))
+					goto bad1;
+				if (len_enc - j < 4)
+					goto bad2;
+				memcpy(&str_enc[j], &str[i], 4);
+				mangled = 1;
+				i+=3; j+=4;
+				continue;
+			}
+		}
+
+		if (_is_whitelisted_char(str[i])) {
+			/* whitelisted, keep it. */
+			if (len_enc - j < 1)
+				goto bad2;
+			str_enc[j] = str[i];
+			j++;
+		} else {
+			/*
+			 * Not on a whitelist, mangle it.
+			 * Return error on mixture of mangled/not mangled
+			 * unless a DM_STRING_MANGLE_HEX is used!.
+			 */
+			if ((name_mangle != DM_STRING_MANGLE_HEX) && (mangled == 1))
+				goto bad1;
+			if (len_enc - j < 4)
+				goto bad2;
+			sprintf(&str_enc[j], "\\x%02x", (unsigned char) str[i]);
+			j+=4;
+			mangled = -1;
+		}
+	}
+
+	if (len_enc - j < 1)
+		goto bad2;
+	str_enc[j] = '\0';
+
+	log_debug("Name mangled [%d]: \"%s\" --> \"%s\"", name_mangle, str, str_enc);
+
+	return 1;
+
+bad1:
+	log_error("Improper device name \"%s\"", str);
+	return 0;
+bad2:
+	log_error("Encoded name too long for device name \"%s\"", str);
+	return 0;
+}
+
 int dm_task_set_name(struct dm_task *dmt, const char *name)
 {
 	char *pos;
 	char *new_name = NULL;
 	char path[PATH_MAX];
+	char mangled_name[DM_NAME_LEN];
 	struct stat st1, st2;
 
 	dm_free(dmt->dev_name);
@@ -330,9 +435,17 @@ int dm_task_set_name(struct dm_task *dmt, const char *name)
 
 	if (new_name)
 		dmt->dev_name = new_name;
-	else if (!(dmt->dev_name = dm_strdup(name))) {
-		log_error("dm_task_set_name: strdup(%s) failed", name);
-		return 0;
+	else {
+		if (!_mangle_dev_name(name, strlen(name), mangled_name, sizeof(mangled_name),
+				      dmt->name_mangle)) {
+			log_error("Failed to encode device name \"%s\"", name);
+			return 0;
+		}
+
+		if (!(dmt->dev_name = dm_strdup(mangled_name))) {
+			log_error("dm_task_set_name: strdup(%s) failed", mangled_name);
+			return 0;
+		}
 	}
 
 	return 1;
@@ -340,6 +453,8 @@ int dm_task_set_name(struct dm_task *dmt, const char *name)
 
 int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 {
+	char mangled_name[DM_NAME_LEN];
+
 	if (strchr(newname, '/')) {
 		log_error("Name \"%s\" invalid. It contains \"/\".", newname);
 		return 0;
@@ -350,8 +465,14 @@ int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 		return 0;
 	}
 
-	if (!(dmt->newname = dm_strdup(newname))) {
-		log_error("dm_task_set_newname: strdup(%s) failed", newname);
+	if (!_mangle_dev_name(newname, strlen(newname), mangled_name, sizeof(mangled_name),
+			      dmt->name_mangle)) {
+		log_error("Failed to encode new device name \"%s\"", newname);
+		return 0;
+	}
+
+	if (!(dmt->newname = dm_strdup(mangled_name))) {
+		log_error("dm_task_set_newname: strdup(%s) failed", mangled_name);
 		return 0;
 	}
 	dmt->new_uuid = 0;


