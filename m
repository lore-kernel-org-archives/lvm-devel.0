From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:15 -0500
Subject: master - cov: add missing check for dm_strncpy
Message-ID: <201811051627.wA5GRFCj005362@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=813347cf84617a946d9184f44c5fbd275bb41766
Commit:        813347cf84617a946d9184f44c5fbd275bb41766
Parent:        c7789daec06110b7ed3663f1ba8cf91f40c8e572
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 2 21:50:29 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 3 16:10:32 2018 +0100

cov: add missing check for dm_strncpy

---
 lib/activate/dev_manager.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 67a49be..aaf113f 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1916,7 +1916,11 @@ static int _check_holder(struct dev_manager *dm, struct dm_tree *dtree,
 
 		if (!strncmp(uuid, (char*)&lv->vg->id, sizeof(lv->vg->id)) &&
 		    !dm_tree_find_node_by_uuid(dtree, uuid)) {
-			dm_strncpy((char*)&id, uuid, 2 * sizeof(struct id) + 1);
+			if (!dm_strncpy((char*)&id, uuid, 2 * sizeof(struct id) + 1)) {
+				log_error(INTERNAL_ERROR "Too long UUID %s in VG %s.",
+					  uuid, lv->vg->name);
+				goto out;
+			}
 
 			/* If UUID is not yet in dtree, look for matching LV */
 			if (!(lv_det = find_lv_in_vg_by_lvid(lv->vg, &id))) {


