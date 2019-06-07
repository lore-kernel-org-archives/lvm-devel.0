From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 11:16:02 -0400
Subject: stable-2.02 - lvmcache: remove unused_duplicate_devs list from cmd
Message-ID: <201906071516.x57FG2ff027290@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c31e6b0acad339ec3cdc0c8d7e0e01f8d816ed10
Commit:        c31e6b0acad339ec3cdc0c8d7e0e01f8d816ed10
Parent:        cb7766bc1411c3350e79241122a974dac7fcc902
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 6 14:12:19 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 6 14:12:19 2019 -0500

lvmcache: remove unused_duplicate_devs list from cmd

Save the previous duplicate PVs in a global list instead
of a list on the cmd struct.  dmeventd reuses the cmd struct
for multiple commands, and the list entries between commands
were being freed (apparently), causing a segfault in dmeventd
when it tried to use items in cmd->unused_duplicate_devs
that had been saved there by the previous command.
---
 lib/cache/lvmcache.c       |   16 +++++++++-------
 lib/commands/toolcontext.c |    2 --
 lib/commands/toolcontext.h |    1 -
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index ad40d4c..0ce5df0 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -100,6 +100,7 @@ static struct dm_hash_table *_saved_vg_hash = NULL;
 static DM_LIST_INIT(_vginfos);
 static DM_LIST_INIT(_found_duplicate_devs);
 static DM_LIST_INIT(_unused_duplicate_devs);
+static DM_LIST_INIT(_prev_unused_duplicate_devs);
 static int _scanning_in_progress = 0;
 static int _has_scanned = 0;
 static int _vgs_locked = 0;
@@ -118,6 +119,7 @@ int lvmcache_init(struct cmd_context *cmd)
 	dm_list_init(&_vginfos);
 	dm_list_init(&_found_duplicate_devs);
 	dm_list_init(&_unused_duplicate_devs);
+	dm_list_init(&_prev_unused_duplicate_devs);
 
 	if (!(_vgname_hash = dm_hash_create(128)))
 		return 0;
@@ -1152,14 +1154,14 @@ next:
 
 		if (!prev_unchosen1 && !prev_unchosen2) {
 			/*
-			 * The cmd list saves the unchosen preference across
+			 * The prev list saves the unchosen preference across
 			 * lvmcache_destroy.  Sometimes a single command will
 			 * fill lvmcache, destroy it, and refill it, and we
 			 * want the same duplicate preference to be preserved
 			 * in each instance of lvmcache for a single command.
 			 */
-			prev_unchosen1 = _dev_in_device_list(dev1, &cmd->unused_duplicate_devs);
-			prev_unchosen2 = _dev_in_device_list(dev2, &cmd->unused_duplicate_devs);
+			prev_unchosen1 = _dev_in_device_list(dev1, &_prev_unused_duplicate_devs);
+			prev_unchosen2 = _dev_in_device_list(dev2, &_prev_unused_duplicate_devs);
 		}
 
 		dev1_major = MAJOR(dev1->dev);
@@ -2575,8 +2577,8 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	dm_list_init(&_vginfos);
 
 	/*
-	 * Copy the current _unused_duplicate_devs into a cmd list before
-	 * destroying _unused_duplicate_devs.
+	 * Move the current _unused_duplicate_devs to _prev_unused_duplicate_devs
+	 * before destroying _unused_duplicate_devs.
 	 *
 	 * One command can init/populate/destroy lvmcache multiple times.  Each
 	 * time it will encounter duplicates and choose the preferrred devs.
@@ -2584,8 +2586,8 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	 * the unpreferred devs here so that _choose_preferred_devs can use
 	 * this to make the same choice each time.
 	 */
-	dm_list_init(&cmd->unused_duplicate_devs);
-	lvmcache_get_unused_duplicate_devs(cmd, &cmd->unused_duplicate_devs);
+	_destroy_duplicate_device_list(&_prev_unused_duplicate_devs);
+	dm_list_splice(&_prev_unused_duplicate_devs, &_unused_duplicate_devs);
 	_destroy_duplicate_device_list(&_unused_duplicate_devs);
 	_destroy_duplicate_device_list(&_found_duplicate_devs); /* should be empty anyway */
 	_found_duplicate_pvs = 0;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 25e8b87..38e382f 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1983,8 +1983,6 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 	if (!init_lvmcache_orphans(cmd))
 		goto_out;
 
-	dm_list_init(&cmd->unused_duplicate_devs);
-
 	if (!_init_segtypes(cmd))
 		goto_out;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 485dca9..6e262e8 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -231,7 +231,6 @@ struct cmd_context {
 	const char *report_list_item_separator;
 	const char *time_format;
 	unsigned rand_seed;
-	struct dm_list unused_duplicate_devs; /* save preferences between lvmcache instances */
 };
 
 /*


