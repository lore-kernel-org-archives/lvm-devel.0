From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 10 Sep 2015 14:50:24 +0000 (UTC)
Subject: master - lockd: add start_init arg to lockd_start_vg
Message-ID: <20150910145024.A805F60EE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36d16fed1fe883cf2c2756212fd0e6b2f1f99e6b
Commit:        36d16fed1fe883cf2c2756212fd0e6b2f1f99e6b
Parent:        30e489db5e05296e22037bd885d074d395ab46f4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 9 13:20:37 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 10 09:47:26 2015 -0500

lockd: add start_init arg to lockd_start_vg

Add a new arg to lockd_start_vg() that indicates
it is being called for a new lockd VG, so that
lvmlockd knows the lockspace being started is new.
(Will be used by a following commit.)
---
 lib/locking/lvmlockd.c |   15 ++++++++++-----
 lib/locking/lvmlockd.h |    4 ++--
 tools/vgchange.c       |    2 +-
 tools/vgcreate.c       |    2 +-
 4 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index a726d87..597a964 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -921,9 +921,13 @@ void lockd_free_vg_final(struct cmd_context *cmd, struct volume_group *vg)
  * for starting the lockspace.  To use the vg after starting
  * the lockspace, follow the standard method which is:
  * lock the vg, read/use/write the vg, unlock the vg.
+ *
+ * start_init is 1 when the VG is being started after the
+ * command has done lockd_init_vg().  This tells lvmlockd
+ * that the VG lockspace being started is new.
  */
 
-int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg)
+int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_init)
 {
 	char uuid[64] __attribute__((aligned(8)));
 	daemon_reply reply;
@@ -945,8 +949,8 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg)
 		return 0;
 	}
 
-	log_debug("lockd start VG %s lock_type %s",
-		  vg->name, vg->lock_type ? vg->lock_type : "empty");
+	log_debug("lockd start VG %s lock_type %s init %d",
+		  vg->name, vg->lock_type ? vg->lock_type : "empty", start_init);
 
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
 		return_0;
@@ -973,6 +977,7 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg)
 				"vg_uuid = %s", uuid[0] ? uuid : "none",
 				"version = %d", (int64_t)vg->seqno,
 				"host_id = %d", host_id,
+				"opts = %s", start_init ? "start_init" : "none",
 				NULL);
 
 	if (!_lockd_result(reply, &result, NULL)) {
@@ -2461,7 +2466,7 @@ int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int
 		 * Depending on the problem that caused the rename to
 		 * fail, it may make sense to not restart the VG here.
 		 */
-		if (!lockd_start_vg(cmd, vg))
+		if (!lockd_start_vg(cmd, vg, 0))
 			log_error("Failed to restart VG %s lockspace.", vg->name);
 		return 1;
 	}
@@ -2501,7 +2506,7 @@ int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int
 		}
 	}
 
-	if (!lockd_start_vg(cmd, vg))
+	if (!lockd_start_vg(cmd, vg, 1))
 		log_error("Failed to start VG %s lockspace.", vg->name);
 
 	return 1;
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 51c2905..7e6505d 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -62,7 +62,7 @@ int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int
 
 /* start and stop the lockspace for a vg */
 
-int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg);
+int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_init);
 int lockd_stop_vg(struct cmd_context *cmd, struct volume_group *vg);
 int lockd_start_wait(struct cmd_context *cmd);
 
@@ -147,7 +147,7 @@ static inline int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_g
 	return 1;
 }
 
-static inline int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg)
+static inline int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_init)
 {
 	return 0;
 }
diff --git a/tools/vgchange.c b/tools/vgchange.c
index a80b678..81e4bf3 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -878,7 +878,7 @@ static int _vgchange_lock_start(struct cmd_context *cmd, struct volume_group *vg
 	}
 
 do_start:
-	return lockd_start_vg(cmd, vg);
+	return lockd_start_vg(cmd, vg, 0);
 }
 
 static int _vgchange_lock_stop(struct cmd_context *cmd, struct volume_group *vg)
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 67b593d..fd79563 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -157,7 +157,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (is_lockd_type(vg->lock_type)) {
 		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
 
-		if (!lockd_start_vg(cmd, vg)) {
+		if (!lockd_start_vg(cmd, vg, 1)) {
 			log_error("Failed to start locking");
 			goto out;
 		}


