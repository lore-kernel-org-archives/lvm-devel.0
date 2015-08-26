From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 26 Aug 2015 20:52:36 +0000 (UTC)
Subject: master - lvmlockd: add full changing of lock type
Message-ID: <20150826205236.A593D60F47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9ca9d73c1037657660bb3c966e9039ff75144c1
Commit:        b9ca9d73c1037657660bb3c966e9039ff75144c1
Parent:        8740b7cb77699dbb78e80ed4e8bd6c742626558e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 24 15:06:23 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 26 15:22:31 2015 -0500

lvmlockd: add full changing of lock type

Remove the existing lock type using the same functions
used to remove the lockd components during vgremove.
This results in a "clean" VG and lvmlockd state after
the vgchange, i.e. no bits left over from previous
lock type.
---
 lib/locking/lvmlockd.c |   45 +++++++++++++++++++++++++++++++--------------
 lib/locking/lvmlockd.h |    2 +-
 tools/vgchange.c       |   41 ++++++++++++++++++++++++++---------------
 tools/vgremove.c       |    2 +-
 4 files changed, 59 insertions(+), 31 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 5918de3..3f73cf3 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -868,10 +868,37 @@ int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg,
 	}
 }
 
+static int _lockd_all_lvs(struct cmd_context *cmd, struct volume_group *vg)
+{
+	struct lv_list *lvl;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!lockd_lv(cmd, lvl->lv, "ex", 0)) {
+			log_error("LV %s/%s must be inactive on all hosts.",
+				  vg->name, lvl->lv->name);
+			return 0;
+		}
+
+		if (!lockd_lv(cmd, lvl->lv, "un", 0)) {
+			log_error("Failed to unlock LV %s/%s.", vg->name, lvl->lv->name);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 /* vgremove before the vg is removed */
 
-int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg)
+int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg,
+			 int changing)
 {
+	/* Check that no LVs are active on other hosts. */
+	if (changing && !_lockd_all_lvs(cmd, vg)) {
+		log_error("Cannot change VG %s with active LVs", vg->name);
+		return 0;
+	}
+
 	switch (get_lock_type_from_string(vg->lock_type)) {
 	case LOCK_TYPE_NONE:
 	case LOCK_TYPE_CLVM:
@@ -2374,7 +2401,6 @@ int lockd_free_lv(struct cmd_context *cmd, struct volume_group *vg,
 
 int lockd_rename_vg_before(struct cmd_context *cmd, struct volume_group *vg)
 {
-	struct lv_list *lvl;
 	daemon_reply reply;
 	int result;
 	int ret;
@@ -2392,18 +2418,9 @@ int lockd_rename_vg_before(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	/* Check that no LVs are active on other hosts. */
-
-	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (!lockd_lv(cmd, lvl->lv, "ex", 0)) {
-			log_error("LV %s/%s must be inactive on all hosts before vgrename.",
-				  vg->name, lvl->lv->name);
-			return 0;
-		}
-
-		if (!lockd_lv(cmd, lvl->lv, "un", 0)) {
-			log_error("Failed to unlock LV %s/%s.", vg->name, lvl->lv->name);
-			return 0;
-		}
+	if (!_lockd_all_lvs(cmd, vg)) {
+		log_error("Cannot rename VG %s with active LVs", vg->name);
+		return 0;
 	}
 
 	/*
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 64b3ce9..ec36ff8 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -54,7 +54,7 @@ void lvmlockd_disconnect(void);
 /* vgcreate/vgremove use init/free */
 
 int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg, const char *lock_type, int lv_lock_count);
-int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg);
+int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg, int changing);
 void lockd_free_vg_final(struct cmd_context *cmd, struct volume_group *vg);
 
 /* vgrename */
diff --git a/tools/vgchange.c b/tools/vgchange.c
index cbdc29a..f57fa15 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -568,11 +568,17 @@ static int _vgchange_locktype(struct cmd_context *cmd,
 	}
 
 	if (!strcmp(vg->lock_type, lock_type)) {
-		log_warn("New lock_type %s matches the current lock_type %s.",
+		log_warn("New lock type %s matches the current lock type %s.",
 			 lock_type, vg->lock_type);
 		return 1;
 	}
 
+	if (is_lockd_type(vg->lock_type) && is_lockd_type(lock_type)) {
+		log_error("First change from lock type %s to none, then to lock type %s",
+			  vg->lock_type, lock_type);
+		return 0;
+	}
+
 	/*
 	 * When lvm is currently using clvm, this function is just an alternative
 	 * to vgchange -c{y,n}, and can:
@@ -627,17 +633,19 @@ static int _vgchange_locktype(struct cmd_context *cmd,
 
 	/*
 	 * lockd type to ..., first undo lockd type
-	 *
-	 * To allow this, we need to do:
-	 * lockd_stop_vg();
-	 * lockd_free_vg_before();
-	 * lockd_free_vg_after();
 	 */
 	if (is_lockd_type(vg->lock_type)) {
-		/* FIXME: implement full undoing of the lock_type */
-		log_error("Changing VG %s from lock type %s not yet allowed.",
-			  vg->name, vg->lock_type);
-		return 0;
+		if (!lockd_free_vg_before(cmd, vg, 1))
+			return 0;
+
+		lockd_free_vg_final(cmd, vg);
+
+		vg->status &= ~CLUSTERED;
+		vg->lock_type = "none";
+		vg->lock_args = NULL;
+
+		dm_list_iterate_items(lvl, &vg->lvs)
+			lvl->lv->lock_args = NULL;
 	}
 
 	/* ... to clvm */
@@ -716,7 +724,14 @@ static int _vgchange_locktype(struct cmd_context *cmd,
 		return 1;
 	}
 
-	log_error("Unknown lock type");
+	/* ... to none */
+	if (!strcmp(lock_type, "none")) {
+		vg->lock_type = NULL;
+		vg->system_id = cmd->system_id ? dm_pool_strdup(vg->vgmem, cmd->system_id) : NULL;
+		return 1;
+	}
+
+	log_error("Cannot change to unknown lock type %s", lock_type);
 	return 0;
 }
 
@@ -791,10 +806,6 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 	if (vg->lvm1_system_id)
 		*vg->lvm1_system_id = '\0';
 
-	/* update system_id in lvmlockd's record for this vg */
-	if (!lockd_start_vg(cmd, vg))
-		log_debug("Failed to update lvmlockd.");
-
 	return 1;
 }
 
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 692d114..219149e 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -68,7 +68,7 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 		}
 	}
 
-	if (!lockd_free_vg_before(cmd, vg))
+	if (!lockd_free_vg_before(cmd, vg, 0))
 		return_ECMD_FAILED;
 
 	if (!force && !vg_remove_check(vg))


