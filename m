From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:35 +0000 (GMT)
Subject: main - lvdisplay: fix show of merged thin snapshot
Message-ID: <20210217105435.9BAFE3857C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14008ead2a42b4a5db0c81e444f9ea1a05c1a899
Commit:        14008ead2a42b4a5db0c81e444f9ea1a05c1a899
Parent:        3af61d8646765fea95a77618e9bfc7e1c35f7ea2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 12 15:11:48 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:21:35 2021 +0100

lvdisplay: fix show of merged thin snapshot

When lvdisplay was executed and thin snaphost has be merged to
thin origin and the operation has been postponed till devices
are closed, command crashed.

Check LV is COW before trying to check snapshot percentage.
---
 lib/display/display.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index a84695393..f0f03c0a5 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -475,7 +475,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 					  snap_active ? "active" : "INACTIVE");
 		}
 		snap_seg = NULL;
-	} else if ((snap_seg = find_snapshot(lv))) {
+	} else if (lv_is_cow(lv) && (snap_seg = find_snapshot(lv))) {
 		if (inkernel &&
 		    (snap_active = lv_snapshot_percent(snap_seg->cow,
 						       &snap_percent)))


