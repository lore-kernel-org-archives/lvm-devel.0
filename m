From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 27 Aug 2015 15:28:49 +0000 (UTC)
Subject: master - lvmlockd: fix to work around dlm lvb bug
Message-ID: <20150827152849.F262E607A1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=521136181b6c6cfde4c07d5aecf1dcc5e0ab9594
Commit:        521136181b6c6cfde4c07d5aecf1dcc5e0ab9594
Parent:        fda19b55b1f1a04c7539d007dfb6cd3faf1857de
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 25 16:10:12 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 27 10:27:24 2015 -0500

lvmlockd: fix to work around dlm lvb bug

Work around a dlm bug that fails to copy lvb
on a NL->EX conversion.
---
 daemons/lvmlockd/lvmlockd-dlm.c |   35 +++++++++++++++++++++++++++++++++--
 1 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 1d7cfe6..e242685 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -67,6 +67,8 @@ int lm_data_size_dlm(void)
 #define VG_LOCK_ARGS_MINOR 0
 #define VG_LOCK_ARGS_PATCH 0
 
+static int dlm_has_lvb_bug;
+
 static int cluster_name_from_args(char *vg_args, char *clustername)
 {
 	return last_string_from_args(vg_args, clustername);
@@ -160,6 +162,7 @@ int lm_prepare_lockspace_dlm(struct lockspace *ls)
 {
 	char sys_clustername[MAX_ARGS+1];
 	char arg_clustername[MAX_ARGS+1];
+	uint32_t major = 0, minor = 0, patch = 0;
 	struct lm_dlm *lmd;
 	int rv;
 
@@ -170,6 +173,17 @@ int lm_prepare_lockspace_dlm(struct lockspace *ls)
 	if (rv < 0)
 		return -EMANAGER;
 
+	rv = dlm_kernel_version(&major, &minor, &patch);
+	if (rv < 0) {
+		log_error("prepare_lockspace_dlm kernel_version not detected %d", rv);
+		dlm_has_lvb_bug = 1;
+	}
+
+	if ((major == 6) && (minor == 0) && (patch == 1)) {
+		log_debug("dlm kernel version %u.%u.%u has lvb bug", major, minor, patch);
+		dlm_has_lvb_bug = 1;
+	}
+
 	if (!ls->vg_args[0]) {
 		/* global lockspace has no vg args */
 		goto skip_args;
@@ -468,9 +482,27 @@ int lm_lock_dlm(struct lockspace *ls, struct resource *r, int ld_mode,
 		return 0;
 	}
 
+	/*
+	 * The dlm lvb bug means that converting NL->EX will not return 
+	 * the latest lvb, so we have to convert NL->PR->EX to reread it.
+	 */
+	if (dlm_has_lvb_bug && (ld_mode == LD_LK_EX)) {
+		rv = dlm_ls_lock_wait(lmd->dh, LKM_PRMODE, lksb, flags,
+				      r->name, strlen(r->name),
+				      0, NULL, NULL, NULL);
+		if (rv == -1) {
+			log_debug("S %s R %s lock_dlm acquire mode PR for %d rv %d",
+				  ls->name, r->name, mode, rv);
+			goto lockrv;
+		}
+
+		/* Fall through to request EX. */
+	}
+
 	rv = dlm_ls_lock_wait(lmd->dh, mode, lksb, flags,
 			      r->name, strlen(r->name),
 			      0, NULL, NULL, NULL);
+lockrv:
 	if (rv == -1 && errno == EAGAIN) {
 		log_debug("S %s R %s lock_dlm acquire mode %d rv EAGAIN", ls->name, r->name, mode);
 		return -EAGAIN;
@@ -584,8 +616,7 @@ int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
 			/* first time vb has been written */
 			rdd->vb->version = cpu_to_le16(VAL_BLK_VERSION);
 		}
-		if (r_version)
-			rdd->vb->r_version = cpu_to_le32(r_version);
+		rdd->vb->r_version = cpu_to_le32(r_version);
 		memcpy(lksb->sb_lvbptr, rdd->vb, sizeof(struct val_blk));
 
 		log_debug("S %s R %s unlock_dlm set r_version %u",


