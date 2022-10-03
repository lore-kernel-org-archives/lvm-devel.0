From: David Teigland <teigland@sourceware.org>
Date: Mon,  3 Oct 2022 17:42:11 +0000 (GMT)
Subject: main - lvresize: move the lockd_lv earlier
Message-ID: <20221003174211.A4EC13858299@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a23588d77cb1585e642946fe84c3eaafe7e2d270
Commit:        a23588d77cb1585e642946fe84c3eaafe7e2d270
Parent:        599cbd7dd37ba50b44579f64207cc1e47e004899
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 30 12:16:32 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 3 12:42:02 2022 -0500

lvresize: move the lockd_lv earlier

the lock should cover any potential activation,
not just the resizing changes
---
 lib/metadata/lv_manip.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 99045c220..d6452e849 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6814,6 +6814,13 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
+	/*
+	 * If the LV is locked due to being active, this lock call is a no-op.
+	 * Otherwise, this acquires a transient lock on the lv (not PERSISTENT)
+	 */
+	if (!lockd_lv_resize(cmd, lv_top, "ex", 0, lp))
+		return_0;
+
 	/*
 	 * Active 'hidden' -tpool can be waiting for resize, but the pool LV
 	 * itself might be inactive.  Here plain suspend/resume would not work.
@@ -6909,13 +6916,6 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	if (is_reduce && !lp->fsopt[0] && !_lv_reduce_confirmation(lv_top, lp))
 		goto_out;
 
-	/*
-	 * If the LV is locked due to being active, this lock call is a no-op.
-	 * Otherwise, this acquires a transient lock on the lv (not PERSISTENT)
-	 */
-	if (!lockd_lv_resize(cmd, lv_top, "ex", 0, lp))
-		goto_out;
-
 	/* Part of old approach to fs handling using fsadm.  */
 	if (!strcmp(lp->fsopt, "resize_fsadm") && !lp->nofsck &&
 	    !_fsadm_cmd(FSADM_CMD_CHECK, lv_top, 0, lp->yes, lp->force, &status)) {

