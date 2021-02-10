From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Feb 2021 14:43:55 +0000 (GMT)
Subject: main - lvconvert: read-only origin cannot be merged
Message-ID: <20210210144355.DD0853857C7B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f90082ce8f218781ff3b9361e748dbff0ff0e2e3
Commit:        f90082ce8f218781ff3b9361e748dbff0ff0e2e3
Parent:        289518005834b5844f88ce1f22265df99f7072d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 00:40:21 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 10 15:39:03 2021 +0100

lvconvert: read-only origin cannot be merged

When user sets snapshost origin as read-only,
lvm will not allow simple merge and user needs to
flip permission,
---
 tools/lvconvert.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a72126bf4..77afaf487 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2162,15 +2162,21 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 		log_error("Cannot merge snapshot %s into the origin %s "
 			  "with merging snapshot %s.",
 			  display_lvname(lv), display_lvname(origin),
-			  display_lvname(find_snapshot(origin)->lv));
+			  display_lvname(snap_seg->lv));
 		return 0;
 	}
 
-	if (lv_is_external_origin(origin_from_cow(lv))) {
+	if (lv_is_external_origin(origin)) {
 		log_error("Cannot merge snapshot %s into "
 			  "the read-only external origin %s.",
-			  display_lvname(lv),
-			  display_lvname(origin_from_cow(lv)));
+			  display_lvname(lv), display_lvname(origin));
+		return 0;
+	}
+
+	if (!(origin->status & LVM_WRITE)) {
+		log_error("Cannot merge snapshot %s into "
+			  "the read-only origin %s. (Use lvchange -p rw).",
+			  display_lvname(lv), display_lvname(origin));
 		return 0;
 	}
 


