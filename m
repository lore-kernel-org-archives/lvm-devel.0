From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Nov 2013 11:39:41 +0000 (UTC)
Subject: master - cleanup: share the nonremoval message
Message-ID: <20131115113941.47FDC611A2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=89a8c7bea6df1d52818837f5a6778d7ae3e9626c
Commit:        89a8c7bea6df1d52818837f5a6778d7ae3e9626c
Parent:        3cb9041764005c3a8f59b0b5ede3808b660d001a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 12 15:08:35 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 15 12:38:37 2013 +0100

cleanup: share the  nonremoval message

Use common goto label for not remove log error.
---
 lib/metadata/lv_manip.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4a224e4..e22aaa2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4709,10 +4709,8 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 				} else if ((snap_percent == PERCENT_MERGE_FAILED) &&
 					 (force == PROMPT) &&
 					 yes_no_prompt("Removing snapshot \"%s\" that failed to merge may leave origin \"%s\" inconsistent. "
-						       "Proceed? [y/n]: ", lv->name, origin_from_cow(lv)->name) == 'n') {
-					log_error("Logical volume %s not removed.", lv->name);
-					return 0;
-				}
+						       "Proceed? [y/n]: ", lv->name, origin_from_cow(lv)->name) == 'n')
+                                        goto no_remove;
 			}
 		} else if (!level && lv_is_virtual_origin(origin = origin_from_cow(lv)))
 			/* If this is a sparse device, remove its origin too. */
@@ -4727,10 +4725,8 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 		    !lv_is_active(lv) &&
 		    yes_no_prompt("Removing origin %s will also remove %u "
 				  "snapshots(s). Proceed? [y/n]: ",
-				  lv->name, lv->origin_count) == 'n') {
-			log_error("Logical volume %s not removed.", lv->name);
-			return 0;
-		}
+				  lv->name, lv->origin_count) == 'n')
+                        goto no_remove;
 
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!lv_remove_with_dependencies(cmd, dm_list_struct_base(snh, struct lv_segment,
@@ -4766,12 +4762,15 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	    (force == PROMPT) &&
 	    (yes_no_prompt("Removal of pool metadata spare logical volume \"%s\" "
 			   "disables automatic recovery attempts after damage "
-			   "to a thin pool. Proceed? [y/n]: ", lv->name) == 'n')) {
-		log_error("Logical volume \"%s\" not removed.", lv->name);
-		return 0;
-	}
+			   "to a thin pool. Proceed? [y/n]: ", lv->name) == 'n'))
+                goto no_remove;
 
 	return lv_remove_single(cmd, lv, force);
+
+no_remove:
+	log_error("Logical volume \"%s\" not removed.", lv->name);
+
+	return 0;
 }
 
 /*


