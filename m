From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:46:48 -0500
Subject: master - cleanup: drop unused code
Message-ID: <201801171346.w0HDkm3g030020@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3aedaa7f2aa3c8622538e2758bf905ceb156db4a
Commit:        3aedaa7f2aa3c8622538e2758bf905ceb156db4a
Parent:        38b81e6537a8dc497a4bc616a1f51632b43137ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 11 16:11:21 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:45:48 2018 +0100

cleanup: drop unused code

---
 tools/pvmove.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index af3fec4..b3d1d89 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -329,8 +329,6 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	uint32_t log_count = 0;
 	int lv_found = 0;
 	int lv_skipped = 0;
-	int lv_active_count = 0;
-	int lv_exclusive_count = 0;
 
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
@@ -451,13 +449,6 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 		}
 
-		if (vg_is_clustered(vg)) {
-			if (lv_is_active_exclusive_locally(lv))
-				lv_exclusive_count++;
-			else if (lv_is_active(lv))
-				lv_active_count++;
-		}
-
 		if (!_insert_pvmove_mirrors(cmd, lv_mirr, source_pvl, lv,
 					    *lvs_changed))
 			return_NULL;


