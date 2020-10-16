From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:46 +0000 (GMT)
Subject: stable-2.02 - activation: use revert_lv on tree suspend failure
Message-ID: <20201016191146.51651396EC5D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5726b93709890ddc6f9f08a28ca1e835b2c05a3b
Commit:        5726b93709890ddc6f9f08a28ca1e835b2c05a3b
Parent:        05ba12350c8530395d675538b8b3b741274e041d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 13:35:27 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

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
index 125e094ee..8b6f8965c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Use revert_lv() on reload error path after vg_revert().
   Improve estimation of needed extents when creating thin-pool.
   Use extra 1% when resizing thin-pool metadata LV with --use-policy.
   Enhance --use-policy percentage rounding.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 50269acd1..3f3adafba 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2542,6 +2542,9 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 			      lv_is_thin_volume(lv) ? " thin only" : " without snapshots") : "",
 			     laopts->revert ? " (reverting)" : "");
 
+	if (laopts->revert)
+		goto needs_resume;
+
 	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 63ed182bd..1bed4f525 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6448,6 +6448,10 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 		log_error("Failed to lock logical volume %s.",
 			  display_lvname(lock_lv));
 		vg_revert(vg);
+		if (!revert_lv(vg->cmd, lock_lv))
+			log_error("Failed to revert logical volume %s.",
+				  display_lvname(lock_lv));
+		return 0;
 	} else if (!(r = vg_commit(vg)))
 		stack; /* !vg_commit() has implict vg_revert() */
 	else


