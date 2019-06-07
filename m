From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 11:14:55 -0400
Subject: master - lvmcache: remove unused_duplicate_devs list from cmd
Message-ID: <201906071514.x57FEtdU027228@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2bcd43c683eec3a07d4b7833445856c9aad9963c
Commit:        2bcd43c683eec3a07d4b7833445856c9aad9963c
Parent:        c315112a3b7d01e56cbd2ecb3d05f55d44a50e12
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 7 10:12:52 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 10:14:33 2019 -0500

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
index a4037a5..8a29bf4 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -66,6 +66,7 @@ static struct dm_hash_table *_vgname_hash = NULL;
 static DM_LIST_INIT(_vginfos);
 static DM_LIST_INIT(_found_duplicate_devs);
 static DM_LIST_INIT(_unused_duplicate_devs);
+static DM_LIST_INIT(_prev_unused_duplicate_devs);
 static int _vgs_locked = 0;
 static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
 static int _found_duplicate_vgnames = 0;
@@ -81,6 +82,7 @@ int lvmcache_init(struct cmd_context *cmd)
 	dm_list_init(&_vginfos);
 	dm_list_init(&_found_duplicate_devs);
 	dm_list_init(&_unused_duplicate_devs);
+	dm_list_init(&_prev_unused_duplicate_devs);
 
 	if (!(_vgname_hash = dm_hash_create(128)))
 		return 0;
@@ -581,14 +583,14 @@ next:
 
 		if (!prev_unchosen1 && !prev_unchosen2) {
 			/*
-			 * The cmd list saves the unchosen preference across
+			 * The prev list saves the unchosen preference across
 			 * lvmcache_destroy.  Sometimes a single command will
 			 * fill lvmcache, destroy it, and refill it, and we
 			 * want the same duplicate preference to be preserved
 			 * in each instance of lvmcache for a single command.
 			 */
-			prev_unchosen1 = dev_in_device_list(dev1, &cmd->unused_duplicate_devs);
-			prev_unchosen2 = dev_in_device_list(dev2, &cmd->unused_duplicate_devs);
+			prev_unchosen1 = dev_in_device_list(dev1, &_prev_unused_duplicate_devs);
+			prev_unchosen2 = dev_in_device_list(dev2, &_prev_unused_duplicate_devs);
 		}
 
 		dev1_major = MAJOR(dev1->dev);
@@ -1828,8 +1830,8 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	dm_list_init(&_vginfos);
 
 	/*
-	 * Copy the current _unused_duplicate_devs into a cmd list before
-	 * destroying _unused_duplicate_devs.
+	 * Move the current _unused_duplicate_devs to _prev_unused_duplicate_devs
+	 * before destroying _unused_duplicate_devs.
 	 *
 	 * One command can init/populate/destroy lvmcache multiple times.  Each
 	 * time it will encounter duplicates and choose the preferrred devs.
@@ -1837,8 +1839,8 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
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
index 2642d23..1e03ea2 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1715,8 +1715,6 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 	if (!init_lvmcache_orphans(cmd))
 		goto_out;
 
-	dm_list_init(&cmd->unused_duplicate_devs);
-
 	if (!_init_segtypes(cmd))
 		goto_out;
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index c9def87..0ea2132 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -234,7 +234,6 @@ struct cmd_context {
 	const char *report_list_item_separator;
 	const char *time_format;
 	unsigned rand_seed;
-	struct dm_list unused_duplicate_devs; /* save preferences between lvmcache instances */
 };
 
 /*


