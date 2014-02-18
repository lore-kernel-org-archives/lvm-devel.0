From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Feb 2014 20:28:25 +0000 (UTC)
Subject: master - cleanup: use is_change_activating
Message-ID: <20140218202825.39C8E60CAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6fd16f8ea5e859925268838dba9341527c91a4c
Commit:        e6fd16f8ea5e859925268838dba9341527c91a4c
Parent:        fb519c35bbfae24a26346faf2b90d2a4189e8562
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 18 20:52:17 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 18 21:21:59 2014 +0100

cleanup: use is_change_activating

Use a single inline function to detect activation/deactivation
---
 lib/metadata/lv_manip.c |    7 +++----
 tools/lvcreate.c        |    2 +-
 tools/toollib.c         |    5 ++---
 tools/vgchange.c        |   16 ++++++----------
 4 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c2cc590..d0ae11e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6088,10 +6088,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			return NULL;
 		}
 
-		if (lv_is_active(lvl->lv) ||
-		    ((lp->activate != CHANGE_AN) && (lp->activate != CHANGE_ALN)))
-			if (!update_pool_lv(lvl->lv, 1))
-				return_NULL;
+		if ((lv_is_active(lvl->lv) || is_change_activating(lp->activate)) &&
+		    !update_pool_lv(lvl->lv, 1))
+			return_NULL;
 
 		/* For thin snapshot we must have matching pool */
 		if (org && lv_is_thin_volume(org) && (!lp->pool ||
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 67ea8c6..7e61203 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -724,7 +724,7 @@ static int _read_activation_params(struct lvcreate_params *lp,
 	lp->activate = (activation_change_t)
 		arg_uint_value(cmd, activate_ARG, CHANGE_AY);
 
-	if (lp->activate == CHANGE_AN || lp->activate == CHANGE_ALN) {
+	if (!is_change_activating(lp->activate)) {
 		if (lp->zero && !seg_is_thin(lp)) {
 			log_error("--activate n requires --zero n");
 			return 0;
diff --git a/tools/toollib.c b/tools/toollib.c
index 7deb3a4..9662aa8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1404,7 +1404,7 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		 * deactivation of origin, which is the only visible LV
 		 */
 		if (!deactivate_lv(cmd, find_snapshot(lv)->lv)) {
-			if ((activate != CHANGE_AN) && (activate != CHANGE_ALN)) {
+			if (is_change_activating(activate)) {
 				log_error("Refusing to activate merging \"%s\" while snapshot \"%s\" is still active.",
 					  lv->name, find_snapshot(lv)->lv->name);
 				return 0;
@@ -1420,8 +1420,7 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		return_0;
 
 	if (background_polling() &&
-	    (activate != CHANGE_AN) &&
-	    (activate != CHANGE_ALN) &&
+	    is_change_activating(activate) &&
 	    (lv->status & (PVMOVE|CONVERTING|MERGING)))
 		lv_spawn_background_polling(cmd, lv);
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index d862ec2..814238b 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -117,8 +117,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		/* Can't deactivate a pvmove LV */
 		/* FIXME There needs to be a controlled way of doing this */
-		if (((activate == CHANGE_AN) || (activate == CHANGE_ALN)) &&
-		    ((lv->status & PVMOVE) ))
+		if ((lv->status & PVMOVE) && !is_change_activating(activate))
 			continue;
 
 		if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG), 0))
@@ -152,8 +151,8 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (expected_count)
 		log_verbose("%s %d logical volumes in volume group %s",
-			    (activate == CHANGE_AN || activate == CHANGE_ALN)?
-			    "Deactivated" : "Activated", count, vg->name);
+			    is_change_activating(activate) ?
+			    "Activated" : "Deactivated", count, vg->name);
 
 	return (expected_count != count) ? 0 : 1;
 }
@@ -193,12 +192,10 @@ static int _vgchange_background_polling(struct cmd_context *cmd, struct volume_g
 int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		      activation_change_t activate)
 {
-	int lv_open, active, monitored = 0, r = 1, do_activate = 1;
+	int lv_open, active, monitored = 0, r = 1;
 	const struct lv_list *lvl;
 	struct lvinfo info;
-
-	if ((activate == CHANGE_AN) || (activate == CHANGE_ALN))
-		do_activate = 0;
+	int do_activate = is_change_activating(activate);
 
 	/*
 	 * Safe, since we never write out new metadata here. Required for
@@ -589,8 +586,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_count(cmd, activate_ARG) &&
 	    (arg_count(cmd, monitor_ARG) || arg_count(cmd, poll_ARG))) {
-		int activate = arg_uint_value(cmd, activate_ARG, 0);
-		if (activate == CHANGE_AN || activate == CHANGE_ALN) {
+		if (!is_change_activating(arg_uint_value(cmd, activate_ARG, 0))) {
 			log_error("Only -ay* allowed with --monitor or --poll.");
 			return EINVALID_CMD_LINE;
 		}


