From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:36 +0000 (UTC)
Subject: master - cache: allow deactivation of empty pool
Message-ID: <20141103132336.73487602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b7335f84717743bf9c3f9ea9cafff279dff8672
Commit:        0b7335f84717743bf9c3f9ea9cafff279dff8672
Parent:        969ab6bbf02c11bf989ccc3105910a205448507b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 2 17:48:21 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cache: allow deactivation of empty pool

Tool will use internal activation of unused cache pool to
clear metadata area before next use of cache-pool.
So allow to deactivation unused pool in case some error
case happend and we were not able to deactivation pool
right after metadata wipe.
---
 tools/lvchange.c |    5 +----
 tools/toollib.c  |   17 +++++++++++++++++
 tools/vgchange.c |    4 ----
 3 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 6697905..99dba82 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -170,9 +170,6 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
 
 	activate = (activation_change_t) arg_uint_value(cmd, activate_ARG, CHANGE_AY);
 
-	if (lv_is_cache_pool(lv))
-		return 1;
-
 	if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG)))
 		return 1;
 
diff --git a/tools/toollib.c b/tools/toollib.c
index e87fd30..0472597 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -688,6 +688,23 @@ int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	int r = 1;
 
+	if (lv_is_cache_pool(lv)) {
+		if (is_change_activating(activate)) {
+			log_verbose("Skipping activation of cache pool %s.",
+				    display_lvname(lv));
+			return 1;
+		}
+		if (!dm_list_empty(&lv->segs_using_this_lv)) {
+			log_verbose("Skipping deactivation of used cache pool %s.",
+				    display_lvname(lv));
+			return 1;
+		}
+		/*
+		 * Allow to pass only deactivation of unused cache pool.
+		 * Useful only for recovery of failed zeroing of metadata LV.
+		 */
+	}
+
 	if (lv_is_merging_origin(lv)) {
 		/*
 		 * For merging origin, its snapshot must be inactive.
diff --git a/tools/vgchange.c b/tools/vgchange.c
index af59f3a..e5d700d 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -97,10 +97,6 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (!lv_is_visible(lv))
 			continue;
 
-		/* Cache pool cannot be activated */
-		if (lv_is_cache_pool(lv))
-			continue;
-
 		/* If LV is sparse, activate origin instead */
 		if (lv_is_cow(lv) && lv_is_virtual_origin(origin_from_cow(lv)))
 			lv = origin_from_cow(lv);


