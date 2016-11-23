From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:56:01 +0000 (UTC)
Subject: master - cleanup: deactivate has builtin check for active lv
Message-ID: <20161123165601.3379E60F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c621bc3d36ee4a9fff18e7e83c5c5ac3c1e09d4f
Commit:        c621bc3d36ee4a9fff18e7e83c5c5ac3c1e09d4f
Parent:        74923c213fe3c876d3532ef4251e15f946e90fb5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 23 10:29:42 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:55:03 2016 +0100

cleanup: deactivate has builtin check for active lv

---
 tools/lvconvert.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6165320..f50a551 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1523,10 +1523,9 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 				    MIRROR_BY_LV)) {
 			layer_lv = seg_lv(first_seg(lv), 0);
 			if (!remove_layer_from_lv(lv, layer_lv) ||
-			    (lv_is_active(layer_lv) &&
-			     !deactivate_lv(cmd, layer_lv)) ||
-			    !lv_remove(layer_lv) || !vg_write(lv->vg) ||
-			    !vg_commit(lv->vg)) {
+			    !deactivate_lv(cmd, layer_lv) ||
+			    !lv_remove(layer_lv) ||
+			    !vg_write(lv->vg) || !vg_commit(lv->vg)) {
 				log_error("ABORTING: Failed to remove "
 					  "temporary mirror layer %s.",
 					  display_lvname(layer_lv));


