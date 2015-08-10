From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 10 Aug 2015 18:08:34 +0000 (UTC)
Subject: master - vgremove: fix locking when lvmlockd global lock is removed
Message-ID: <20150810180834.71C5660297@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1aa7fa354e6ed3e468dc7966f5df0009627b2b97
Commit:        1aa7fa354e6ed3e468dc7966f5df0009627b2b97
Parent:        5383697c784de5af5438bb09ea8ebb57b4a47418
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 10 13:04:11 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 10 13:04:11 2015 -0500

vgremove: fix locking when lvmlockd global lock is removed

When vgremove is used to remove multiple VGs in one command,
e.g. vgremove foo bar, the first VG (foo) that is removed
may have held the sanlock global lock.  In this case,
do not continue removing further VGs (bar) without the
global lock.
---
 lib/commands/toolcontext.h |    1 +
 lib/locking/lvmlockd.c     |   28 +++++++++++++++++++++++++++-
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index ec2242d..0440163 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -133,6 +133,7 @@ struct cmd_context {
 	unsigned lockd_gl_disable:1;
 	unsigned lockd_vg_disable:1;
 	unsigned lockd_lv_disable:1;
+	unsigned lockd_gl_removed:1;
 	unsigned lockd_vg_default_sh:1;
 	unsigned lockd_vg_enforce_sh:1;
 
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 7f14a86..5918de3 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -739,6 +739,19 @@ static int _free_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 	if (!_lvmlockd_connected)
 		return 0;
 
+	/*
+	 * vgremove originally held the global lock, but lost it because the
+	 * vgremove command is removing multiple VGs, and removed the VG
+	 * holding the global lock before attempting to remove this VG.
+	 * To avoid this situation, the user should remove the VG holding
+	 * the global lock in a command by itself, or as the last arg in a
+	 * vgremove command that removes multiple VGs.
+	 */
+	if (cmd->lockd_gl_removed) {
+		log_error("Global lock failed: global lock was lost by removing a previous VG.");
+		return 0;
+	}
+
 	if (!vg->lock_args || !strlen(vg->lock_args)) {
 		/* Shouldn't happen in general, but maybe in some error cases? */
 		log_debug("_free_vg_sanlock %s no lock_args", vg->name);
@@ -773,8 +786,21 @@ static int _free_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 		goto out;
 	}
 
-	if (lockd_flags & LD_RF_WARN_GL_REMOVED)
+	/*
+	 * If the global lock was been removed by removing this VG, then:
+	 *
+	 * Print a warning indicating that the global lock should be enabled
+	 * in another remaining sanlock VG.
+	 *
+	 * Do not allow any more VGs to be removed by this command, e.g.
+	 * if a command removes two sanlock VGs, like vgremove foo bar,
+	 * and the global lock existed in foo, do not continue to remove
+	 * VG bar without the global lock.  See the corresponding check above.
+	 */
+	if (lockd_flags & LD_RF_WARN_GL_REMOVED) {
 		log_warn("VG %s held the sanlock global lock, enable global lock in another VG.", vg->name);
+		cmd->lockd_gl_removed = 1;
+	}
 
 	/*
 	 * The usleep delay gives sanlock time to close the lock lv,


