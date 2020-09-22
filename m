From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Sep 2020 21:46:44 +0000 (GMT)
Subject: master - activation: use revert_lv on tree suspend failure
Message-ID: <20200922214644.C5416385780B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5bc66532c70ea2e820b92eb65e0dd21f8caa3394
Commit:        5bc66532c70ea2e820b92eb65e0dd21f8caa3394
Parent:        bc9bb534ff1bfaa8790b871a7ecd2d75bd0824f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 13:35:27 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 21:02:14 2020 +0200

activation: use revert_lv on tree suspend failure

When thetable reload fails during suspend() - we were only calling
plain resume() - and this will reload only those devices,
which were left suspend, but will not try to restore
metadata state according to lvm2 reverted metadata.
So if we were reloading device tree - we have restored
only top-level LV and rest of reverted device manipulation
were left alone and possibly mismatched what is in committed
metadata.

FIXME: There are several cases were such revert will likely not work
properly anyway as some operation are currenly handled in single commit,
while they need multiple commits, but it's step towards better correctness.
At least we catch there errors now earlier.
---
 WHATS_NEW               | 1 +
 lib/activate/activate.c | 3 +++
 lib/metadata/lv_manip.c | 4 ++++
 3 files changed, 8 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0f6412fc5..4be9b8bad 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Use revert_lv() on reload error path after vg_revert().
   Configure --with-integrity enabled.
   Restore lost signal blocking while VG lock is held.
   Improve estimation of needed extents when creating thin-pool.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 0c6bd1a9a..a9a01a8bc 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2322,6 +2322,9 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 			      lv_is_thin_volume(lv) ? " thin only" : " without snapshots") : "",
 			     laopts->revert ? " (reverting)" : "");
 
+	if (laopts->revert)
+		goto needs_resume;
+
 	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 063ff3e03..6ac6a602b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6858,6 +6858,10 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 		log_error("Failed to suspend logical volume %s.",
 			  display_lvname(lock_lv));
 		vg_revert(vg);
+		if (!revert_lv(vg->cmd, lock_lv))
+			log_error("Failed to revert logical volume %s.",
+				  display_lvname(lock_lv));
+		return 0;
 	} else if (!(r = vg_commit(vg)))
 		stack; /* !vg_commit() has implict vg_revert() */
 	else


