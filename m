From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 27 Jul 2016 19:04:26 +0000 (UTC)
Subject: master - vgsplit: restore check for thin pool external origin
Message-ID: <20160727190426.1182460E6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea90a3d622319fd15a3e85d772b25cd352a3544b
Commit:        ea90a3d622319fd15a3e85d772b25cd352a3544b
Parent:        17fb64b569742a2d247f20d198a8b6facdd12a0c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 27 14:00:57 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 27 14:00:57 2016 -0500

vgsplit: restore check for thin pool external origin

Fix a regression from commit 4420d41f, in which the
check was skipped for splitting a thin pool and an
external origin.
---
 tools/vgsplit.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 909a786..fd43650a 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -331,7 +331,8 @@ static int _move_thins(struct volume_group *vg_from,
 			data_lv = seg_lv(first_seg(seg->pool_lv), 0);
 
 			/* Ignore, if no allocations on PVs of @vg_to */
-			if (!lv_is_on_pvs(data_lv, &vg_to->pvs))
+			if (!lv_is_on_pvs(data_lv, &vg_to->pvs) &&
+			    !lv_is_on_pvs(seg->external_lv, &vg_to->pvs))
 				continue;
 
 			if ((_lv_is_in_vg(vg_to, data_lv) ||


