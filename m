From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Jul 2016 19:56:25 +0000 (UTC)
Subject: master - coverity: add some tests for function results
Message-ID: <20160713195625.A8AD06036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e1bf7acd39e2e6686f634be29b2c64a0aab705c
Commit:        4e1bf7acd39e2e6686f634be29b2c64a0aab705c
Parent:        4661c6b6fb7adc01a3fd42b5e802051b92d15d9d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 12 16:43:12 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 13 21:52:14 2016 +0200

coverity: add some tests for function results

Even though they cannot normally happen...
---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 lib/metadata/metadata.c        |    6 ++++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 31d0933..c4c1d68 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -861,7 +861,7 @@ static int remove_metadata(lvmetad_state *s, const char *vgid, int update_pvids)
 
 	/* update_pvid_to_vgid will clear/free the pvid_to_vgid hash */
 	if (update_pvids && meta_lookup)
-		_update_pvid_to_vgid(s, meta_lookup, "#orphan", 0);
+		(void) _update_pvid_to_vgid(s, meta_lookup, "#orphan", 0);
 
 	/* free the unmapped data */
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d8bb726..8a9a1b2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4641,7 +4641,8 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 		dev = dl->dev;
 		if (!(dev->flags & DEV_ASSUMED_FOR_LV)) {
 			if (!found_inconsistent) {
-				dm_pool_begin_object(mem, 32);
+				if (!dm_pool_begin_object(mem, 32))
+					return_0;
 				found_inconsistent = 1;
 			} else {
 				if (!dm_pool_grow_object(mem, DEV_LIST_DELIM, sizeof(DEV_LIST_DELIM) - 1))
@@ -4674,7 +4675,8 @@ static int _check_devs_used_correspond_with_lv(struct dm_pool *mem, struct dm_li
 				}
 				if (!(dev->flags & DEV_USED_FOR_LV)) {
 					if (!found_inconsistent) {
-						dm_pool_begin_object(mem, 32);
+						if (!dm_pool_begin_object(mem, 32))
+                                                        return_0;
 						found_inconsistent = 1;
 					} else {
 						if (!dm_pool_grow_object(mem, DEV_LIST_DELIM, sizeof(DEV_LIST_DELIM) - 1))


