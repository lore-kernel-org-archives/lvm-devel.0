From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:24 +0000 (GMT)
Subject: stable-2.02 - lvconvert: read-only origin cannot be merged
Message-ID: <20210217120124.40BA3389C420@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7bb472bc30c88fc56ff7007d540777a30b144185
Commit:        7bb472bc30c88fc56ff7007d540777a30b144185
Parent:        86cd2c630944f0db3429f05cdee967b273f3dff7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 10 00:40:21 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 12:14:54 2021 +0100

lvconvert: read-only origin cannot be merged

When user sets snapshost origin as read-only,
lvm will not allow simple merge and user needs to
flip permission,
---
 tools/lvconvert.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4d2b0365d..5826955d0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2049,15 +2049,21 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
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
 


