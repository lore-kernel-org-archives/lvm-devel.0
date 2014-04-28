From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 28 Apr 2014 10:43:47 +0000 (UTC)
Subject: master - lvscan: drop test for snapshosts
Message-ID: <20140428104347.9E68760FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1aba7ccf6d1bc5f3bc1fa1b5fe70eec64f8c633
Commit:        d1aba7ccf6d1bc5f3bc1fa1b5fe70eec64f8c633
Parent:        4c405a9b490423fc2dbcc475ca4649f2c4a03f5e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 28 11:58:26 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 28 12:42:53 2014 +0200

lvscan: drop test for snapshosts

When showing  ACTIVE status for snapshot's origin,
avoid testing all its snapshot - it's not useful
to tell user origin is inactivate, while it's clearly
available and running - just one of its snapshot leg
is invalid...
---
 WHATS_NEW      |    1 +
 tools/lvscan.c |   13 +------------
 2 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9d792a2..fad66bf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Show correct availability status for snapshot origin in lvscan.
   Move segment thin pool/volume info into segment display 'lvdisplay --maps'.
   Display thin pool usage even when just thin volume is available.
   Display monitoring status for monitorable segments in 'lvdisplay --maps'.
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 636ac45..47e79d6 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -20,7 +20,6 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 {
 	struct lvinfo info;
 	int inkernel, snap_active = 1;
-	struct lv_segment *snap_seg = NULL;
 	percent_t snap_percent;     /* fused, fsize; */
 
 	const char *active_str, *snapshot_str;
@@ -29,17 +28,7 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_PROCESSED;
 
 	inkernel = lv_info(cmd, lv, 0, &info, 0, 0) && info.exists;
-	if (lv_is_origin(lv)) {
-		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
-				       origin_list) {
-			if (inkernel &&
-			    (snap_active = lv_snapshot_percent(snap_seg->cow,
-							       &snap_percent)))
-				if (snap_percent == PERCENT_INVALID)
-					snap_active = 0;
-		}
-		snap_seg = NULL;
-	} else if (lv_is_cow(lv)) {
+	if (lv_is_cow(lv)) {
 		if (inkernel &&
 		    (snap_active = lv_snapshot_percent(lv, &snap_percent)))
 			if (snap_percent == PERCENT_INVALID)


