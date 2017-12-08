From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Dec 2017 07:22:10 -0500
Subject: master - cleanup: switch to standard query
Message-ID: <201712081222.vB8CMAe6007499@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=700e2a2d251cf8dcaf56035e0bd83ce8f808b5c0
Commit:        700e2a2d251cf8dcaf56035e0bd83ce8f808b5c0
Parent:        71485ebfc759299610e279a91b97215b556295df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 8 13:15:21 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 8 13:21:15 2017 +0100

cleanup: switch to standard query

In /tools part we should mostly use standard functions
lv_is_active*  unless there is good reason to not use it.
---
 tools/vgchange.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 48e64c5..ea737ba 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -58,19 +58,12 @@ static int _poll_lvs_in_vg(struct cmd_context *cmd,
 {
 	struct lv_list *lvl;
 	struct logical_volume *lv;
-	struct lvinfo info;
-	int lv_active;
 	int count = 0;
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
-		if (!lv_info(cmd, lv, 0, &info, 0, 0))
-			lv_active = 0;
-		else
-			lv_active = info.exists;
-
-		if (lv_active &&
+		if (lv_is_active_locally(lv) &&
 		    (lv_is_pvmove(lv) || lv_is_converting(lv) || lv_is_merging(lv))) {
 			lv_spawn_background_polling(cmd, lv);
 			count++;


