From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jan 2016 12:53:54 +0000 (UTC)
Subject: master - cleanup: update check function
Message-ID: <20160120125354.B9F6560D1E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=178cbb580a9c07b777a2abf1e82d250310531e86
Commit:        178cbb580a9c07b777a2abf1e82d250310531e86
Parent:        4b9ae55a8d691eb15d34dce74f00230bd2423c5b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 15 14:41:02 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 20 13:44:47 2016 +0100

cleanup: update check function

Use display_lvname().
Use lv_is_lockd_sanlock_lv().
Order  'error' checks ahead of 'ignore' ones.
---
 lib/metadata/lv_manip.c |   54 ++++++++++++++++++++++++----------------------
 1 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1975c83..13e088c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4614,7 +4614,8 @@ static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv
 		 * Since external-origin can be activated read-only,
 		 * there is no way to use extended areas.
 		 */
-		log_error("Cannot resize external origin \"%s\".", lv->name);
+		log_error("Cannot resize external origin logical volume %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -4626,47 +4627,31 @@ static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv
 	}
 
 	if (lv_is_raid_with_tracking(lv)) {
-		log_error("Cannot resize %s while it is tracking a split image",
-			  lv->name);
+		log_error("Cannot resize logical volume %s while it is "
+			  "tracking a split image.", display_lvname(lv));
 		return 0;
 	}
 
-	if (lp->ac_stripes) {
-		if (vg->fid->fmt->features & FMT_SEGMENTS)
-			lp->stripes = lp->ac_stripes_value;
-		else
-			log_print_unless_silent("Varied striping not supported. Ignoring.");
-	}
-
-	if (lp->ac_mirrors) {
-		if (vg->fid->fmt->features & FMT_SEGMENTS)
-			lp->mirrors = lp->ac_mirrors_value;
-		else
-			log_print_unless_silent("Mirrors not supported. Ignoring.");
-	}
-
-	if (lp->ac_stripesize && !_validate_stripesize(cmd, vg, lp))
-		return_0;
-
 	if (lp->ac_policy && !lv_is_cow(lv) && !lv_is_thin_pool(lv)) {
 		log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
 		return 0;
 	}
 
-	/* FIXME: use a status flag instead of the name "lvmlock". */
-
-	if (!lv_is_visible(lv) && !lv_is_thin_pool_metadata(lv) && strcmp(lv->name, "lvmlock")) {
-		log_error("Can't resize internal logical volume %s", lv->name);
+	if (!lv_is_visible(lv) &&
+	    !lv_is_thin_pool_metadata(lv) &&
+	    !lv_is_lockd_sanlock_lv(lv)) {
+		log_error("Can't resize internal logical volume %s.", display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_locked(lv)) {
-		log_error("Can't resize locked LV %s", lv->name);
+		log_error("Can't resize locked logical volume %s.", display_lvname(lv));
 		return 0;
 	}
 
 	if (lv_is_converting(lv)) {
-		log_error("Can't resize %s while lvconvert in progress", lv->name);
+		log_error("Can't resize logical volume %s while "
+			  "lvconvert in progress.", display_lvname(lv));
 		return 0;
 	}
 
@@ -4675,6 +4660,23 @@ static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv
 		return 0;
 	}
 
+	if (lp->ac_stripesize && !_validate_stripesize(cmd, vg, lp))
+		return_0;
+
+	if (lp->ac_stripes) {
+		if (!(vg->fid->fmt->features & FMT_SEGMENTS))
+			log_print_unless_silent("Varied striping not supported. Ignoring.");
+		else
+			lp->stripes = lp->ac_stripes_value;
+	}
+
+	if (lp->ac_mirrors) {
+		if (!(vg->fid->fmt->features & FMT_SEGMENTS))
+			log_print_unless_silent("Mirrors not supported. Ignoring.");
+		else
+			lp->mirrors = lp->ac_mirrors_value;
+	}
+
 	return 1;
 }
 


