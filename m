From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:57 +0000 (UTC)
Subject: master - cleanup: format1 test whether PV was found
Message-ID: <20120823124257.15B1FA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=243cd3fd2ca377d93fd7407f2a0109a04a189cbc
Commit:        243cd3fd2ca377d93fd7407f2a0109a04a189cbc
Parent:        132306c8887ac7279edd515a9f5c5de75dfc463a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 21 13:52:19 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:52 2012 +0200

cleanup: format1 test whether PV was found

Avoid dereferecing NULL pointer.
---
 lib/format1/import-extents.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/format1/import-extents.c b/lib/format1/import-extents.c
index 46c1b7b..f0f4f65 100644
--- a/lib/format1/import-extents.c
+++ b/lib/format1/import-extents.c
@@ -118,7 +118,10 @@ static int _fill_maps(struct dm_hash_table *maps, struct volume_group *vg,
 	uint32_t i, lv_num, le;
 
 	dm_list_iterate_items(dl, pvds) {
-		pv = find_pv(vg, dl->dev);
+		if (!(pv = find_pv(vg, dl->dev))) {
+			log_error("PV %s not found.", dl->dev->pvid);
+			return 0;
+		}
 		e = dl->extents;
 
 		/* build an array of lv's for this pv */


