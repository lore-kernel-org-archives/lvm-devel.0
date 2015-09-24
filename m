From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 24 Sep 2015 19:03:27 +0000 (UTC)
Subject: master - lockd: fix changing lock type on VG with pool
Message-ID: <20150924190327.3C4C560E53@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d40830a2b13595943ca51d4bfd6249527a0972cf
Commit:        d40830a2b13595943ca51d4bfd6249527a0972cf
Parent:        028715b0f07c0cb9740f8bd81e3d69a29c3341d2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 24 13:59:13 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 24 14:03:20 2015 -0500

lockd: fix changing lock type on VG with pool

vgchange --lock-type iterates through LVs to ensure
no LVs are active before changing the lock type of
the VG, but the loop was not checking that an LV
actually has a lock before trying it, so it would
fail if the VG had any LVs that don't use locks,
e.g it would fail on a tmeta LV from a pool.
---
 lib/locking/lvmlockd.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index e20920c..afbafcb 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -879,6 +879,9 @@ static int _lockd_all_lvs(struct cmd_context *cmd, struct volume_group *vg)
 	struct lv_list *lvl;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!lockd_lv_uses_lock(lvl->lv))
+			continue;
+
 		if (!lockd_lv(cmd, lvl->lv, "ex", 0)) {
 			log_error("LV %s/%s must be inactive on all hosts.",
 				  vg->name, lvl->lv->name);


