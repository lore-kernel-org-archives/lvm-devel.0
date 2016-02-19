From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Feb 2016 10:27:39 +0000 (UTC)
Subject: master - thin: fix update_pool_lv error path
Message-ID: <20160219102739.6E68D60DEA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eefcbd5b28aae6c0bed22a6ff8cb97141184083f
Commit:        eefcbd5b28aae6c0bed22a6ff8cb97141184083f
Parent:        04ab1fa572bbc6751463b137576bc733ec27b2ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 19 11:18:41 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 19 11:25:56 2016 +0100

thin: fix update_pool_lv error path

When update fails in suspend() (sending of messages
fails because metadata space is full) call resume(),
so the locking sequence works properly for clustering.

Also failing deactivation should unlock memory.
---
 WHATS_NEW                 |    1 +
 lib/metadata/thin_manip.c |   20 +++++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8d9294b..654f0a1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.143 -
 =====================================
+  Fix error path when sending thin-pool message fails in update_pool_lv().
   Support reporting CheckNeeded and Fail state for thin-pool and thin LV.
   For failing thin-pool and thin volume correctly report percentage as INVALID.
   Report -1, not 'unkown' for lv_{snapshot_invalid,merge_failed} with --binary.
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 2886259..de3c7e8 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -469,16 +469,22 @@ int update_pool_lv(struct logical_volume *lv, int activate)
 
 		if (!(ret = _check_pool_create(lv)))
 			stack; /* Safety guard, needs local presence of thin-pool target */
-		else if (!(ret = suspend_lv_origin(lv->vg->cmd, lv)))
-			/* Send messages */
-			log_error("Failed to suspend and send message %s.", display_lvname(lv));
-		else if (!(ret = resume_lv_origin(lv->vg->cmd, lv)))
-			log_error("Failed to resume %s.", display_lvname(lv));
+		else {
+			if (!(ret = suspend_lv_origin(lv->vg->cmd, lv)))
+				/* Send messages */
+				log_error("Failed to suspend %s with queued messages.", display_lvname(lv));
+
+			/* Even failing suspend needs resume */
+			if (!resume_lv_origin(lv->vg->cmd, lv)) {
+				log_error("Failed to resume %s.", display_lvname(lv));
+				ret = 0;
+			}
+		}
 
 		if (activate) {
 			if (!deactivate_lv(lv->vg->cmd, lv)) {
-				init_dmeventd_monitor(monitored);
-				return_0;
+				log_error("Failed to deactivate %s.", display_lvname(lv));
+				ret = 0;
 			}
 			init_dmeventd_monitor(monitored);
 		}


