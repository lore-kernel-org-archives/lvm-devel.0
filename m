From: David Teigland <teigland@sourceware.org>
Date: Thu, 26 Apr 2018 15:58:15 -0400
Subject: master - clvmd: drop old saved_vg when returning new saved_vg
Message-ID: <201804261958.w3QJwFD9022934@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5b6e62dc1f3b27089179308fa2f7d004850d5a2c
Commit:        5b6e62dc1f3b27089179308fa2f7d004850d5a2c
Parent:        cdb8400de2d89e2e5901524acdd2178118d740b7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 26 14:41:57 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 26 14:57:45 2018 -0500

clvmd: drop old saved_vg when returning new saved_vg

In some pvmove tests, clvmd uses the new (precommitted)
saved_vg, but then requests the old saved_vg, and
expects that the new saved_vg be returned instead of
the old.  So, when returning the new saved_vg, forget
the old one so we don't return it again.
---
 lib/activate/activate.c |   12 +++++-
 lib/cache/lvmcache.c    |   89 +++++++++++++++++++++++++++++++++++++++++++++--
 lib/metadata/metadata.c |    2 +-
 3 files changed, 97 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8e79cf5..7a2a945 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2164,6 +2164,8 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	vg_pre = lvmcache_get_saved_vg(vgid, 1);
 
 	if (!vg || !vg_pre) {
+		log_debug("lv_suspend dropping both saved vgs and rereading");
+
 		lvmcache_drop_saved_vgid(vgid);
 
 		vg = vg_read_by_vgid(cmd, vgid, 0);
@@ -2175,8 +2177,14 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 			goto out;
 		}
 
-		log_debug("lv_suspend found vg %s vg %p vg_pre %p",
-			  vg->name, vg, vg_pre);
+		/*
+		 * Note that vg and vg_pre returned by vg_read_by_vgid will
+		 * not be the same as saved_vg_old/saved_vg_new that would
+		 * be returned by lvmcache_get_saved_vg() because the saved_vg's
+		 * are copies of the vg struct that is created by _vg_read.
+		 * (Should we grab and use the saved_vg to use here instead of
+		 * the vg returned by vg_read_by_vgid?)
+		 */
 
 		if ((vg->status & EXPORTED_VG) || (vg_pre->status & EXPORTED_VG)) {
 			log_error("Volume group \"%s\" is exported", vg->name);
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index e88d350..bd92055 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -300,7 +300,7 @@ void lvmcache_save_vg(struct volume_group *vg, int precommitted)
 		vginfo->saved_vg_old_buf = susp_buf;
 		vginfo->saved_vg_old_cft = susp_cft;
 		vginfo->saved_vg_old = save_vg;
-		log_debug_cache("lvmcache saved vg %s seqno %d %p",
+		log_debug_cache("lvmcache saved old vg %s seqno %d %p",
 				save_vg->name, save_vg->seqno, save_vg);
 	} else {
 		vginfo->saved_vg_new_buf = susp_buf;
@@ -326,10 +326,57 @@ struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted)
 	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
 		goto out;
 
+	/*
+	 * Once new is returned, then also return new if old is requested,
+	 * i.e. new becomes both old and new once it's used.
+	 */
+
 	if (new)
 		vg = vginfo->saved_vg_new;
 	else if (old)
 		vg = vginfo->saved_vg_old;
+
+	if (vg && old) {
+		if (!vginfo->saved_vg_new)
+			log_debug_cache("lvmcache: get old saved_vg %d %s %p",
+					vg->seqno, vg->name, vg);
+		else
+			log_debug_cache("lvmcache: get old saved_vg %d %s %p new is %d %p",
+					vg->seqno, vg->name, vg,
+					vginfo->saved_vg_new->seqno,
+					vginfo->saved_vg_new);
+	}
+
+	if (vg && new) {
+		if (!vginfo->saved_vg_old)
+			log_debug_cache("lvmcache: get new (pre) saved_vg %d %s %p",
+					vg->seqno, vg->name, vg);
+		else
+			log_debug_cache("lvmcache: get new (pre) saved_vg %d %s %p old is %d %p",
+					vg->seqno, vg->name, vg,
+					vginfo->saved_vg_old->seqno,
+					vginfo->saved_vg_old);
+
+		/* Do we need to actually set saved_vg_old to match saved_vg_new?
+		 * By just dropping old, we force a subsequent request for old to
+		 * reread it rather than just using new. */
+		if (vginfo->saved_vg_old) {
+			log_debug_cache("lvmcache: drop saved_vg_old because new invalidates");
+			_saved_vg_free(vginfo, 1, 0);
+		}
+	}
+
+	if (!vg && new && vginfo->saved_vg_old)
+		log_warn("lvmcache_get_saved_vg pre %d wanted new but only have old %d %s",
+			 precommitted,
+			 vginfo->saved_vg_old->seqno,
+			 vginfo->saved_vg_old->name);
+
+	if (!vg && old && vginfo->saved_vg_new)
+		log_warn("lvmcache_get_saved_vg pre %d wanted old but only have new %d %s",
+			 precommitted,
+			 vginfo->saved_vg_new->seqno,
+			 vginfo->saved_vg_new->name);
 out:
 	if (!vg)
 		log_debug_cache("lvmcache no saved vg %s pre %d", vgid, precommitted);
@@ -340,14 +387,49 @@ struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg = NULL;
+	int old = 0;
+	int new = 0;
 
 	if (!(vginfo = lvmcache_vginfo_from_vgid(vgid)))
 		goto out;
 
-	if (vginfo->saved_vg_committed)
+	if (vginfo->saved_vg_committed) {
 		vg = vginfo->saved_vg_new;
-	else
+		new = 1;
+	} else {
 		vg = vginfo->saved_vg_old;
+		old = 1;
+	}
+
+	if (vg && old) {
+		if (!vginfo->saved_vg_new)
+			log_debug_cache("lvmcache: get_latest old saved_vg %d %s %p",
+					vg->seqno, vg->name, vg);
+		else
+			log_debug_cache("lvmcache: get_latest old saved_vg %d %s %p new is %d %p",
+					vg->seqno, vg->name, vg,
+					vginfo->saved_vg_new->seqno,
+					vginfo->saved_vg_new);
+	}
+
+	if (vg && new) {
+		if (!vginfo->saved_vg_old)
+			log_debug_cache("lvmcache: get_latest new (pre) saved_vg %d %s %p",
+					vg->seqno, vg->name, vg);
+		else
+			log_debug_cache("lvmcache: get_latest new (pre) saved_vg %d %s %p old is %d %p",
+					vg->seqno, vg->name, vg,
+					vginfo->saved_vg_old->seqno,
+					vginfo->saved_vg_old);
+
+		/* Do we need to actually set saved_vg_old to match saved_vg_new?
+		 * By just dropping old, we force a subsequent request for old to
+		 * reread it rather than just using new. */
+		if (vginfo->saved_vg_old) {
+			log_debug_cache("lvmcache: drop saved_vg_old because new invalidates");
+			_saved_vg_free(vginfo, 1, 0);
+		}
+	}
 out:
 	if (!vg)
 		log_debug_cache("lvmcache no saved vg %s", vgid);
@@ -1246,6 +1328,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		goto out;
 	}
 
+	/* FIXME: can this happen? */
 	if (!cmd->full_filter) {
 		log_error("label scan is missing full filter");
 		goto out;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3c1d8a4..97225df 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3869,7 +3869,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		if (warn_flags & SKIP_RESCAN)
 			goto find_vg;
 		skipped_rescan = 0;
-		log_debug_metadata("Rescanning devices for for %s", vgname);
+		log_debug_metadata("Rescanning devices for %s", vgname);
 		lvmcache_label_rescan_vg(cmd, vgname, vgid);
 	} else {
 		log_debug_metadata("Skipped rescanning devices for %s", vgname);


