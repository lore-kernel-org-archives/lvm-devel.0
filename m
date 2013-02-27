From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Feb 2013 09:40:59 +0000 (UTC)
Subject: master - lvmetad: fix to properly process embedding area
Message-ID: <20130227094059.40B59A0C38@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d5a3c16dd4f5ea64ba3d89ead049a116f728d64
Commit:        9d5a3c16dd4f5ea64ba3d89ead049a116f728d64
Parent:        b3776468fa07a0bc173dd01152a4f6010c4d174d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Feb 27 10:36:49 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Feb 27 10:36:49 2013 +0100

lvmetad: fix to properly process embedding area

---
 lib/cache/lvmetad.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 2f9ffea..3cde71e 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -306,9 +306,12 @@ static struct lvmcache_info *_pv_populate_lvmcache(
 	do {
 		sprintf(da_id, "ea%d", i);
 		da = dm_config_find_node(cn->child, da_id);
-		if (!dm_config_get_uint64(da->child, "offset", &offset)) return_0;
-		if (!dm_config_get_uint64(da->child, "size", &size)) return_0;
-		lvmcache_add_ea(info, offset, size);
+		if (da) {
+			if (!dm_config_get_uint64(da->child, "offset", &offset)) return_0;
+			if (!dm_config_get_uint64(da->child, "size", &size)) return_0;
+			lvmcache_add_ea(info, offset, size);
+		}
+		++i;
 	} while (da);
 
 	return info;
@@ -675,7 +678,7 @@ static int _extract_disk_location(const char *name, struct disk_locn *dl, void *
 	if (!dl)
 		return 1;
 
-	(void) dm_snprintf(id, 32, "name%d", b->i);
+	(void) dm_snprintf(id, 32, "%s%d", name, b->i);
 	if (!(cn = make_config_node(b->cft, id, b->cft->root, b->pre_sib)))
 		return 0;
 	if (!config_make_nodes(b->cft, cn, NULL,
@@ -710,6 +713,7 @@ static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
 	baton.i = 0;
 	if (!lvmcache_foreach_da(info, &_extract_da, &baton))
 		return 0;
+	baton.i = 0;
 	if (!lvmcache_foreach_ea(info, &_extract_ea, &baton))
 		return 0;
 


