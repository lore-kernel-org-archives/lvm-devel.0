From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:16 +0000 (UTC)
Subject: master - lib: better reporting of threshold
Message-ID: <20151022213316.31E9660DEE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19e272ba53a51a0f3103e1d5e04d06b6207f0acc
Commit:        19e272ba53a51a0f3103e1d5e04d06b6207f0acc
Parent:        73e679f33f411c65c9b7c7e4e501d97245f0bf5d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 10:46:39 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:06:14 2015 +0200

lib: better reporting of threshold

Simplify code reporting warning about incorrect thresholds.
---
 lib/metadata/lv_manip.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7a3d9b9..316710b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4433,23 +4433,34 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 	if (lv_is_thin_pool(lv)) {
 		policy_threshold =
 			find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG,
-					     lv_config_profile(lv)) * DM_PERCENT_1;
+					     lv_config_profile(lv));
 		policy_amount =
 			find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG,
 					     lv_config_profile(lv));
-		if (!policy_amount && policy_threshold < DM_PERCENT_100) {
-			log_error("Can't extend thin pool %s, autoextend is set to 0%%.",
-				  display_lvname(lv));
-			return 0;
+		if (policy_threshold < 50) {
+			log_warn("WARNING: Thin pool autoextend threshold %d%% is set bellow "
+				 "minimal supported value 50%%.", policy_threshold);
+			policy_threshold = 50;
 		}
 	} else {
 		policy_threshold =
-			find_config_tree_int(cmd, activation_snapshot_autoextend_threshold_CFG, NULL) * DM_PERCENT_1;
+			find_config_tree_int(cmd, activation_snapshot_autoextend_threshold_CFG, NULL);
 		policy_amount =
 			find_config_tree_int(cmd, activation_snapshot_autoextend_percent_CFG, NULL);
+		if (policy_threshold < 50) {
+			log_warn("WARNING: Snapshot autoextend threshold %d%% is set bellow "
+				 "minimal supported value 50%%.", policy_threshold);
+			policy_threshold = 50;
+		}
 	}
 
-	if (policy_threshold >= DM_PERCENT_100)
+	if (!policy_amount && policy_threshold < 100) {
+		log_error("Can't extend %s with %s autoextend percent set to 0%%.",
+			  display_lvname(lv),  first_seg(lv)->segtype->name);
+		return 0;
+	}
+
+	if (policy_threshold >= 100)
 		return 1; /* nothing to do */
 
 	if (!lv_is_active_locally(lv)) {
@@ -4458,6 +4469,8 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 		return 0;
 	}
 
+	policy_threshold *= DM_PERCENT_1;
+
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, 1, &percent))
 			return_0;


