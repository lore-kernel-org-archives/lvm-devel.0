From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:19 +0000 (UTC)
Subject: master - cleanup: use safe iterator
Message-ID: <20131122200919.AA0A461097@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bea118a87cd6cf7c63ccaa0d75691de1f73602ab
Commit:        bea118a87cd6cf7c63ccaa0d75691de1f73602ab
Parent:        19cc92230cd855d08e0a8787687c8dba9cd8d627
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 13:18:02 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:55 2013 +0100

cleanup: use safe iterator

Simplify code and use dm_list_iterate_items_safe() and avoid
scanning the list mutliple times.
Use dm_list_move().
---
 lib/metadata/metadata.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 53d7e5e..c71ec30 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2809,7 +2809,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	struct lvmcache_vginfo *vginfo;
 	struct volume_group *vg = NULL;
 	struct _vg_read_orphan_baton baton;
-	struct pv_list *pvl, *pvl_;
+	struct pv_list *pvl, *tpvl;
 	struct pv_list head;
 
 	dm_list_init(&head.list);
@@ -2823,15 +2823,13 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 		return_NULL;
 
 	vg = fmt->orphan_vg;
-restart:
-	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (pvl->pv->status & UNLABELLED_PV ) {
-			dm_list_del(&pvl->list);
-			dm_list_add(&head.list, &pvl->list);
-			goto restart;
-		} else
+
+	dm_list_iterate_items_safe(pvl, tpvl, &vg->pvs)
+		if (pvl->pv->status & UNLABELLED_PV )
+			dm_list_move(&head.list, &pvl->list);
+		else
 			pv_set_fid(pvl->pv, NULL);
-	}
+
 	dm_list_init(&vg->pvs);
 	vg->pv_count = 0;
 	vg->extent_count = 0;


