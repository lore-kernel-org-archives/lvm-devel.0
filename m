From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue, 16 Aug 2016 21:57:44 +0000 (UTC)
Subject: master - vgsplit: fix regression processing thin external origins
Message-ID: <20160816215744.6D7B660E2D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0a0eedf2e572b99e40384e68e3d5f8fba6f0ae5
Commit:        c0a0eedf2e572b99e40384e68e3d5f8fba6f0ae5
Parent:        73df2aedf9788dcf2dbf09f20f8783c6d2108e75
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Aug 16 23:57:09 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Aug 16 23:57:09 2016 +0200

vgsplit: fix regression processing thin external origins

a579ba2ac27d fixed a regression causing a segfault if no external
origin existed but broke the logic leading to erroneous error
messages and creations of split off exported VGs in case the
external origin and the pool LVs were allocated on different PVs.

- resolves rhbz1367459
---
 tools/vgsplit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 93161c1..52f603f 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -331,7 +331,7 @@ static int _move_thins(struct volume_group *vg_from,
 			data_lv = seg_lv(first_seg(seg->pool_lv), 0);
 
 			/* Ignore, if no allocations on PVs of @vg_to */
-			if (!lv_is_on_pvs(data_lv, &vg_to->pvs) ||
+			if (!lv_is_on_pvs(data_lv, &vg_to->pvs) &&
 			    (seg->external_lv && !lv_is_on_pvs(seg->external_lv, &vg_to->pvs)))
 				continue;
 


