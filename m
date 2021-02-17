From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:15 +0000 (GMT)
Subject: stable-2.02 - lvdisplay: fix show of merged thin snapshot
Message-ID: <20210217120115.1A48F3896839@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7243e32ce56c2f33fb7cfd735dc6abf27f868c00
Commit:        7243e32ce56c2f33fb7cfd735dc6abf27f868c00
Parent:        9344a04b3794b154b06fa44da62d088f0b057486
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 12 15:11:48 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:56:12 2021 +0100

lvdisplay: fix show of merged thin snapshot

When lvdisplay was executed and thin snaphost has be merged to
thin origin and the operation has been postponed till devices
are closed, command crashed.

Check LV is COW before trying to check snapshot percentage.
---
 lib/display/display.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index cd911feea..f6a212c7b 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -474,7 +474,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 					  snap_active ? "active" : "INACTIVE");
 		}
 		snap_seg = NULL;
-	} else if ((snap_seg = find_snapshot(lv))) {
+	} else if (lv_is_cow(lv) && (snap_seg = find_snapshot(lv))) {
 		if (inkernel &&
 		    (snap_active = lv_snapshot_percent(snap_seg->cow,
 						       &snap_percent)))


