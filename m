From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 07 Oct 2011 15:43:27 +0200
Subject: [PATCH] Add support for escaping device-mapper names (to be in sync with udev whitelist)
Message-ID: <4E8F01FF.5050602@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch restrict device names used in device-mapper to comply
with udev whitelist. If not whitelisted, we use an escape mechanism
that udev accepts - that is \xNN where NN is a hex value of the
character.

(Related rhbz #736486, #740575)

Peter
---
 libdm/ioctl/libdm-iface.c   |    7 ++++
 libdm/ioctl/libdm-targets.h |    1 +
 libdm/libdevmapper.h        |    1 +
 libdm/libdm-common.c        |   67 +++++++++++++++++++++++++++++++++++++++++--
 tools/dmsetup.c             |   11 ++++++-
 5 files changed, 82 insertions(+), 5 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index aab6305..4565266 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -835,6 +835,13 @@ int dm_task_retry_remove(struct dm_task *dmt)
 	return 1;
 }
 
+int dm_task_name_escape(struct dm_task *dmt)
+{
+	dmt->name_escape = 1;
+
+	return 1;
+}
+
 int dm_task_query_inactive_table(struct dm_task *dmt)
 {
 	dmt->query_inactive_table = 1;
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index ca08fe8..46c5e88 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -64,6 +64,7 @@ struct dm_task {
 	int new_uuid;
 	int secure_data;
 	int retry_remove;
+	int name_escape;
 	int enable_checks;
 
 	char *uuid;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index fdf8943..ae2803e 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -192,6 +192,7 @@ int dm_task_query_inactive_table(struct dm_task *dmt);
 int dm_task_suppress_identical_reload(struct dm_task *dmt);
 int dm_task_secure_data(struct dm_task *dmt);
 int dm_task_retry_remove(struct dm_task *dmt);
+int dm_task_name_escape(struct dm_task *dmt);
 
 /*
  * Enable checks for common mistakes such as issuing ioctls in an unsafe order.
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 23539d7..22a3d32 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -277,11 +277,62 @@ static char *_find_dm_name_of_device(dev_t st_rdev)
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
+static int _escape_dev_name(const char *str, char *str_enc, size_t len)
+{
+	size_t i, j;
+
+	if (str == NULL || str_enc == NULL)
+		return 0;
+
+	for (i = 0, j = 0; str[i] != '\0'; i++) {
+		if (str[i] == '\\' || !_is_whitelisted_char(str[i])) {
+			if (len - j < 4)
+				goto error;
+			sprintf(&str_enc[j], "\\x%02x", (unsigned char) str[i]);
+			j+=4;
+		} else {
+			if (len - j < 1)
+				goto error;
+			str_enc[j] = str[i];
+			j++;
+		}
+	}
+
+	if (len - j < 1)
+		goto error;
+	str_enc[j] = '\0';
+
+	return 1;
+error:
+	log_error("Escaped name too long for device name %s", str);
+	return 0;
+}
+
 int dm_task_set_name(struct dm_task *dmt, const char *name)
 {
 	char *pos;
 	char *new_name = NULL;
 	char path[PATH_MAX];
+	char esc_name[DM_NAME_LEN];
 	struct stat st1, st2;
 
 	dm_free(dmt->dev_name);
@@ -330,9 +381,19 @@ int dm_task_set_name(struct dm_task *dmt, const char *name)
 
 	if (new_name)
 		dmt->dev_name = new_name;
-	else if (!(dmt->dev_name = dm_strdup(name))) {
-		log_error("dm_task_set_name: strdup(%s) failed", name);
-		return 0;
+	else {
+		if (dmt->name_escape) {
+			if (!_escape_dev_name(name, esc_name, sizeof(esc_name))) {
+				log_error("Failed to encode device name %s", name);
+				return 0;
+			}
+			name = esc_name;
+		}
+
+		if (!(dmt->dev_name = dm_strdup(name))) {
+			log_error("dm_task_set_name: strdup(%s) failed", name);
+			return 0;
+		}
 	}
 
 	return 1;
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f35c8a5..41637f5 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -130,6 +130,7 @@ enum {
 	MINOR_ARG,
 	MODE_ARG,
 	NAMEPREFIXES_ARG,
+	NONAMEESCAPE_ARG,
 	NOFLUSH_ARG,
 	NOHEADINGS_ARG,
 	NOLOCKFS_ARG,
@@ -608,6 +609,9 @@ static int _create(CMD_ARGS)
 	if (!(dmt = dm_task_create(DM_DEVICE_CREATE)))
 		return 0;
 
+	if (!_switches[NONAMEESCAPE_ARG])
+		dm_task_name_escape(dmt);
+
 	if (!dm_task_set_name(dmt, argv[1]))
 		goto out;
 
@@ -2806,8 +2810,8 @@ static void _usage(FILE *out)
 
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
-		"        [--checks] [-v|--verbose [-v|--verbose ...]]\n"
-		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
+		"        [--checks] [-v|--verbose [-v|--verbose ...]] [-r|--readonly]\n"
+		"        [--nonameescape] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
@@ -3172,6 +3176,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"minor", 1, &ind, MINOR_ARG},
 		{"mode", 1, &ind, MODE_ARG},
 		{"nameprefixes", 0, &ind, NAMEPREFIXES_ARG},
+		{"nonameescape", 0, &ind, NONAMEESCAPE_ARG},
 		{"noflush", 0, &ind, NOFLUSH_ARG},
 		{"noheadings", 0, &ind, NOHEADINGS_ARG},
 		{"nolockfs", 0, &ind, NOLOCKFS_ARG},
@@ -3339,6 +3344,8 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 			_switches[INACTIVE_ARG]++;
 		if ((ind == NAMEPREFIXES_ARG))
 			_switches[NAMEPREFIXES_ARG]++;
+		if ((ind == NONAMEESCAPE_ARG))
+			_switches[NONAMEESCAPE_ARG]++;
 		if ((ind == NOFLUSH_ARG))
 			_switches[NOFLUSH_ARG]++;
 		if ((ind == NOHEADINGS_ARG))


