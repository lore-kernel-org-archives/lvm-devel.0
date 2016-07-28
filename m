From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 28 Jul 2016 16:35:48 +0000 (UTC)
Subject: master - vgsplit: ea90a3d622 added an unconditional call to lv_is_on_pvs() on any thin snap external origin LV which caused a segfault when none existed as exposed by the vgsplit-thin.sh test.
Message-ID: <20160728163548.1545A60D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a579ba2ac27d9651165e7e997a5ff855dc83c170
Commit:        a579ba2ac27d9651165e7e997a5ff855dc83c170
Parent:        4bc351d65879f319cf94cc59ff781ca3d649060f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 28 18:34:46 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Jul 28 18:35:33 2016 +0200

vgsplit: ea90a3d622 added an unconditional call to lv_is_on_pvs()          on any thin snap external origin LV which caused a segfault          when none existed as exposed by the vgsplit-thin.sh test.

         Only call lv_is_on_pvs() if an external origin LV actually
         exists and correct the related splitting logic.
---
 tools/vgsplit.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index fd43650a..93161c1 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -331,8 +331,8 @@ static int _move_thins(struct volume_group *vg_from,
 			data_lv = seg_lv(first_seg(seg->pool_lv), 0);
 
 			/* Ignore, if no allocations on PVs of @vg_to */
-			if (!lv_is_on_pvs(data_lv, &vg_to->pvs) &&
-			    !lv_is_on_pvs(seg->external_lv, &vg_to->pvs))
+			if (!lv_is_on_pvs(data_lv, &vg_to->pvs) ||
+			    (seg->external_lv && !lv_is_on_pvs(seg->external_lv, &vg_to->pvs)))
 				continue;
 
 			if ((_lv_is_in_vg(vg_to, data_lv) ||


