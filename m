From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 21 Mar 2014 21:31:21 +0000 (UTC)
Subject: master - lvmcache: handle reinit without error
Message-ID: <20140321213121.59BD060B41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc280bcc42556ca1c78d897839d05b3688d9d65b
Commit:        fc280bcc42556ca1c78d897839d05b3688d9d65b
Parent:        bdd7baeab39f7ef61817b2c48008852aefdbcdb0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 21 22:26:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 21 22:29:21 2014 +0100

lvmcache: handle reinit without error

Since commit f12ee43f2eaba5d38b1925a5a34b1746c1d66985 call destroy,
it start to check all VGs are unlocked. However when we become_daemon,
we simply reset locking (since lock is still kept by parent process).
So implement a simple 'reset' flag.
---
 lib/cache/lvmcache.c       |    9 ++++++---
 lib/cache/lvmcache.h       |    2 +-
 lib/commands/toolcontext.c |    4 ++--
 tools/lvmcmdline.c         |    2 +-
 tools/pvscan.c             |    2 +-
 tools/toollib.c            |    2 +-
 tools/vgrename.c           |    2 +-
 tools/vgscan.c             |    2 +-
 8 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f414aed..0c49ccf 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1621,7 +1621,7 @@ static void _lvmcache_destroy_lockname(struct dm_hash_node *n)
 			  dm_hash_get_key(_lock_hash, n));
 }
 
-void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans)
+void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 {
 	struct dm_hash_node *n;
 	log_verbose("Wiping internal VG cache");
@@ -1647,8 +1647,11 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans)
 	}
 
 	if (_lock_hash) {
-		dm_hash_iterate(n, _lock_hash)
-			_lvmcache_destroy_lockname(n);
+		if (reset)
+			_vg_global_lock_held = 0;
+		else
+			dm_hash_iterate(n, _lock_hash)
+				_lvmcache_destroy_lockname(n);
 		dm_hash_destroy(_lock_hash);
 		_lock_hash = NULL;
 	}
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index bf26664..83d561b 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -42,7 +42,7 @@ struct lvmcache_vginfo;
 int lvmcache_init(void);
 void lvmcache_allow_reads_with_lvmetad(void);
 
-void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans);
+void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset);
 
 /* Set full_scan to 1 to reread every filtered device label or
  * 2 to rescan /dev for new devices */
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 899666c..f0c0201 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1596,7 +1596,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	 */
 
 	activation_release();
-	lvmcache_destroy(cmd, 0);
+	lvmcache_destroy(cmd, 0, 0);
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
@@ -1688,7 +1688,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 
 	archive_exit(cmd);
 	backup_exit(cmd);
-	lvmcache_destroy(cmd, 0);
+	lvmcache_destroy(cmd, 0, 0);
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 454bee8..b7d69ef 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1185,7 +1185,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
       out:
 	if (test_mode()) {
 		log_verbose("Test mode: Wiping internal cache");
-		lvmcache_destroy(cmd, 1);
+		lvmcache_destroy(cmd, 1, 0);
 	}
 
 	if ((old_cft = remove_config_tree_by_source(cmd, CONFIG_STRING))) {
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 6a74ac0..9e5536e 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -363,7 +363,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 
 	if (cmd->filter->wipe)
 		cmd->filter->wipe(cmd->filter);
-	lvmcache_destroy(cmd, 1);
+	lvmcache_destroy(cmd, 1, 0);
 
 	/* populate lvmcache */
 	if (!lvmetad_vg_list_to_lvmcache(cmd))
diff --git a/tools/toollib.c b/tools/toollib.c
index 2bc0be3..6b68f55 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -91,8 +91,8 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 	strncpy(*cmd->argv, "(lvm2)", strlen(*cmd->argv));
 
 	if (!skip_lvm) {
-		lvmcache_destroy(cmd, 1);
 		reset_locking();
+		lvmcache_destroy(cmd, 1, 1);
 		if (!lvmcache_init())
 			/* FIXME Clean up properly here */
 			_exit(ECMD_FAILED);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index b5e778f..d97b871 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -185,7 +185,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	/* FIXME lvmcache corruption - vginfo duplicated instead of renamed */
 	if (cmd->filter->wipe)
 		cmd->filter->wipe(cmd->filter);
-	lvmcache_destroy(cmd, 1);
+	lvmcache_destroy(cmd, 1, 0);
 
 	return 1;
 
diff --git a/tools/vgscan.c b/tools/vgscan.c
index baf25b0..fff0e89 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -44,7 +44,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 
 	if (cmd->filter->wipe)
 		cmd->filter->wipe(cmd->filter);
-	lvmcache_destroy(cmd, 1);
+	lvmcache_destroy(cmd, 1, 0);
 
 	if (arg_count(cmd, cache_ARG)) {
 		if (lvmetad_active()) {


