From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jul 2017 15:45:46 -0400
Subject: master - lvmlockd: fix revert in lvcreate
Message-ID: <201707071945.v67JjkQe013246@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3797f47ecf23c41d4476e2cce0f210b48b32923d
Commit:        3797f47ecf23c41d4476e2cce0f210b48b32923d
Parent:        a0f6135e5c53af8bb361932ebe8fec55a1804cc9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 7 14:42:25 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 7 14:42:25 2017 -0500

lvmlockd: fix revert in lvcreate

If the activation step in lvcreate fails (e.g. the specified
minor number is already used), then the lvcreate is reverted,
but the LV lock in lvmlockd was not being unlocked or properly
freed.
---
 lib/metadata/lv_manip.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f75cf51..fbe0aed 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7983,7 +7983,8 @@ deactivate_and_revert_new_lv:
 	}
 
 revert_new_lv:
-	lockd_free_lv(vg->cmd, vg, lp->lv_name, &lv->lvid.id[1], lp->lock_args);
+	lockd_lv(cmd, lv, "un", LDLV_PERSISTENT);
+	lockd_free_lv(vg->cmd, vg, lp->lv_name, &lv->lvid.id[1], lv->lock_args);
 
 	/* FIXME Better to revert to backup of metadata? */
 	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))


