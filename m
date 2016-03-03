From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:16 +0000 (UTC)
Subject: master - metadata: honour 'nohistory' switch when removing thin LVs
Message-ID: <20160303132016.B8992602C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f545dd5952ee0b191ae2cda2d7b6f304442debab
Commit:        f545dd5952ee0b191ae2cda2d7b6f304442debab
Parent:        9a34de9cb9c1e8585f11bbb79bc447fdbdf7ea31
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:25:28 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:15 2016 +0100

metadata: honour 'nohistory' switch when removing thin LVs

When --nohistory switch is used with lvremove, the LV that is removed is
not recorded in metadata as 'historical LV'.
---
 lib/metadata/pool_manip.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index ac590b3..d2856ae 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -215,10 +215,17 @@ static int _set_up_historical_lv(struct lv_segment *seg_to_remove,
 {
 	struct generic_logical_volume *glv = NULL;
 
-	if (seg_to_remove->origin || seg_to_remove->indirect_origin ||
-	    dm_list_size(&seg_to_remove->lv->segs_using_this_lv) ||
-	    dm_list_size(&seg_to_remove->lv->indirect_glvs)) {
-		if (!(glv = _create_historical_glv(seg_to_remove)))
+	if (seg_to_remove->lv->vg->cmd->record_historical_lvs) {
+		if (seg_to_remove->origin || seg_to_remove->indirect_origin ||
+		    dm_list_size(&seg_to_remove->lv->segs_using_this_lv) ||
+		    dm_list_size(&seg_to_remove->lv->indirect_glvs)) {
+			if (!(glv = _create_historical_glv(seg_to_remove)))
+				return_0;
+		}
+	} else {
+		if (seg_to_remove->indirect_origin &&
+		    !remove_glv_from_indirect_glvs(seg_to_remove->indirect_origin,
+						   seg_to_remove->lv->this_glv))
 			return_0;
 	}
 


