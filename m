From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 30 May 2017 12:44:47 -0400
Subject: master - tmp
Message-ID: <201705301644.v4UGilUK014275@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a54d21ccd156a38a8cbc71ee77e0752c26e4ee7f
Commit:        a54d21ccd156a38a8cbc71ee77e0752c26e4ee7f
Parent:        c245996d700458f6ab159a387483736f1c1a6fbf
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed May 24 22:55:01 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue May 30 18:43:56 2017 +0200

tmp

---
 tools/lvconvert.c |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 821146f..3423428 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1293,6 +1293,20 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		if (!seg_is_mirrored(seg) && !seg_is_linear(seg)) {
 			log_error("--mirrors/-m is not compatible with %s.",
 				  lvseg_name(seg));
+			log_error("You can convert %s LV %s to %s indirectly.",
+				  lvseg_name(seg), display_lvname(lv), lp->type_str);
+			if (seg_is_any_raid5(seg)) {
+				if (seg->area_count == 2)
+					log_error("Convert %s LV %s to raid1.",
+						  lvseg_name(seg), display_lvname(lv));
+				else
+					log_error("Convert %s LV %s to 2 stripes, then to raid1 and to linear.",
+						  lvseg_name(seg), display_lvname(lv));
+			} else
+				log_error("Convert %s LV %s to raid5 with 2 stripes and then to raid1.",
+					  lvseg_name(seg), display_lvname(lv));
+
+			log_error("Mind to extend the LV before removing stripes to avoid data loss.");
 			return 0;
 		}
 		if (seg_is_raid10(seg)) {
@@ -1442,7 +1456,13 @@ try_new_takeover_or_reshape:
 		return 1;
 	}
 
-	log_error("Conversion operation not yet supported.");
+	if (seg_is_mirror(seg) || seg_is_linear(seg)) {
+		log_error("Convert %s LV %s to raid1 with 2 images (i.e. --mirrors 1) first.",
+			  lvseg_name(seg), display_lvname(lv));
+		log_error("Conversion operation failed.");
+	} else
+		log_error("Conversion operation not yet supported.");
+
 	return 0;
 }
 


