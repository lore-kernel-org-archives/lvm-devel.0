From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:36:17 -0500
Subject: master - cleanup: update messages in lvconvert
Message-ID: <201711072036.vA7KaHut008022@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7f2f77dcad0d23c84a1146de05217beeb3fbde5
Commit:        f7f2f77dcad0d23c84a1146de05217beeb3fbde5
Parent:        e2fce429cfccf974be93bc939eed6f111738659c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 5 10:22:31 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:26:11 2017 +0100

cleanup: update messages in lvconvert

Use display_lvname and update thin snapshot merge error message.
---
 tools/lvconvert.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 438f34b..50c77d8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2018,9 +2018,10 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	}
 
 	if (lv_is_external_origin(origin_from_cow(lv))) {
-		log_error("Cannot merge snapshot \"%s\" into "
-			  "the read-only external origin \"%s\".",
-			  lv->name, origin_from_cow(lv)->name);
+		log_error("Cannot merge snapshot %s into "
+			  "the read-only external origin %s.",
+			  display_lvname(lv),
+			  display_lvname(origin_from_cow(lv)));
 		return 0;
 	}
 
@@ -2029,8 +2030,8 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	    && info.exists && info.live_table &&
 	    (!lv_snapshot_percent(lv, &snap_percent) ||
 	     snap_percent == DM_PERCENT_INVALID)) {
-		log_error("Unable to merge invalidated snapshot LV \"%s\".",
-			  lv->name);
+		log_error("Unable to merge invalidated snapshot LV %s.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2119,7 +2120,9 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 
 	/* Check if merge is possible */
 	if (lv_is_merging_origin(origin)) {
-		log_error("Snapshot %s is already merging into the origin.",
+		log_error("Cannot merge snapshot %s into the origin %s "
+			  "with merging snapshot %s.",
+			  display_lvname(lv), display_lvname(origin),
 			  display_lvname(find_snapshot(origin)->lv));
 		return 0;
 	}


