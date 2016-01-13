From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 13 Jan 2016 22:40:33 +0000 (UTC)
Subject: master - vgchange: fix lockd_gl results
Message-ID: <20160113224033.CCF8260E28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9e9c7575413dca7a1ac7a5f363d1c7a464f86c3d
Commit:        9e9c7575413dca7a1ac7a5f363d1c7a464f86c3d
Parent:        1b1f42b49005665e669b52f78864cad59d81f64b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 13 15:55:41 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 13 16:40:02 2016 -0600

vgchange: fix lockd_gl results

The wrong error value was being checked from lockd_gl()
in two cases.

Clarify the use of lockd_gl() in the lock-start case.
---
 tools/vgchange.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 62e602a..6cbb042 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1046,11 +1046,26 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, lockstop_ARG))
 		cmd->lockd_vg_default_sh = 1;
 
-	/* Starting a vg lockspace means there are no locks available yet. */
-
-	if (arg_is_set(cmd, lockstart_ARG))
+	/*
+	 * Starting lockspaces.  For VGs not yet started, locks are not
+	 * available to acquire, and for VGs already started, there's nothing
+	 * to do, so disable VG locks.  Try to acquire the global lock sh to
+	 * validate the cache (if no gl is available, lockd_gl will force a
+	 * cache validation).  If the global lock is available, it can be
+	 * benficial to hold sh to serialize lock-start with vgremove of the
+	 * same VG from another host.
+	 */
+	if (arg_is_set(cmd, lockstart_ARG)) {
 		cmd->lockd_vg_disable = 1;
 
+		if (!lockd_gl(cmd, "sh", 0))
+			log_debug("No global lock for lock start");
+
+		/* Disable the lockd_gl in process_each_vg. */
+		cmd->lockd_gl_disable = 1;
+		return 1;
+	}
+
 	/*
 	 * Changing system_id or lock_type must only be done on explicitly
 	 * named vgs.
@@ -1059,17 +1074,7 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, systemid_ARG) || arg_is_set(cmd, locktype_ARG))
 		cmd->command->flags &= ~ALL_VGS_IS_DEFAULT;
 
-	if (arg_is_set(cmd, lockstart_ARG)) {
-		/*
-		 * The lockstart condition takes the global lock to serialize
-		 * with any other host that tries to remove the VG while this
-		 * tries to start it.  (Zero argc means all VGs, in wich case
-		 * process_each_vg will acquire the global lock.)
-		 */
-		if (argc && !lockd_gl(cmd, "sh", 0))
-			return_ECMD_FAILED;
-
-	} else if (arg_is_set(cmd, systemid_ARG) || arg_is_set(cmd, locktype_ARG)) {
+	if (arg_is_set(cmd, systemid_ARG) || arg_is_set(cmd, locktype_ARG)) {
 		/*
 		 * This is a special case where taking the global lock is
 		 * not needed to protect global state, because the change is
@@ -1079,7 +1084,7 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 		 * lock_type.
 		 */
 		if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
-			return_ECMD_FAILED;
+			return 0;
 	}
 
 	return 1;


