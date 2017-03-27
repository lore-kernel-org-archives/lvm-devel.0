From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 27 Mar 2017 09:33:10 -0400
Subject: master - lvchange: reject setting all raid1 images to writemostly
Message-ID: <201703271333.v2RDXAV5027137@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6165e092215c795eafa297268cddbd9dade3a82c
Commit:        6165e092215c795eafa297268cddbd9dade3a82c
Parent:        5c199d99f4dc9911d62673baba7643ea649ffe64
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sun Mar 26 20:28:04 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sun Mar 26 20:28:04 2017 +0200

lvchange: reject setting all raid1 images to writemostly

raid1 doesn't allow to set all images to writemostly because at
least one image is required to receive any written data immediately.

The dm-raid target will detect such invalid request and
fail it iwith a kernel error message.

Reject such request in uspace displaying a respective error message.
---
 tools/lvchange.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index abb557a..7239f18 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -732,7 +732,8 @@ static int _lvchange_rebuild(struct logical_volume *lv)
 
 static int _lvchange_writemostly(struct logical_volume *lv)
 {
-	int s, pv_count, i = 0;
+	int pv_count, i = 0;
+	uint32_t s, writemostly;
 	char **pv_names;
 	const char *tmp_str;
 	size_t tmp_str_len;
@@ -808,7 +809,7 @@ static int _lvchange_writemostly(struct logical_volume *lv)
 				return 0;
 			}
 
-			for (s = 0; s < (int) raid_seg->area_count; s++) {
+			for (s = 0; s < raid_seg->area_count; s++) {
 				/*
 				 * We don't bother checking the metadata area,
 				 * since writemostly only affects the data areas.
@@ -830,6 +831,19 @@ static int _lvchange_writemostly(struct logical_volume *lv)
 						return_0;
 				}
 			}
+
+		}
+
+		/* Only allow a maximum on N-1 images to be set writemostly. */
+		writemostly = 0;
+		for (s = 0; s < raid_seg->area_count; s++)
+			if (seg_lv(raid_seg, s)->status & LV_WRITEMOSTLY)
+				writemostly++;
+
+		if (writemostly == raid_seg->area_count) {
+			log_error("Can't set all images of %s LV %s to writemostly.",
+				  lvseg_name(raid_seg), display_lvname(lv));
+			return 0;
 		}
 	}
 


