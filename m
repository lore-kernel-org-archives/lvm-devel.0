From: David Teigland <teigland@sourceware.org>
Date: Tue, 24 Sep 2019 16:56:08 -0400
Subject: master - writecache: allow removing LV with attached writecache
Message-ID: <201909242056.x8OKu8eE015866@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=26596ce7faf1cd8b0aa4b199fa917fb14eace666
Commit:        26596ce7faf1cd8b0aa4b199fa917fb14eace666
Parent:        76dd9b2b518e85a4fecbc752424a8a0f36616838
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 24 15:33:09 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 24 15:51:05 2019 -0500

writecache: allow removing LV with attached writecache

---
 lib/metadata/lv_manip.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f404555..21d21ca 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1599,11 +1599,6 @@ int lv_reduce(struct logical_volume *lv, uint32_t extents)
 {
 	struct lv_segment *seg = first_seg(lv);
 
-	if (lv_is_writecache(lv)) {
-		log_error("Remove not yet allowed on LVs with writecache attached.");
-		return 0;
-	}
-
 	/* Ensure stripe boundary extents on RAID LVs */
 	if (lv_is_raid(lv) && extents != lv->le_count)
 		extents =_round_to_stripe_boundary(lv->vg, extents,
@@ -6318,6 +6313,25 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
+	if (lv_is_writecache(lv)) {
+		struct logical_volume *cachevol_lv = first_seg(lv)->writecache;
+
+		if (!deactivate_lv(cmd, lv)) {
+			log_error("Failed to deactivate LV %s", display_lvname(lv));
+			return 0;
+		}
+
+		if (!lv_detach_writecache_cachevol(lv, 1)) {
+			log_error("Failed to detach writecache from %s", display_lvname(lv));
+			return 0;
+		}
+
+		if (!lv_remove_single(cmd, cachevol_lv, force, suppress_remove_message)) {
+			log_error("Failed to remove cachevol %s.", display_lvname(cachevol_lv));
+			return 0;
+		}
+	}
+
 	if (!lv_is_historical(lv) && (force == PROMPT) && ask_discard &&
 	    yes_no_prompt("Do you really want to remove and DISCARD "
 			  "logical volume %s? [y/n]: ",


