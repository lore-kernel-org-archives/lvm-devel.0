From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 25 Oct 2015 20:09:56 +0000 (UTC)
Subject: master - lv_manip: ensure it will fit bellow threshold
Message-ID: <20151025200956.C3D4C60E5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40eea582aea512db7fceafd8559bf66df0733b55
Commit:        40eea582aea512db7fceafd8559bf66df0733b55
Parent:        b780d329aa9ce249bf5164154c81cefd9b276970
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 19:19:39 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 21:03:11 2015 +0100

lv_manip: ensure it will fit bellow threshold

Use single code to evaluate if the percentage value has
crossed threshold.

Recalculate amount value to always fit bellow
threshold so there are not need any extra reiterations
to reach this state in case policy amount is too small.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   37 +++++++++++++++++++++++++------------
 2 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0495e46..8ca0aa7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Ensure --use-policy will resize volume to fit below threshold.
   Correct percentage evaluation when checking thin-pool over threshold.
   Fix lvmcache to move PV from VG to orphans if VG is removed and lvmetad used.
   Fix lvmcache to not cache even invalid info about PV which got removed.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 19032e9..8029dab 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4424,6 +4424,25 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 	return exec_cmd(cmd, argv, status, 1);
 }
 
+static int _adjust_amount(dm_percent_t percent, int policy_threshold, int *policy_amount)
+{
+	if (!(DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) ||
+	    percent <= (policy_threshold * DM_PERCENT_1))
+		return 0;
+	/*
+	 * Evaluate the minimal amount needed to get bellow threshold.
+	 * Keep using DM_PERCENT_1 units for better precision.
+	 * Round-up to needed percentage value
+	 */
+	percent = (percent/policy_threshold + (DM_PERCENT_1 - 1) / 100) / (DM_PERCENT_1 / 100) - 100;
+
+	/* Use it if current policy amount is smaller */
+	if (*policy_amount < percent)
+		*policy_amount = percent;
+
+	return 1;
+}
+
 static int _adjust_policy_params(struct cmd_context *cmd,
 				 struct logical_volume *lv, struct lvresize_params *lp)
 {
@@ -4469,35 +4488,29 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 		return 0;
 	}
 
-	policy_threshold *= DM_PERCENT_1;
-
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, 1, &percent))
 			return_0;
-		if ((DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) &&
-		    (percent > policy_threshold)) {
+		if (_adjust_amount(percent, policy_threshold, &policy_amount)) {
 			if (!thin_pool_feature_supported(lv, THIN_FEATURE_METADATA_RESIZE)) {
-				log_error_once("Online metadata resize for %s/%s is not supported.",
-					       lv->vg->name, lv->name);
+				log_error_once("Online metadata resize for %s is not supported.",
+					       display_lvname(lv));
 				return 0;
 			}
 			lp->poolmetadatasize = (first_seg(lv)->metadata_lv->size *
 						policy_amount + 99) / 100;
 			lp->poolmetadatasign = SIGN_PLUS;
 		}
-
 		if (!lv_thin_pool_percent(lv, 0, &percent))
 			return_0;
-		if (!(DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) ||
-		    percent <= policy_threshold)
-			return 1;
 	} else {
 		if (!lv_snapshot_percent(lv, &percent))
 			return_0;
-		if (!(DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) || percent <= policy_threshold)
-			return 1; /* nothing to do */
 	}
 
+	if (!_adjust_amount(percent, policy_threshold, &policy_amount))
+		return 1; /* nothing to do */
+
 	lp->extents = policy_amount;
 	lp->sizeargs = (lp->extents) ? 1 : 0;
 


