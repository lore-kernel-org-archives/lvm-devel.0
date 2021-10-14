From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 21:37:14 +0000 (GMT)
Subject: main - debug: reduce some debugging noise
Message-ID: <20211014213714.3A2623858427@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8784211958ee0ea663171e186bd5217b1c7b52c7
Commit:        8784211958ee0ea663171e186bd5217b1c7b52c7
Parent:        ae92888a7baf3f1882168a6084eca23c9b85b998
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 14 18:16:49 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 14 23:34:11 2021 +0200

debug: reduce some debugging noise

Resolve event_activation configure option just once.

Do not print debug_devs about 'bad' filtering, when
actually filter already printed reason for skipping

Do not trace more then once about backup being disabled.

No debug when unlinked file does not exists in pvscan.
---
 lib/commands/toolcontext.c      | 1 +
 lib/commands/toolcontext.h      | 2 ++
 lib/filters/filter-persistent.c | 3 ++-
 lib/format_text/archiver.c      | 5 ++++-
 tools/pvscan.c                  | 8 ++++----
 tools/toollib.c                 | 2 +-
 6 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 5144a9a6e..ab574fb55 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -765,6 +765,7 @@ static int _process_config(struct cmd_context *cmd)
 	init_pv_min_size((uint64_t)pv_min_kb * (1024 >> SECTOR_SHIFT));
 
 	cmd->check_pv_dev_sizes = find_config_tree_bool(cmd, metadata_check_pv_device_sizes_CFG, NULL);
+	cmd->event_activation = find_config_tree_bool(cmd, global_event_activation_CFG, NULL);
 
 	if (!process_profilable_config(cmd))
 		return_0;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 7ccee4571..701b7a739 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -199,6 +199,8 @@ struct cmd_context {
 	unsigned check_devs_used:1;		/* check devs used by LVs */
 	unsigned print_device_id_not_found:1;	/* print devices file entries not found */
 	unsigned ignore_device_name_mismatch:1; /* skip updating devices file names */
+	unsigned backup_disabled:1;		/* skip repeated debug message */
+	unsigned event_activation:1;		/* whether event_activation is set */
 
 	/*
 	 * Devices and filtering.
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 3f7007e4d..494a38ece 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -137,7 +137,8 @@ static int _lookup_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 			l = PF_GOOD_DEVICE;
 		}
 
-		log_debug_devs("filter caching %s %s", pass ? "good" : "bad", dev_name(dev));
+		if (!dev->filtered_flags) /* skipping reason already logged by filter */
+			log_debug_devs("filter caching %s %s", pass ? "good" : "bad", dev_name(dev));
 
 		dm_list_iterate_items(sl, &dev->aliases)
 			if (!dm_hash_insert(pf->devices, sl->str, l)) {
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 87e4edc40..165c029aa 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -626,7 +626,10 @@ void check_current_backup(struct volume_group *vg)
 	int old_suppress;
 
 	if (!vg->cmd->backup_params->enabled || !vg->cmd->backup_params->dir) {
-		log_debug("Skipping check for current backup, since backup is disabled.");
+		if (!vg->cmd->backup_disabled) {
+			log_debug("Skipping check for current backup, since backup is disabled.");
+			vg->cmd->backup_disabled = 1;
+		}
 		return;
 	}
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 75a08d325..6ea7a77e5 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -271,7 +271,7 @@ static void _lookup_file_remove(char *vgname)
 
 	log_debug("Unlink pvs_lookup: %s", path);
 
-	if (unlink(path))
+	if (unlink(path) && (errno != ENOENT))
 		log_sys_debug("unlink", path);
 }
 
@@ -292,7 +292,7 @@ void online_vg_file_remove(const char *vgname)
 
 	log_debug("Unlink vg online: %s", path);
 
-	if (unlink(path))
+	if (unlink(path) && (errno != ENOENT))
 		log_sys_debug("unlink", path);
 }
 
@@ -332,7 +332,7 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 
 		if ((file_major == major) && (file_minor == minor)) {
 			log_debug("Unlink pv online %s", path);
-			if (unlink(path))
+			if (unlink(path) && (errno != ENOENT))
 				log_sys_debug("unlink", path);
 
 			if (file_vgname[0]) {
@@ -360,7 +360,7 @@ static void _online_files_remove(const char *dirpath)
 
 		memset(path, 0, sizeof(path));
 		snprintf(path, sizeof(path), "%s/%s", dirpath, de->d_name);
-		if (unlink(path))
+		if (unlink(path) && (errno != ENOENT))
 			log_sys_debug("unlink", path);
 	}
 	if (closedir(dir))
diff --git a/tools/toollib.c b/tools/toollib.c
index 5b67669e1..d6f48aad2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -828,7 +828,7 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 	 * user may want to take charge of activation changes to the VG
 	 * and not have the system autoactivation interfere.
 	 */
-	if (!is_change_activating(activate) && find_config_tree_bool(cmd, global_event_activation_CFG, NULL))
+	if (!is_change_activating(activate) && cmd->event_activation)
 		online_vg_file_remove(lv->vg->name);
 
 	set_lv_notify(lv->vg->cmd);


