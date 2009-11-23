From: Milan Broz <mbroz@redhat.com>
Date: Mon, 23 Nov 2009 12:52:50 +0100
Subject: [PATCH] Return error status if vgchange fails to activate some volume.
Message-ID: <1258977170-9080-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I know that there is ongoing discussion about that,
but in cluster we have now this situation
(on one node a storage connection failed):

# vgchange -a y vg_bar ; echo $?
  Error locking on node bar-02: Refusing activation of partial LV lv1. Use --partial to override.
    1 logical volume(s) in volume group "vg_bar" now active
    0

So activation fails on one node, error is correctly printed but
status code is wrong.

This patch fixes the top level (vgchange) to return proper code
(and print # of activated LVs).

N.B. unification of lvchange/vgchange and fixing the low level
(unroll the transaction if anything failed) is still to be solved.

But I think this trivial solution can be used for short term.
(lvchange returns error properly here.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/vgchange.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 80ac6e7..f791e53 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -56,7 +56,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 {
 	struct lv_list *lvl;
 	struct logical_volume *lv;
-	int count = 0;
+	int count = 0, expected_count = 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
@@ -78,6 +78,8 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 		    ((lv->status & PVMOVE) ))
 			continue;
 
+		expected_count++;
+
 		if (activate == CHANGE_AN) {
 			if (!deactivate_lv(cmd, lv))
 				continue;
@@ -100,7 +102,12 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd,
 		count++;
 	}
 
-	return count;
+	if (expected_count)
+		log_verbose("%s %d logical volumes in volume group %s",
+			    activate ? "Activated" : "Deactivated",
+			    count, vg->name);
+
+	return (expected_count != count) ? ECMD_FAILED : ECMD_PROCESSED;
 }
 
 static int _vgchange_monitoring(struct cmd_context *cmd, struct volume_group *vg)
@@ -121,7 +128,7 @@ static int _vgchange_monitoring(struct cmd_context *cmd, struct volume_group *vg
 static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 {
 	int lv_open, active, monitored;
-	int available;
+	int available, ret;
 	int activate = 1;
 
 	/*
@@ -158,17 +165,11 @@ static int _vgchange_available(struct cmd_context *cmd, struct volume_group *vg)
 		}
 	}
 
-	if (activate && _activate_lvs_in_vg(cmd, vg, available))
-		log_verbose("Activated logical volumes in "
-			    "volume group \"%s\"", vg->name);
-
-	if (!activate && _activate_lvs_in_vg(cmd, vg, available))
-		log_verbose("Deactivated logical volumes in "
-			    "volume group \"%s\"", vg->name);
+	ret = _activate_lvs_in_vg(cmd, vg, available);
 
 	log_print("%d logical volume(s) in volume group \"%s\" now active",
 		  lvs_in_vg_activated(vg), vg->name);
-	return ECMD_PROCESSED;
+	return ret;
 }
 
 static int _vgchange_alloc(struct cmd_context *cmd, struct volume_group *vg)
-- 
1.6.5.3


