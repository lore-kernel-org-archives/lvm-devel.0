From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 23 Feb 2013 09:41:45 +0000 (UTC)
Subject: master - activation: extend _cached_info
Message-ID: <20130223094145.185C440A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78b23f35950f9d5dd502495325aa019b793c8052
Commit:        78b23f35950f9d5dd502495325aa019b793c8052
Parent:        6a995bac43f8ddcdbb5075053943aa8189df3170
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 18 00:08:38 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 23 10:28:01 2013 +0100

activation: extend _cached_info

Add layer string to support check of layered devices.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   14 ++++++++------
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2f8fbd4..0f4228b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Extend _cached_info() to accept layer string.
   Allow identical table reload for RAID to restore transiently failed PVs.
   vgimport '--force' now allows users to import VGs with missing PVs.
   Fix PV alignment to incorporate alignment offset if the PV has zero MDAs.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e8f449c..deaab9f 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -481,14 +481,15 @@ int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
 }
 
 static const struct dm_info *_cached_info(struct dm_pool *mem,
+					  struct dm_tree *dtree,
 					  const struct logical_volume *lv,
-					  struct dm_tree *dtree)
+					  const char *layer)
 {
 	const char *dlid;
 	struct dm_tree_node *dnode;
 	const struct dm_info *dinfo;
 
-	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, NULL))) {
+	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, layer))) {
 		log_error("dlid build failed for %s", lv->name);
 		return NULL;
 	}
@@ -2169,10 +2170,11 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		 * - open_count is always retrieved (as of dm-ioctl 4.7.0)
 		 *   so just use the tree's existing nodes' info
 		 */
-		if (((dinfo = _cached_info(dm->mem, lv,
-					   dtree)) && dinfo->open_count) ||
-		    ((dinfo = _cached_info(dm->mem, find_merging_cow(lv)->cow,
-					   dtree)) && dinfo->open_count)) {
+		if (((dinfo = _cached_info(dm->mem, dtree, lv, NULL)) &&
+		     dinfo->open_count) ||
+		    ((dinfo = _cached_info(dm->mem, dtree,
+					   find_merging_cow(lv)->cow, NULL)) &&
+		     dinfo->open_count)) {
 			/* FIXME Is there anything simpler to check for instead? */
 			if (!lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
 				laopts->no_merging = 1;


