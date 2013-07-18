From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:52 +0000 (UTC)
Subject: master - thin: removal of spare disables recovery
Message-ID: <20130718162652.474AD60DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a916bf7eeb9130435c78573ddb51da9318f68411
Commit:        a916bf7eeb9130435c78573ddb51da9318f68411
Parent:        915cc5a2faf67dd3438651b80414f2a054016749
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 17 19:54:15 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:44 2013 +0200

thin: removal of spare disables recovery

Warn user when removing spare LV.
Remove spare automatically, when last pool from VG is removed.
---
 lib/metadata/lv_manip.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 42a5f1e..16ad7e7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4525,7 +4525,9 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 {
 	percent_t snap_percent;
 	struct dm_list *snh, *snht;
+	struct lv_list *lvl;
 	struct lvinfo info;
+	int is_last_pool;
 
 	if (lv_is_cow(lv)) {
 		/*
@@ -4583,6 +4585,30 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "pool"))
 		return_0;
 
+	if (lv_is_thin_pool(lv) && lv->vg->pool_metadata_spare_lv) {
+		/* When removing last thin pool, remove also spare */
+		is_last_pool = 1;
+		dm_list_iterate_items(lvl, &lv->vg->lvs)
+			if (lv_is_thin_pool(lvl->lv) && lvl->lv != lv) {
+				is_last_pool = 0;
+				break;
+			}
+
+		if (is_last_pool &&
+		    !lv_remove_with_dependencies(cmd, lv->vg->pool_metadata_spare_lv,
+						 DONT_PROMPT, level + 1))
+			return_0;
+	}
+
+	if (lv_is_pool_metadata_spare(lv) &&
+	    (force == PROMPT) &&
+	    (yes_no_prompt("Removal of pool metadata spare logical volume \"%s\" "
+			   "disables automatic recovery attempts after damage "
+			   "to a thin pool. Proceed? [y/n]: ", lv->name) == 'n')) {
+		log_error("Logical volume \"%s\" not removed.", lv->name);
+		return 0;
+	}
+
 	return lv_remove_single(cmd, lv, force);
 }
 


