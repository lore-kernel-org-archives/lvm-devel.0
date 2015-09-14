From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Sep 2015 18:20:42 +0000 (UTC)
Subject: master - thin: show message on error path
Message-ID: <20150914182042.1392B60CF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ffeeb5c1e70e554defa45ee8aa28dcaeb47c705f
Commit:        ffeeb5c1e70e554defa45ee8aa28dcaeb47c705f
Parent:        c356991fa83b15af261e8d7e33f5615397c07778
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 14 12:58:21 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 20:18:54 2015 +0200

thin: show message on error path

Add missing log_error and show proper reason for failure
when autoextend is set to 0.

Add missing log_error when checked LV is not locally active.
---
 lib/metadata/lv_manip.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f43d281..46213fe 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4405,8 +4405,11 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 		policy_amount =
 			find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG,
 					     lv_config_profile(lv));
-		if (!policy_amount && policy_threshold < DM_PERCENT_100)
-                        return 0;
+		if (!policy_amount && policy_threshold < DM_PERCENT_100) {
+			log_error("Can't extend thin pool %s, autoextend is set to 0%%.",
+				  display_lvname(lv));
+			return 0;
+		}
 	} else {
 		policy_threshold =
 			find_config_tree_int(cmd, activation_snapshot_autoextend_threshold_CFG, NULL) * DM_PERCENT_1;
@@ -4417,6 +4420,12 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 	if (policy_threshold >= DM_PERCENT_100)
 		return 1; /* nothing to do */
 
+	if (!lv_is_active_locally(lv)) {
+		log_error("Can't read state of locally inactive LV %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	if (lv_is_thin_pool(lv)) {
 		if (!lv_thin_pool_percent(lv, 1, &percent))
 			return_0;


