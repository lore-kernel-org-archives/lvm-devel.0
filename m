From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 16:38:00 -0400
Subject: master - lvmlockd: fix reverting new lv in error path
Message-ID: <201805312038.w4VKc07q027311@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9c1cef8176ad127e682e40b1508816b23c9a989
Commit:        b9c1cef8176ad127e682e40b1508816b23c9a989
Parent:        4a01e4f3895a947c0c693d0336643a1287de6df5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 31 15:35:48 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 31 15:35:48 2018 -0500

lvmlockd: fix reverting new lv in error path

The wrong name was being used to free the LV lock
in lvmlockd in the error exit path.
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c1bba03..c5e63a9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8010,7 +8010,7 @@ deactivate_and_revert_new_lv:
 
 revert_new_lv:
 	lockd_lv(cmd, lv, "un", LDLV_PERSISTENT);
-	lockd_free_lv(vg->cmd, vg, lp->lv_name, &lv->lvid.id[1], lv->lock_args);
+	lockd_free_lv(vg->cmd, vg, lv->name, &lv->lvid.id[1], lv->lock_args);
 
 	/* FIXME Better to revert to backup of metadata? */
 	if (!lv_remove(lv) || !vg_write(vg) || !vg_commit(vg))


