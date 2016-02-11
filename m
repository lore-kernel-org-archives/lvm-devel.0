From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:56 +0000 (UTC)
Subject: master - cleanup: update messages
Message-ID: <20160211173956.97E0660365@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc23fdbd13a616010e54fa0491f5de9cee340fec
Commit:        cc23fdbd13a616010e54fa0491f5de9cee340fec
Parent:        5a32d2c1d95e5cdd1849fc979353a81edf972878
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 8 13:08:54 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:38:40 2016 +0100

cleanup: update messages

---
 lib/metadata/lv_manip.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d5105e1..d99d347 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4224,7 +4224,8 @@ static int _request_confirmation(const struct volume_group *vg,
 	if (lp->resizefs) {
 		if (!info.exists) {
 			log_error("Logical volume %s must be activated "
-				  "before resizing filesystem", lp->lv_name);
+				  "before resizing filesystem.",
+				  display_lvname(lv));
 			return 0;
 		}
 		return 1;
@@ -4233,7 +4234,7 @@ static int _request_confirmation(const struct volume_group *vg,
 	if (!info.exists)
 		return 1;
 
-	log_warn("WARNING: Reducing active%s logical volume to %s",
+	log_warn("WARNING: Reducing active%s logical volume to %s.",
 		 info.open_count ? " and open" : "",
 		 display_size(vg->cmd, (uint64_t) lp->extents * vg->extent_size));
 
@@ -4241,8 +4242,9 @@ static int _request_confirmation(const struct volume_group *vg,
 
 	if (!lp->ac_force) {
 		if (yes_no_prompt("Do you really want to reduce %s? [y/n]: ",
-				  lp->lv_name) == 'n') {
-			log_error("Logical volume %s NOT reduced", lp->lv_name);
+				  display_lvname(lv)) == 'n') {
+			log_error("Logical volume %s NOT reduced",
+				  display_lvname(lv));
 			return 0;
 		}
 		if (sigint_caught())
@@ -4315,13 +4317,13 @@ static int _adjust_amount(dm_percent_t percent, int policy_threshold, int *polic
 {
 	if (!(DM_PERCENT_0 < percent && percent <= DM_PERCENT_100) ||
 	    percent <= (policy_threshold * DM_PERCENT_1))
-		return 0;
+		return 0; /* nothing to do */
 	/*
 	 * Evaluate the minimal amount needed to get bellow threshold.
 	 * Keep using DM_PERCENT_1 units for better precision.
 	 * Round-up to needed percentage value
 	 */
-	percent = (percent/policy_threshold + (DM_PERCENT_1 - 1) / 100) / (DM_PERCENT_1 / 100) - 100;
+	percent = (percent / policy_threshold + (DM_PERCENT_1 - 1) / 100) / (DM_PERCENT_1 / 100) - 100;
 
 	/* Use it if current policy amount is smaller */
 	if (*policy_amount < percent)


