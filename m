From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:04 -0400
Subject: master - cache: report for succesful status
Message-ID: <201910041533.x94FX4GC030973@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb5f0bdba988c826b8edee06e139cff62eeffeb8
Commit:        cb5f0bdba988c826b8edee06e139cff62eeffeb8
Parent:        667b33dd3be1068ffb92783e189cbc1b41c9ac28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 1 13:31:36 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

cache: report for succesful status

---
 lib/display/display.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 055fc69..913bced 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -522,10 +522,10 @@ int lvdisplay_full(struct cmd_context *cmd,
 			log_print("LV origin of Cache LV  %s", seg->lv->name);
 	} else if (lv_is_cache(lv)) {
 		seg = first_seg(lv);
-		if (inkernel && !lv_cache_status(lv, &cache_status))
-                        return_0;
-		log_print("LV Cache pool name     %s", seg->pool_lv->name);
-		log_print("LV Cache origin name   %s", seg_lv(seg, 0)->name);
+		if (inkernel && lv_cache_status(lv, &cache_status)) {
+			log_print("LV Cache pool name     %s", seg->pool_lv->name);
+			log_print("LV Cache origin name   %s", seg_lv(seg, 0)->name);
+		}
 	} else if (lv_is_cache_pool(lv)) {
 		seg = first_seg(lv);
 		log_print("LV Pool metadata       %s", seg->metadata_lv->name);


