From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:56:12 -0500
Subject: master - vdo: enable dmeventd resize
Message-ID: <201901211156.x0LBuCHD024612@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f3c52a515b7b40a76d7dfc64b712020f032cde1d
Commit:        f3c52a515b7b40a76d7dfc64b712020f032cde1d
Parent:        3d367f3348da072360c9dd251d981e627c8444ff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 20 16:08:11 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:53:16 2019 +0100

vdo: enable dmeventd resize

---
 daemons/dmeventd/plugins/vdo/dmeventd_vdo.c |    3 +--
 lib/metadata/lv_manip.c                     |   20 +++++++++++++++++++-
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
index d5156cd..9d267eb 100644
--- a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
+++ b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
@@ -255,8 +255,7 @@ void process_event(struct dm_task *dmt,
 	} else
 		state->max_fails = 1; /* Reset on success */
 
-	/* FIXME: ATM nothing can be done, drop 0, once it becomes useful */
-	if (0 && needs_policy)
+	if (needs_policy)
 		_use_policy(dmt, state);
 out:
 	if (vdop.status)
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7e542fe..8c9a933 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4795,6 +4795,18 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 				 "minimum supported 50%%.", policy_threshold);
 			policy_threshold = 50;
 		}
+	} else if (lv_is_vdo_pool(lv)) {
+		policy_threshold =
+			find_config_tree_int(cmd, activation_vdo_pool_autoextend_threshold_CFG,
+					     lv_config_profile(lv));
+		policy_amount =
+			find_config_tree_int(cmd, activation_vdo_pool_autoextend_percent_CFG,
+					     lv_config_profile(lv));
+		if (policy_threshold < 50) {
+			log_warn("WARNING: VDO pool autoextend threshold %d%% is set below "
+				 "minimum supported 50%%.", policy_threshold);
+			policy_threshold = 50;
+		}
 	} else {
 		policy_threshold =
 			find_config_tree_int(cmd, activation_snapshot_autoextend_threshold_CFG, NULL);
@@ -4833,6 +4845,9 @@ static int _lvresize_adjust_policy(const struct logical_volume *lv,
 
 		if (!lv_thin_pool_percent(lv, 0, &percent))
 			return_0;
+	} else if (lv_is_vdo_pool(lv)) {
+		if (!lv_vdo_pool_percent(lv, &percent))
+			return_0;
 	} else {
 		if (!lv_snapshot_percent(lv, &percent))
 			return_0;
@@ -4916,7 +4931,10 @@ static int _lvresize_check(struct logical_volume *lv,
 		}
 	}
 
-	if (lp->use_policies && !lv_is_cow(lv) && !lv_is_thin_pool(lv)) {
+	if (lp->use_policies &&
+	    !lv_is_cow(lv) &&
+	    !lv_is_thin_pool(lv) &&
+	    !lv_is_vdo_pool(lv)) {
 		log_error("Policy-based resize is supported only for snapshot and thin pool volumes.");
 		return 0;
 	}


