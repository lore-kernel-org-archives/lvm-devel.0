From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:47 +0000 (GMT)
Subject: main - cov: avoid using strcpy
Message-ID: <20230216231047.585C03858C31@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7bc5c8ac3d4c6004de24050fd51d3eaa4732822d
Commit:        7bc5c8ac3d4c6004de24050fd51d3eaa4732822d
Parent:        fb930c2165c2b62daf2adc9d97d59f129132e5c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 14 20:59:56 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:00:04 2023 +0100

cov: avoid using strcpy

Coverity is complaining about unchecked strcpy here, which is
irelevant as we preallocate buffer to fit in copied string,
however we could actually reuse these size and use just memcpy().
So lets make some simple conversions.
---
 device_mapper/ioctl/libdm-iface.c | 41 ++++++++++++++++++++++++---------------
 lib/activate/fs.c                 |  5 +++--
 lib/commands/toolcontext.c        |  8 +++-----
 lib/format_text/format-text.c     |  7 ++++---
 4 files changed, 35 insertions(+), 26 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index ffcbc8a48..0cc81b9d9 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -843,8 +843,8 @@ int dm_task_get_device_list(struct dm_task *dmt, struct dm_list **devs_list,
 		dm_dev->event_nr = 0;
 		dm_dev->uuid = NULL;
 
-		strcpy(dm_dev->name, names->name);
 		len = strlen(names->name) + 1;
+		memcpy(dm_dev->name, names->name, len);
 
 		dm_new_dev = _align_ptr((char*)(dm_dev + 1) + len);
 		if (_check_has_event_nr()) {
@@ -862,8 +862,9 @@ int dm_task_get_device_list(struct dm_task *dmt, struct dm_list **devs_list,
 				*devs_features |= DM_DEVICE_LIST_HAS_UUID;
 				uuid_ptr = _align_ptr(event_nr + 2);
 				dm_dev->uuid = (char*) dm_new_dev;
-				dm_new_dev = _align_ptr((char*)dm_new_dev + strlen(uuid_ptr) + 1);
-				strcpy(dm_dev->uuid, uuid_ptr);
+				len = strlen(uuid_ptr) + 1;
+				dm_new_dev = _align_ptr((char*)dm_new_dev + len);
+				memcpy(dm_dev->uuid, uuid_ptr, len);
 				if (!dm_hash_insert(devs->uuids, dm_dev->uuid, dm_dev))
 					return_0; // FIXME
 #if 0
@@ -1201,9 +1202,10 @@ static char *_add_target(struct target *t, char *out, char *end)
 	while (*pt)
 		if (*pt++ == '\\')
 			backslash_count++;
-	len = strlen(t->params) + backslash_count;
 
-	if ((out >= end) || (out + len + 1) >= end) {
+	len = strlen(t->params) + 1;
+
+	if ((out >= end) || (out + len + backslash_count) >= end) {
 		log_error("Ran out of memory building ioctl parameter");
 		return NULL;
 	}
@@ -1219,8 +1221,8 @@ static char *_add_target(struct target *t, char *out, char *end)
 		*out++ = '\0';
 	}
 	else {
-		strcpy(out, t->params);
-		out += len + 1;
+		memcpy(out, t->params, len);
+		out += len + backslash_count;
 	}
 
 	/* align next block */
@@ -1291,6 +1293,7 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 	struct target *t;
 	struct dm_target_msg *tmsg;
 	size_t len = sizeof(struct dm_ioctl);
+	size_t message_len = 0, newname_len = 0, geometry_len = 0;
 	char *b, *e;
 	int count = 0;
 
@@ -1351,14 +1354,20 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 		return NULL;
 	}
 
-	if (dmt->newname)
-		len += strlen(dmt->newname) + 1;
+	if (dmt->newname) {
+		newname_len = strlen(dmt->newname) + 1;
+		len += newname_len;
+	}
 
-	if (dmt->message)
-		len += sizeof(struct dm_target_msg) + strlen(dmt->message) + 1;
+	if (dmt->message) {
+		message_len = strlen(dmt->message) + 1;
+		len += sizeof(struct dm_target_msg) + message_len;
+	}
 
-	if (dmt->geometry)
-		len += strlen(dmt->geometry) + 1;
+	if (dmt->geometry) {
+		geometry_len = strlen(dmt->geometry) + 1;
+		len += geometry_len;
+	}
 
 	/*
 	 * Give len a minimum size so that we have space to store
@@ -1480,16 +1489,16 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 				goto_bad;
 
 	if (dmt->newname)
-		strcpy(b, dmt->newname);
+		memcpy(b, dmt->newname, newname_len);
 
 	if (dmt->message) {
 		tmsg = (struct dm_target_msg *) b;
 		tmsg->sector = dmt->sector;
-		strcpy(tmsg->message, dmt->message);
+		memcpy(tmsg->message, dmt->message, message_len);
 	}
 
 	if (dmt->geometry)
-		strcpy(b, dmt->geometry);
+		memcpy(b, dmt->geometry, geometry_len);
 
 	return dmi;
 
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index 3e0692c9d..c8b304f9d 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -318,9 +318,10 @@ struct fs_op_parms {
 
 static void _store_str(char **pos, char **ptr, const char *str)
 {
-	strcpy(*pos, str);
+	size_t len = strlen(str) + 1;
+	memcpy(*pos, str, len);
 	*ptr = *pos;
-	*pos += strlen(*ptr) + 1;
+	*pos += len;
 }
 
 static void _del_fs_op(struct fs_op_parms *fsp)
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index b630554a9..4e05f9078 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1581,7 +1581,7 @@ struct cmd_context *create_config_context(void)
 	if (!(cmd = zalloc(sizeof(*cmd))))
 		goto_out;
 
-	strcpy(cmd->system_dir, DEFAULT_SYS_DIR);
+	strncpy(cmd->system_dir, DEFAULT_SYS_DIR, sizeof(cmd->system_dir) - 1);
 
 	if (!_get_env_vars(cmd))
 		goto_out;
@@ -1713,10 +1713,8 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 	/*
 	 * Environment variable LVM_SYSTEM_DIR overrides this below.
 	 */
-        if (system_dir)
-		strncpy(cmd->system_dir, system_dir, sizeof(cmd->system_dir) - 1);
-	else
-		strcpy(cmd->system_dir, DEFAULT_SYS_DIR);
+	strncpy(cmd->system_dir, (system_dir) ? system_dir : DEFAULT_SYS_DIR,
+		sizeof(cmd->system_dir) - 1);
 
 	if (!_get_env_vars(cmd))
 		goto_out;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c1ccdb031..3d4eac27b 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1389,7 +1389,7 @@ static int _vg_commit_file(struct format_instance *fid, struct volume_group *vg,
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 	const char *slash;
 	char new_name[PATH_MAX];
-	size_t len;
+	size_t len, vglen;
 
 	if (!_vg_commit_file_backup(fid, vg, mda))
 		return 0;
@@ -1401,14 +1401,15 @@ static int _vg_commit_file(struct format_instance *fid, struct volume_group *vg,
 		slash = tc->path_live;
 
 	if (strcmp(slash, vg->name)) {
+		vglen = strlen(vg->name) + 1;
 		len = slash - tc->path_live;
-		if ((len + strlen(vg->name)) > (sizeof(new_name) - 1)) {
+		if ((len + vglen) > (sizeof(new_name) - 1)) {
 			log_error("Renaming path %s is too long for VG %s.",
 				  tc->path_live, vg->name);
 			return 0;
 		}
 		strncpy(new_name, tc->path_live, len);
-		strcpy(new_name + len, vg->name);
+		memcpy(new_name + len, vg->name, vglen);
 		log_debug_metadata("Renaming %s to %s", tc->path_live, new_name);
 		if (test_mode())
 			log_verbose("Test mode: Skipping rename");

