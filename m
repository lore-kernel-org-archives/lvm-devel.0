From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:03:09 +0000 (UTC)
Subject: master - dev_manager: lower memory usage
Message-ID: <20130715140309.D6E4C60FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57be501aa3d723fcd41781e6c37579991a714751
Commit:        57be501aa3d723fcd41781e6c37579991a714751
Parent:        0443c42e3bff5b3e0bca6cfdc489d59cd45ada8a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 14 15:08:26 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 15:59:20 2013 +0200

dev_manager: lower memory usage

Created dlid for test is not needed afterward, so lower a memory
usage of this call is repeatedly used for building some large tree.

TODO: create function to use given buffer on stack as much cheaper.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   18 ++++++++++--------
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7aa3df9..5763bdf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Release memory allocated with _cached_info().
   Add whole log_lv and metadata_lv sub volumes when creating partial tree.
   Properly use snapshot layer for origin which is also thin volume.
   Avoid generating metadata backup when calling update_pool_lv().
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 260cb3e..6a2cc68 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -485,25 +485,27 @@ static const struct dm_info *_cached_info(struct dm_pool *mem,
 					  const struct logical_volume *lv,
 					  const char *layer)
 {
-	const char *dlid;
-	struct dm_tree_node *dnode;
-	const struct dm_info *dinfo;
+	char *dlid;
+	const struct dm_tree_node *dnode;
+	const struct dm_info *dinfo = NULL;
 
 	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, layer))) {
-		log_error("dlid build failed for %s", lv->name);
+		log_error("Failed to build dlid for %s.", lv->name);
 		return NULL;
 	}
 
 	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid)))
-		return NULL;
+		goto out;
 
 	if (!(dinfo = dm_tree_node_get_info(dnode))) {
-		log_error("failed to get info from tree node for %s", lv->name);
-		return NULL;
+		log_error("Failed to get info from tree node for %s.", lv->name);
+		goto out;
 	}
 
 	if (!dinfo->exists)
-		return NULL;
+		dinfo = NULL;
+out:
+	dm_pool_free(mem, dlid);
 
 	return dinfo;
 }


