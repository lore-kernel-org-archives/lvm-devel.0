From: David Teigland <teigland@sourceware.org>
Date: Fri, 8 Jun 2018 15:02:15 -0400
Subject: master - Remove unused cache management from locking
Message-ID: <201806081902.w58J2FJe003633@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8759dc7a6669b9ecfbc749d68beed2e0029903b
Commit:        a8759dc7a6669b9ecfbc749d68beed2e0029903b
Parent:        5e672df6aefd5b61129636994d8b5cdc05f651ea
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 8 12:30:43 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 8 12:30:43 2018 -0500

Remove unused cache management from locking

This code was for managing lvmcache for clvm
and it no longer does anything.
---
 lib/locking/locking.h   |    4 ----
 lib/metadata/metadata.c |   20 --------------------
 tools/vgmerge.c         |    3 ---
 tools/vgrename.c        |    4 ----
 4 files changed, 0 insertions(+), 31 deletions(-)

diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index f6a3859..23636fc 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -138,7 +138,6 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 #define LCK_VG_READ		(LCK_VG | LCK_READ | LCK_HOLD)
 #define LCK_VG_WRITE		(LCK_VG | LCK_WRITE | LCK_HOLD)
 #define LCK_VG_UNLOCK		(LCK_VG | LCK_UNLOCK)
-#define LCK_VG_DROP_CACHE	(LCK_VG | LCK_WRITE | LCK_CACHE)
 
 /* FIXME: LCK_HOLD abused here */
 #define LCK_VG_COMMIT		(LCK_VG | LCK_WRITE | LCK_CACHE | LCK_HOLD)
@@ -163,9 +162,6 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 		release_vg(vg); \
 	} while (0)
 
-#define drop_cached_metadata(vg)	\
-	lock_vol((vg)->cmd, (vg)->name, LCK_VG_DROP_CACHE, NULL)
-
 int sync_local_dev_names(struct cmd_context* cmd);
 
 /* Process list of LVs */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b7a73c5..e45f5c1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2915,11 +2915,6 @@ int vg_write(struct volume_group *vg)
 		return 0;
 	}
 
-	if (!drop_cached_metadata(vg)) {
-		log_error("Unable to drop cached metadata for VG %s.", vg->name);
-		return 0;
-	}
-
 	if (critical_section())
 		log_error(INTERNAL_ERROR
 			  "Writing metadata in critical section.");
@@ -3077,11 +3072,6 @@ int vg_commit(struct volume_group *vg)
 		_vg_move_cached_precommitted_to_committed(vg);
 	}
 
-	/* If update failed, remove any cached precommitted metadata. */
-	if (!cache_updated && !drop_cached_metadata(vg))
-		log_error("Attempt to drop cached metadata failed "
-			  "after commit for VG %s.", vg->name);
-
 	/* If at least one mda commit succeeded, it was committed */
 	return cache_updated;
 }
@@ -3115,10 +3105,6 @@ void vg_revert(struct volume_group *vg)
 			stack;
 		}
 	}
-
-	if (!drop_cached_metadata(vg))
-		log_error("Attempt to drop cached metadata failed "
-			  "after reverted update for VG %s.", vg->name);
 }
 
 static int _check_mda_in_use(struct metadata_area *mda, void *_in_use)
@@ -3543,12 +3529,6 @@ static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg,
 			 pv_dev_name(pvl->pv), uuid, vg->name);
 		if (!pv_write_orphan(cmd, pvl->pv))
 			return_0;
-
-		/* Refresh metadata after orphan write */
-		if (!drop_cached_metadata(vg)) {
-			log_error("Unable to drop cached metadata for VG %s while wiping outdated PVs.", vg->name);
-			return 0;
-		}
 next_pv:
 		;
 	}
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 920ed73..eab3d56 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -103,9 +103,6 @@ static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 	if (!archive(vg_from) || !archive(vg_to))
 		goto_bad;
 
-	if (!drop_cached_metadata(vg_from))
-		stack;
-
 	if (!_vgmerge_select_pool_metadata_spare(cmd, vg_to, vg_from))
 		goto_bad;
 
diff --git a/tools/vgrename.c b/tools/vgrename.c
index bbc3087..2e6157f 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -108,10 +108,6 @@ static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
 	if (!archive(vg))
 		goto error;
 
-	/* Remove references based on old name */
-	if (!drop_cached_metadata(vg))
-		stack;
-
 	if (!lockd_rename_vg_before(cmd, vg)) {
 		stack;
 		goto error;


