From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  9 Jul 2015 22:03:37 +0000 (UTC)
Subject: master - vgchange: fix disallowed LV types in lockd VG
Message-ID: <20150709220337.EA4AA61043@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=082fcc53cc82e77e42af014623f8d9df4f1be173
Commit:        082fcc53cc82e77e42af014623f8d9df4f1be173
Parent:        074295245b3f57310a2688a4628f016b17ba2f5d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 9 16:34:23 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 9 16:34:23 2015 -0500

vgchange: fix disallowed LV types in lockd VG

cow snapshots work in lockd VG (they were wrongly
disallowed), but mirror type LVs do not yet work in
lockd VGs (they were wrongly allowed).
---
 tools/vgchange.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 437dbae..4b90b56 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -613,9 +613,9 @@ static int _vgchange_locktype(struct cmd_context *cmd,
 		dm_list_iterate_items(lvl, &vg->lvs) {
 			lv = lvl->lv;
 
-			if ((lv->status & SNAPSHOT) || lv_is_cow(lv)) {
-				log_error("Changing to lock type %s is not allowed with cow snapshot LV %s/%s",
-					  lock_type, vg->name, lv->name);
+			if (lv_is_mirror_type(lv)) {
+				log_error("Changing to lock type %s is not allowed with mirror type LV %s/%s",
+					  lock_type, vg->name, display_lvname(lv));
 				return 0;
 			}
 		}


