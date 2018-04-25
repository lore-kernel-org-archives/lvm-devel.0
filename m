From: David Teigland <teigland@sourceware.org>
Date: Wed, 25 Apr 2018 17:51:17 -0400
Subject: master - skip some clvmd-specific code in common cases
Message-ID: <201804252151.w3PLpHhl017834@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4670e9f698099bf1b9612d16855f9207c0e0f467
Commit:        4670e9f698099bf1b9612d16855f9207c0e0f467
Parent:        47bfac21cab25b104170bf31e4fec84096bf90a5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 25 15:08:54 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 25 16:40:08 2018 -0500

skip some clvmd-specific code in common cases

This, or something like it, can probably be done
in many other places.
---
 daemons/clvmd/lvm-functions.c |    1 +
 lib/activate/activate.c       |    9 +++++++--
 lib/cache/lvmcache.c          |    2 --
 lib/commands/toolcontext.h    |    1 +
 4 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 6254122..7e7b992 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -913,6 +913,7 @@ int init_clvm(struct dm_hash_table *excl_uuid)
 		return 0;
 	}
 
+	cmd->is_clvmd = 1;
 	cmd->cmd_line = "clvmd";
 
 	/* Check lvm.conf is setup for cluster-LVM */
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index eb04ef0..8e79cf5 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2154,6 +2154,9 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	if (!activation())
 		return 1;
 
+	if (!cmd->is_clvmd)
+		goto skip_read;
+
 	if (lv && lv_pre)
 		goto skip_read;
 
@@ -2223,8 +2226,10 @@ skip_read:
 	 * did happen (or failed), and it will resume LVs using the
 	 * new/precommitted metadata if the vg_commit succeeded.
 	 */
-	lvmcache_save_vg(lv->vg, 0);
-	lvmcache_save_vg(lv_pre->vg, 1);
+	if (cmd->is_clvmd) {
+		lvmcache_save_vg(lv->vg, 0);
+		lvmcache_save_vg(lv_pre->vg, 1);
+	}
 
 	if (!info.exists || info.suspended) {
 		if (!error_if_not_suspended) {
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 4a7b6f9..7534567 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -246,8 +246,6 @@ static void _drop_metadata(const char *vgname, int drop_precommitted)
 	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
 		return;
 
-	log_debug_cache("lvmcache: dropping saved_vg %s pre %d", vgname, drop_precommitted);
-
 	if (drop_precommitted)
 		_saved_vg_free(vginfo, 0, 1);
 	else
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 2474264..1d9de0a 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -170,6 +170,7 @@ struct cmd_context {
 	unsigned mirror_warn_printed:1;		/* command already printed warning about non-monitored mirrors */
 	unsigned pvscan_cache_single:1;
 	unsigned can_use_one_scan:1;
+	unsigned is_clvmd:1;
 
 	/*
 	 * Filtering.


