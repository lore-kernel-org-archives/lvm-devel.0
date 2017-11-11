From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Nov 2017 19:03:09 -0500
Subject: master - cleanup: constify lv parameter
Message-ID: <201711110003.vAB039Do009550@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9ac1c12d0966714a918154e97864faf0a916170
Commit:        b9ac1c12d0966714a918154e97864faf0a916170
Parent:        05f9acdc7ff3e9968c2e2422b2cd384c74d7dbe4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 8 14:24:09 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 11 00:56:10 2017 +0100

cleanup: constify lv parameter

---
 lib/locking/locking.c |    2 +-
 lib/locking/locking.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 2886fc4..bf39b4a 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -437,7 +437,7 @@ int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs,
  * Then if the VG is clustered and the LV is not yet active (e.g. due to 
  * an activation filter) try activating on remote nodes.
  */
-int activate_lv_excl(struct cmd_context *cmd, struct logical_volume *lv) 
+int activate_lv_excl(struct cmd_context *cmd, const struct logical_volume *lv)
 {
 	/* Non-clustered VGs are only activated locally. */
 	if (!vg_is_clustered(lv->vg))
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 2381631..d39a725 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -242,7 +242,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 				lock_lv_vol(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_REMOTE)
 
 struct logical_volume;
-int activate_lv_excl(struct cmd_context *cmd, struct logical_volume *lv);
+int activate_lv_excl(struct cmd_context *cmd, const struct logical_volume *lv);
 
 #define activate_lv_local(cmd, lv)	\
 	lock_lv_vol_serially(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD | LCK_LOCAL)


