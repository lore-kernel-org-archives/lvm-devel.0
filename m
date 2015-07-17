From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Jul 2015 20:35:40 +0000 (UTC)
Subject: master - vgchange/lvchange: enforce the shared VG lock from lvmlockd
Message-ID: <20150717203540.BAFF060066@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b4be988732e909d34ae7b4868bf30cf44c087518
Commit:        b4be988732e909d34ae7b4868bf30cf44c087518
Parent:        b785a50da415cd8ee48e971f720640457514032d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 17 15:13:22 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 17 15:35:34 2015 -0500

vgchange/lvchange: enforce the shared VG lock from lvmlockd

The vgchange/lvchange activation commands read the VG, and
don't write it, so they acquire a shared VG lock from lvmlockd.
When other commands fail to acquire a shared VG lock from
lvmlockd, a warning is printed and they continue without it.
(Without it, the VG metadata they display from lvmetad may
not be up to date.)

vgchange/lvchange -a shouldn't continue without the shared
lock for a couple reasons:

. Usually they will just continue on and fail to acquire the
  LV locks for activation, so continuing is pointless.

. More importantly, without the sh VG lock, the VG metadata
  used by the command may be stale, and the LV locks shown
  in the VG metadata may no longer be current.  In the
  case of sanlock, this would result in odd, unpredictable
  errors when lvmlockd doesn't find the expected lock on
  disk.  In the case of dlm, the invalid LV lock could be
  granted for the non-existing LV.

The solution is to not continue after the shared lock fails,
in the same way that a command fails if an exclusive lock fails.
---
 lib/commands/toolcontext.h |    1 +
 lib/metadata/metadata.c    |    2 +-
 tools/lvchange.c           |    4 +++-
 tools/vgchange.c           |    4 +++-
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 283783f..4e8998d 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -107,6 +107,7 @@ struct cmd_context {
 	unsigned lockd_vg_disable:1;
 	unsigned lockd_lv_disable:1;
 	unsigned lockd_vg_default_sh:1;
+	unsigned lockd_vg_enforce_sh:1;
 
 	struct dev_types *dev_types;
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 56ed3fb..8757331 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4803,7 +4803,7 @@ static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg
 	 * no lock.
 	 */
 	if (lockd_state & LDST_FAIL) {
-		if (lockd_state & LDST_EX) {
+		if ((lockd_state & LDST_EX) || cmd->lockd_vg_enforce_sh) {
 			log_error("Cannot access VG %s due to failed lock.", vg->name);
 			*failure |= FAILED_LOCK_MODE;
 			return 0;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 58e0fb2..823c36a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1294,8 +1294,10 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	 * are cases where lvchange does not modify the vg, so they can use
 	 * the sh lock mode.
 	 */
-	if (arg_count(cmd, activate_ARG) || arg_count(cmd, refresh_ARG))
+	if (arg_count(cmd, activate_ARG) || arg_count(cmd, refresh_ARG)) {
 		cmd->lockd_vg_default_sh = 1;
+		cmd->lockd_vg_enforce_sh = 1;
+	}
 
 	return process_each_lv(cmd, argc, argv,
 			       update ? READ_FOR_UPDATE : 0, NULL,
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 9612222..824fd91 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1017,8 +1017,10 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return 0;
 	}
 
-	if (arg_is_set(cmd, activate_ARG) || arg_is_set(cmd, refresh_ARG))
+	if (arg_is_set(cmd, activate_ARG) || arg_is_set(cmd, refresh_ARG)) {
 		cmd->lockd_vg_default_sh = 1;
+		cmd->lockd_vg_enforce_sh = 1;
+	}
 
 	/* Starting a vg lockspace means there are no locks available yet. */
 


