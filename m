From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:17 +0000 (UTC)
Subject: master - cleanup: use trigraph
Message-ID: <20131122200917.9928961133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19cc92230cd855d08e0a8787687c8dba9cd8d627
Commit:        19cc92230cd855d08e0a8787687c8dba9cd8d627
Parent:        879ea38c53f81ab22225fb368e8787144517d963
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 13:15:47 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:55 2013 +0100

cleanup: use trigraph

Shorter code...
---
 lib/metadata/lv_manip.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e22aaa2..491accd 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3822,10 +3822,8 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			lv->status |= LV_NOTSYNCED;
 
 		dm_list_iterate_back_items(mirr_seg, &lv->segments) {
-			if (seg_is_mirrored(mirr_seg))
-				seg_mirrors = lv_mirror_count(mirr_seg->lv);
-			else
-				seg_mirrors = 0;
+			seg_mirrors = seg_is_mirrored(mirr_seg) ?
+				lv_mirror_count(mirr_seg->lv) : 0;
 			break;
 		}
 


