From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:25 -0500
Subject: master - debug: print VG name in log messages for segment errors
Message-ID: <32255.119121009462300985@us-mta-190.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e70d5d470c196f81c125c2705c065302608dbfbe
Commit:        e70d5d470c196f81c125c2705c065302608dbfbe
Parent:        4353823306800fda4184a4a4278d036ca345993b
Author:        Nikhil Kshirsagar <nkshirsa@redhat.com>
AuthorDate:    Tue Nov 26 12:36:45 2019 +0530
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:44:06 2019 +0100

debug: print VG name in log messages for segment errors

Signed-off-by: Nikhil Kshirsagar <nkshirsa@redhat.com>
---
 lib/metadata/merge.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index e482921..11b26b4 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -73,7 +73,7 @@ int lv_merge_segments(struct logical_volume *lv)
 
 #define seg_error(msg) do { \
 		log_error("LV %s, segment %u invalid: %s for %s segment.", \
-			  seg->lv->name, seg_count, (msg), lvseg_name(seg)); \
+			  display_lvname(seg->lv), seg_count, (msg), lvseg_name(seg)); \
 		if ((*error_count)++ > ERROR_MAX) \
 			return; \
 	} while (0)
@@ -86,14 +86,14 @@ int lv_merge_segments(struct logical_volume *lv)
  */
 #define raid_seg_error(msg) do { \
 	log_error("LV %s invalid: %s for %s segment", \
-		  seg->lv->name, (msg), lvseg_name(seg)); \
+		  display_lvname(seg->lv), (msg), lvseg_name(seg)); \
 	if ((*error_count)++ > ERROR_MAX) \
 		return; \
 } while (0)
 
 #define raid_seg_error_val(msg, val) do { \
 	log_error("LV %s invalid: %s (is %u) for %s segment", \
-		  seg->lv->name, (msg), (val), lvseg_name(seg)); \
+		  display_lvname(seg->lv), (msg), (val), lvseg_name(seg)); \
 	if ((*error_count)++ > ERROR_MAX) \
 		return; \
 } while(0)



