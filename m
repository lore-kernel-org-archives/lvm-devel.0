From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Nov 2018 06:23:36 -0500
Subject: master - activation: trimming string is expected
Message-ID: <201811081123.wA8BNaJd013946@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c1703845c3d82e381c545b8ad8bde68bafc2fbcf
Commit:        c1703845c3d82e381c545b8ad8bde68bafc2fbcf
Parent:        1dc5603f73940bc59d09afa67c2e8c4da0ce8526
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 8 10:02:28 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 8 12:20:57 2018 +0100

activation: trimming string is expected

Commit 813347cf84617a946d9184f44c5fbd275bb41766 added extra validation,
however in this particular we do want to trim suffix out so rather ignore
resulting error code here intentionaly.
---
 lib/activate/dev_manager.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 49f425b..f0c5254 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2061,11 +2061,8 @@ static int _check_holder(struct dev_manager *dm, struct dm_tree *dtree,
 
 		if (!strncmp(uuid, (char*)&lv->vg->id, sizeof(lv->vg->id)) &&
 		    !dm_tree_find_node_by_uuid(dtree, uuid)) {
-			if (!dm_strncpy((char*)&id, uuid, 2 * sizeof(struct id) + 1)) {
-				log_error(INTERNAL_ERROR "Too long UUID %s in VG %s.",
-					  uuid, lv->vg->name);
-				goto out;
-			}
+			/* trims any UUID suffix (i.e. -cow) */
+			(void) dm_strncpy((char*)&id, uuid, 2 * sizeof(struct id) + 1);
 
 			/* If UUID is not yet in dtree, look for matching LV */
 			if (!(lv_det = find_lv_in_vg_by_lvid(lv->vg, &id))) {


