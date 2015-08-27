From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 27 Aug 2015 15:28:54 +0000 (UTC)
Subject: master - lvmlockd: rescan lockd VG in two new cases
Message-ID: <20150827152854.42F5B603F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32e22a00378192f226932258d9c5b55b073b4528
Commit:        32e22a00378192f226932258d9c5b55b073b4528
Parent:        231b7df6cc80ffb1a93db6f948670d9c37b169ea
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 26 14:06:39 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 27 10:27:24 2015 -0500

lvmlockd: rescan lockd VG in two new cases

Previously, a command would only rescan a lockd VG
when lvmetad returned the "vg_invalid" flag indicating
that the cached copy was invalid (which is done by
lvmlockd.)  This is still the only usual reason for
rescanning a lockd VG, but two new special cases are
added where we also do the rescan:

. When the --shared option is used to display lockd VGs
  from hosts not using lvmlockd.  This is the same case
  as using --foreign to display foreign VGs, but --shared
  was missing the corresponding bits to rescan the VGs.

. When a lockd VG is allowed to be read for displaying
  after failing to acquire the lock from lvmlockd.  In
  this case, the usual mechanism for validating the
  cache is missed, so assume the cache would have been
  invalidated.  (This had been a previous todo item
  that was lost during other cleanup.)

These were long-standing todos that were lost track of.
---
 lib/cache/lvmetad.c        |   45 ++++++++++++++++++++++++++++++++++++++++++-
 lib/commands/toolcontext.h |    1 +
 lib/locking/lvmlockd.c     |   35 ++++++++++++++++++++++++++++++++-
 3 files changed, 77 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 856b30f..b2e2f55 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -434,6 +434,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	struct format_type *fmt;
 	struct dm_config_node *pvcn;
 	struct pv_list *pvl;
+	int rescan = 0;
 
 	if (!lvmetad_active())
 		return NULL;
@@ -493,15 +494,55 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 			goto_out;
 
 		/*
+		 * Read the VG from disk, ignoring the lvmetad copy in these
+		 * cases:
+		 *
+		 * 1. The host is not using lvmlockd, but is reading lockd VGs
+		 * using the --shared option.  The shared option is meant to
+		 * let hosts not running lvmlockd look at lockd VGs, like the
+		 * foreign option allows hosts to look at foreign VGs.  When
+		 * --foreign is used, the code forces a rescan since the local
+		 * lvmetad cache of foreign VGs is likely stale.  Similarly,
+		 * for --shared, have the code reading the shared VGs below
+		 * not use the cached copy from lvmetad but to rescan the VG.
+		 *
+		 * 2. The host failed to acquire the VG lock from lvmlockd for
+		 * the lockd VG.  In this case, the usual mechanisms for
+		 * updating the lvmetad copy of the VG have been missed.  Since
+		 * we don't know if the cached copy is valid, assume it's not.
+		 *
+		 * 3. lvmetad has returned the "vg_invalid" flag, which is the
+		 * usual mechanism used by lvmlockd/lvmetad to cause a host to
+		 * reread a VG from disk that has been modified from another
+		 * host.
+		 */
+
+		if (is_lockd_type(vg->lock_type) && cmd->include_shared_vgs) {
+			log_debug_lvmetad("Rescan VG %s because including shared", vgname);
+			rescan = 1;
+		} else if (is_lockd_type(vg->lock_type) && cmd->lockd_vg_rescan) {
+			log_debug_lvmetad("Rescan VG %s because no lvmlockd lock is held", vgname);
+			rescan = 1;
+		} else if (dm_config_find_node(reply.cft->root, "vg_invalid")) {
+			log_debug_lvmetad("Rescan VG %s because lvmetad returned invalid", vgname);
+			rescan = 1;
+		}
+
+		/*
 		 * locking may have detected a newer vg version and
 		 * invalidated the cached vg.
 		 */
-		if (dm_config_find_node(reply.cft->root, "vg_invalid")) {
+		if (rescan) {
 			log_debug_lvmetad("Update invalid lvmetad cache for VG %s", vgname);
 			vg2 = lvmetad_pvscan_vg(cmd, vg);
 			release_vg(vg);
 			vg = vg2;
-			fid = vg->fid;
+			if (!vg) {
+				log_debug_lvmetad("VG %s from lvmetad not found during rescan.", vgname);
+				fid = NULL;
+				goto out;
+			} else
+				fid = vg->fid;
 		}
 
 		dm_list_iterate_items(pvl, &vg->pvs) {
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 0440163..cd55348 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -134,6 +134,7 @@ struct cmd_context {
 	unsigned lockd_vg_disable:1;
 	unsigned lockd_lv_disable:1;
 	unsigned lockd_gl_removed:1;
+	unsigned lockd_vg_rescan:1;
 	unsigned lockd_vg_default_sh:1;
 	unsigned lockd_vg_enforce_sh:1;
 
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index e647c96..45159d2 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1323,6 +1323,9 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 		return 0;
 	}
 
+	/* --shared with vgcreate does not mean include_shared_vgs */
+	cmd->include_shared_vgs = 0;
+
 	lvmetad_validate_global_cache(cmd, 1);
 
 	return 1;
@@ -1631,8 +1634,31 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	int result;
 	int ret;
 
+	/*
+	 * The result of the VG lock request is saved in lockd_state to be
+	 * passed into vg_read where the lock result is needed once we
+	 * know if this is a local VG or lockd VG.
+	 */
 	*lockd_state = 0;
 
+	/*
+	 * Use of lockd_vg_rescan.
+	 *
+	 * This is the VG equivalent of using lvmetad_validate_global_cache()
+	 * for the global lock (after failing to acquire the global lock).  If
+	 * we fail to acquire the VG lock from lvmlockd, then the lvmlockd
+	 * mechanism has been missed that would have updated the cached lvmetad
+	 * copy of the VG.  So, set lockd_vg_rescan to tell the VG reading code
+	 * to treat the lvmetad copy as if the invalid flag had been returned.
+	 * i.e. If a lockd VG is read without a lock, ignore the lvmetad copy
+	 * and read it from disk since we don't know if the cache is stale.
+	 *
+	 * Because lvmlockd requests return an error for local VGs, this will
+	 * be set for local VGs, but it ends up being ignored once the VG is
+	 * read and found to be a local VG.
+	 */
+	cmd->lockd_vg_rescan = 0;
+
 	if (!is_real_vg(vg_name))
 		return 1;
 
@@ -1703,6 +1729,7 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	 */
 	if (!_use_lvmlockd) {
 		*lockd_state |= LDST_FAIL_REQUEST;
+		cmd->lockd_vg_rescan = 1;
 		return 1;
 	}
 
@@ -1719,6 +1746,7 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 		 * this error for local VGs, but we do care for lockd VGs.
 		 */
 		*lockd_state |= LDST_FAIL_REQUEST;
+		cmd->lockd_vg_rescan = 1;
 		return 1;
 	}
 
@@ -1737,12 +1765,15 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 		break;
 	case -ENOLS:
 		*lockd_state |= LDST_FAIL_NOLS;
+		cmd->lockd_vg_rescan = 1;
 		break;
 	case -ESTARTING:
 		*lockd_state |= LDST_FAIL_STARTING;
+		cmd->lockd_vg_rescan = 1;
 		break;
 	default:
 		*lockd_state |= LDST_FAIL_OTHER;
+		cmd->lockd_vg_rescan = 1;
 	}
 
 	/*
@@ -1758,8 +1789,8 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	 * since a sanlock VG must be stopped everywhere before it's removed.
 	 */
 	if (result == -EREMOVED) {
-		log_error("VG %s lock is removed", vg_name);
-		ret = 0;
+		log_error("VG %s lock failed: removed", vg_name);
+		ret = 1;
 		goto out;
 	}
 


