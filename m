From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 26 Aug 2015 20:52:43 +0000 (UTC)
Subject: master - lvmlockd: improve VG removal for lock_type dlm
Message-ID: <20150826205243.0345560F47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c58f4892f606aafb3828c8c0d2738ed8b6407577
Commit:        c58f4892f606aafb3828c8c0d2738ed8b6407577
Parent:        7c8fc4b842223c96ed2a1b77ad774871dd34a2e2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 26 10:01:05 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 26 15:27:22 2015 -0500

lvmlockd: improve VG removal for lock_type dlm

This makes lvmlockd removal steps for dlm VGs closely match
sanlock VGs.  Because dlm lockspaces are not required to be
stopped on all hosts before vgremove, there is an extra bit
for dlm lockspaces, where a flag is set in the VG lock lvb
indicating that the VG was removed.  If other hosts happen
to use the VG lock they will see this flag and stop their
lockspace.
---
 daemons/lvmlockd/lvmlockd-client.h   |    1 +
 daemons/lvmlockd/lvmlockd-core.c     |    7 +++-
 daemons/lvmlockd/lvmlockd-dlm.c      |   25 ++++++++++++----
 daemons/lvmlockd/lvmlockd-internal.h |    4 ++
 lib/locking/lvmlockd.c               |   51 ++++++++++++++++++++++++---------
 5 files changed, 66 insertions(+), 22 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-client.h b/daemons/lvmlockd/lvmlockd-client.h
index 0a1424f..67fcbe3 100644
--- a/daemons/lvmlockd/lvmlockd-client.h
+++ b/daemons/lvmlockd/lvmlockd-client.h
@@ -47,5 +47,6 @@ static inline void lvmlockd_close(daemon_handle h)
 #define ELOCKD    216
 #define EVGKILLED 217 /* sanlock lost access to leases and VG is killed. */
 #define ELOCKIO   218 /* sanlock io errors during lock op, may be transient. */
+#define EREMOVED  219
 
 #endif	/* _LVM_LVMLOCKD_CLIENT_H */
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index b99cb0b..3d41bd2 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1763,7 +1763,7 @@ static void res_process(struct lockspace *ls, struct resource *r,
 				list_del(&act->list);
 				add_client_result(act);
 			}
-			if (rv == -EUNATCH)
+			if (rv == -EUNATCH || rv == -EREMOVED)
 				goto r_free;
 		}
 	}
@@ -1796,7 +1796,7 @@ static void res_process(struct lockspace *ls, struct resource *r,
 				list_del(&act->list);
 				add_client_result(act);
 			}
-			if (rv == -EUNATCH)
+			if (rv == -EUNATCH || rv == -EREMOVED)
 				goto r_free;
 			break;
 		}
@@ -1817,6 +1817,9 @@ r_free:
 	lm_rem_resource(ls, r);
 	list_del(&r->list);
 	free_resource(r);
+
+	if (rv == -EREMOVED)
+		ls->thread_stop = 1;
 }
 
 #define LOCKS_EXIST_ANY 1
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index e242685..676c944 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -443,6 +443,7 @@ int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
 	struct val_blk vb;
 	uint32_t flags = 0;
 	uint16_t vb_version;
+	uint16_t vb_flags;
 	int mode;
 	int rv;
 
@@ -522,6 +523,7 @@ lockrv:
 
 		memcpy(&vb, lksb->sb_lvbptr, sizeof(struct val_blk));
 		vb_version = le16_to_cpu(vb.version);
+		vb_flags = le16_to_cpu(vb.flags);
 
 		if (vb_version && ((vb_version & 0xFF00) > (VAL_BLK_VERSION & 0xFF00))) {
 			log_error("S %s R %s lock_dlm ignore vb_version %x",
@@ -536,8 +538,14 @@ lockrv:
 		*r_version = le32_to_cpu(vb.r_version);
 		memcpy(rdd->vb, &vb, sizeof(vb)); /* rdd->vb saved as le */
 
-		log_debug("S %s R %s lock_dlm get r_version %u",
-			  ls->name, r->name, *r_version);
+		log_debug("S %s R %s lock_dlm get r_version %u flags %x",
+			  ls->name, r->name, *r_version, vb_flags);
+
+		if (vb_flags & VBF_REMOVED) {
+			log_debug("S %s R %s lock_dlm VG has been removed",
+				  ls->name, r->name);
+			return -EREMOVED;
+		}
 	}
 out:
 	return 0;
@@ -593,7 +601,7 @@ int lm_convert_dlm(struct lockspace *ls, struct resource *r,
 }
 
 int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
-		  uint32_t r_version, uint32_t lmuf_flags)
+		  uint32_t r_version, uint32_t lmu_flags)
 {
 	struct lm_dlm *lmd = (struct lm_dlm *)ls->lm_data;
 	struct rd_dlm *rdd = (struct rd_dlm *)r->lm_data;
@@ -602,7 +610,7 @@ int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
 	int rv;
 
 	log_debug("S %s R %s unlock_dlm r_version %u flags %x",
-		  ls->name, r->name, r_version, lmuf_flags);
+		  ls->name, r->name, r_version, lmu_flags);
 
 	/*
 	 * Do not set PERSISTENT, because we don't need an orphan
@@ -611,12 +619,17 @@ int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
 
 	flags |= LKF_CONVERT;
 
-	if (rdd->vb && r_version && (r->mode == LD_LK_EX)) {
+	if (rdd->vb && (r->mode == LD_LK_EX)) {
 		if (!rdd->vb->version) {
 			/* first time vb has been written */
 			rdd->vb->version = cpu_to_le16(VAL_BLK_VERSION);
 		}
-		rdd->vb->r_version = cpu_to_le32(r_version);
+		if (r_version)
+			rdd->vb->r_version = cpu_to_le32(r_version);
+
+		if ((lmu_flags & LMUF_FREE_VG) && (r->type == LD_RT_VG))
+			rdd->vb->flags = cpu_to_le16(VBF_REMOVED);
+
 		memcpy(lksb->sb_lvbptr, rdd->vb, sizeof(struct val_blk));
 
 		log_debug("S %s R %s unlock_dlm set r_version %u",
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 8e0582b..46ae67f 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -194,8 +194,12 @@ struct lockspace {
 	struct list_head resources;	/* resource/lock state for gl/vg/lv */
 };
 
+/* val_blk version */
 #define VAL_BLK_VERSION 0x0101
 
+/* val_blk flags */
+#define VBF_REMOVED 0x0001
+
 struct val_blk {
 	uint16_t version;
 	uint16_t flags;
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 3f73cf3..e647c96 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -694,7 +694,8 @@ out:
 
 static int _free_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
 {
-	uint32_t lockd_flags;
+	daemon_reply reply;
+	uint32_t lockd_flags = 0;
 	int result;
 	int ret;
 
@@ -704,23 +705,31 @@ static int _free_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
 		return 0;
 
 	/*
-	 * Unlocking the vg lock here preempts the lvmlockd unlock in
-	 * toollib.c which happens too late since the lockspace is
-	 * left here.
+	 * For the dlm, free_vg means unlock the ex VG lock,
+	 * and include an indication in the lvb that the VG
+	 * has been removed.  Then, leave the lockspace.
+	 * If another host tries to acquire the VG lock, it
+	 * will see that the VG has been removed by looking
+	 * at the lvb value.
 	 */
 
-	/* Equivalent to a standard unlock. */
-	ret = _lockd_request(cmd, "lock_vg",
-			     vg->name, NULL, NULL, NULL, NULL, NULL, "un", NULL,
-			     &result, &lockd_flags);
+	reply = _lockd_send("free_vg",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				"vg_lock_type = %s", vg->lock_type,
+				"vg_lock_args = %s", vg->lock_args,
+				NULL);
 
-	if (!ret || result < 0) {
-		log_error("_free_vg_dlm lvmlockd result %d", result);
-		return 0;
+	if (!_lockd_result(reply, &result, &lockd_flags)) {
+		ret = 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
 	}
 
-	/* Leave the dlm lockspace. */
-	lockd_stop_vg(cmd, vg);
+	if (!ret)
+		log_error("_free_vg_dlm lvmlockd result %d", result);
+
+	daemon_reply_destroy(reply);
 
 	return 1;
 }
@@ -893,7 +902,11 @@ static int _lockd_all_lvs(struct cmd_context *cmd, struct volume_group *vg)
 int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg,
 			 int changing)
 {
-	/* Check that no LVs are active on other hosts. */
+	/*
+	 * Check that no LVs are active on other hosts.
+	 * When removing (not changing), each LV is locked
+	 * when it is removed, they do not need checking here.
+	 */
 	if (changing && !_lockd_all_lvs(cmd, vg)) {
 		log_error("Cannot change VG %s with active LVs", vg->name);
 		return 0;
@@ -1741,6 +1754,16 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	}
 
 	/*
+	 * The VG has been removed.  This will only happen with a dlm VG
+	 * since a sanlock VG must be stopped everywhere before it's removed.
+	 */
+	if (result == -EREMOVED) {
+		log_error("VG %s lock is removed", vg_name);
+		ret = 0;
+		goto out;
+	}
+
+	/*
 	 * The lockspace for the VG is starting (the VG must not
 	 * be local), and is not yet ready to do locking.  Allow
 	 * reading without a sh lock during this period.


