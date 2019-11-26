From: Nikhil Kshirsagar <nkshirsa@redhat.com>
Date: Tue, 26 Nov 2019 12:36:45 +0530
Subject: [PATCH] lib/metadata: Print VG name in log messages for segment errors
Message-ID: <CAMNNMLFD5FdAfic_7Vi3KCZ-VcAp6kzfmASt6gca48aVFHeF_A@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Nikhil Kshirsagar <nkshirsa@redhat.com>
---
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index e482921..11b26b4 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -73,7 +73,7 @@ int lv_merge_segments(struct logical_volume *lv)

 #define seg_error(msg) do { \
                log_error("LV %s, segment %u invalid: %s for %s segment.", \
-                         seg->lv->name, seg_count, (msg), lvseg_name(seg)); \
+                         display_lvname(seg->lv), seg_count, (msg),
lvseg_name(seg)); \
                if ((*error_count)++ > ERROR_MAX) \
                        return; \
        } while (0)
@@ -86,14 +86,14 @@ int lv_merge_segments(struct logical_volume *lv)
  */
 #define raid_seg_error(msg) do { \
        log_error("LV %s invalid: %s for %s segment", \
-                 seg->lv->name, (msg), lvseg_name(seg)); \
+                 display_lvname(seg->lv), (msg), lvseg_name(seg)); \
        if ((*error_count)++ > ERROR_MAX) \
                return; \
 } while (0)

 #define raid_seg_error_val(msg, val) do { \
        log_error("LV %s invalid: %s (is %u) for %s segment", \
-                 seg->lv->name, (msg), (val), lvseg_name(seg)); \
+                 display_lvname(seg->lv), (msg), (val), lvseg_name(seg)); \
        if ((*error_count)++ > ERROR_MAX) \
                return; \
 } while(0)



