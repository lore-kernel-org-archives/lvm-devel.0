From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 10 Jul 2015 20:54:29 +0000 (UTC)
Subject: master - vgchange: allow changing to lockd type when mirrors exist
Message-ID: <20150710205429.4299160139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b8538f5dcd2e1c0880607a2bbd067d6aa60e689a
Commit:        b8538f5dcd2e1c0880607a2bbd067d6aa60e689a
Parent:        c4fdcb04be174dd3ec68eb0c3f17dd8a08314b59
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 10 11:48:50 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 10 15:53:21 2015 -0500

vgchange: allow changing to lockd type when mirrors exist

and update lvmlockd man page to reflect the fact that
mirror LVs work correctly in lockd VGs.
---
 man/lvmlockd.8.in |    4 +---
 tools/vgchange.c  |   17 -----------------
 2 files changed, 1 insertions(+), 20 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 4d9b3f5..c3b0ac0 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -682,13 +682,11 @@ it are not autoactivated.
 
 Things that do not yet work in lockd VGs:
 .br
-- old style mirror LVs (only raid1)
-.br
 - creating a new thin pool and a new thin LV in a single command
 .br
 - using lvcreate to create cache pools or cache LVs (use lvconvert)
 .br
-- splitting raid1 mirror LVs
+- splitting mirrors and snapshots from LVs
 .br
 - vgsplit
 .br
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 4b90b56..95cffaf 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -604,23 +604,6 @@ static int _vgchange_locktype(struct cmd_context *cmd,
 		return 0;
 	}
 
-	/*
-	 * Check if there are any LV types in the VG that cannot be handled
-	 * with the new lock type.  Remove this once all LV types can be
-	 * handled.
-	 */
-	if (is_lockd_type(lock_type)) {
-		dm_list_iterate_items(lvl, &vg->lvs) {
-			lv = lvl->lv;
-
-			if (lv_is_mirror_type(lv)) {
-				log_error("Changing to lock type %s is not allowed with mirror type LV %s/%s",
-					  lock_type, vg->name, display_lvname(lv));
-				return 0;
-			}
-		}
-	}
-
 	/* none to clvm */
 	if (!strcmp(vg->lock_type, "none") && !strcmp(lock_type, "clvm")) {
 		log_warn("New clvm lock type will not be usable with lvmlockd.");


