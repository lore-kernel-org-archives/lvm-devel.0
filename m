From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:55 -0500
Subject: master - segtype: better get_monitor_dso_path api
Message-ID: <201802122120.w1CLKtiD023767@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=27399755fd1b1292cc93f6469162c0855b7231c2
Commit:        27399755fd1b1292cc93f6469162c0855b7231c2
Parent:        e113df129ebc4c2b4fca2a973ac6e06630e1a470
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 10 20:22:32 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:15:03 2018 +0100

segtype: better get_monitor_dso_path api

Instead of allocating always 4K for dso path, use only real needed size.
Also simplify API call and move common functionality into function
itself.
---
 lib/activate/activate.c |   14 +++++---------
 lib/activate/activate.h |    2 +-
 lib/mirror/mirrored.c   |    3 +--
 lib/raid/raid.c         |    3 +--
 lib/snapshot/snapshot.c |    3 +--
 lib/thin/thin.c         |    3 +--
 6 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b39f314..bd1dc18 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1685,18 +1685,14 @@ bad:
 	return NULL;
 }
 
-char *get_monitor_dso_path(struct cmd_context *cmd, const char *libpath)
+char *get_monitor_dso_path(struct cmd_context *cmd, int id)
 {
-	char *path;
-
-	if (!(path = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Failed to allocate dmeventd library path.");
-		return NULL;
-	}
+	const char *libpath = find_config_tree_str(cmd, id, NULL);
+	char path[PATH_MAX];
 
-	get_shared_library_path(cmd, libpath, path, PATH_MAX);
+	get_shared_library_path(cmd, libpath, path, sizeof(path));
 
-	return path;
+	return dm_pool_strdup(cmd->mem, path);
 }
 
 static char *_build_target_uuid(struct cmd_context *cmd, const struct logical_volume *lv)
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index b1cc176..8d06867 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -206,7 +206,7 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
-char *get_monitor_dso_path(struct cmd_context *cmd, const char *libpath);
+char *get_monitor_dso_path(struct cmd_context *cmd, int id);
 int target_registered_with_dmeventd(struct cmd_context *cmd, const char *dso,
 				    const struct logical_volume *lv, int *pending, int *monitored);
 int target_register_events(struct cmd_context *cmd, const char *dso, const struct logical_volume *lv,
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 16a5852..2d9c3de 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -572,8 +572,7 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-	segtype->dso = get_monitor_dso_path(cmd,
-		find_config_tree_str(cmd, dmeventd_mirror_library_CFG, NULL));
+	segtype->dso = get_monitor_dso_path(cmd, dmeventd_mirror_library_CFG);
 
 	if (segtype->dso)
 		segtype->flags |= SEG_MONITORED;
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index eb75c1b..e835160 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -656,8 +656,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-	dso = get_monitor_dso_path(cmd,
-		find_config_tree_str(cmd, dmeventd_raid_library_CFG, NULL));
+	dso = get_monitor_dso_path(cmd, dmeventd_raid_library_CFG);
 
 	if (dso)
 		monitored = SEG_MONITORED;
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index e44a49a..1105204 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -263,8 +263,7 @@ struct segment_type *init_segtype(struct cmd_context *cmd)
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-	segtype->dso = get_monitor_dso_path(cmd,
-		find_config_tree_str(cmd, dmeventd_snapshot_library_CFG, NULL));
+	segtype->dso = get_monitor_dso_path(cmd, dmeventd_snapshot_library_CFG);
 
 	if (segtype->dso)
 		segtype->flags |= SEG_MONITORED;
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 06854ed..dad1bf2 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -816,8 +816,7 @@ int init_multiple_segtypes(struct cmd_context *cmd, struct segtype_library *segl
 
 #ifdef DEVMAPPER_SUPPORT
 #  ifdef DMEVENTD
-		segtype->dso = get_monitor_dso_path(cmd,
-			find_config_tree_str(cmd, dmeventd_thin_library_CFG, NULL));
+		segtype->dso = get_monitor_dso_path(cmd, dmeventd_thin_library_CFG);
 
 		if ((reg_segtypes[i].flags & SEG_THIN_POOL) &&
 		    segtype->dso)


