From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Sep 2015 19:54:35 +0000 (UTC)
Subject: master - pool: validate pool_metadata has proper suffix
Message-ID: <20150911195435.624CC609C4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=729b035edd923554275ac7b3bc446b57f0e9f0d5
Commit:        729b035edd923554275ac7b3bc446b57f0e9f0d5
Parent:        fda853b573920ccefda23ad97f54d7b4dafaa9f1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 11 20:58:58 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 11 21:52:27 2015 +0200

pool: validate pool_metadata has proper suffix

---
 lib/metadata/merge.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index a3e6af1..351ab39 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -119,12 +119,24 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			inc_error_count;
 		}
 
-		if (lv_is_pool_metadata(lv) &&
-		    (!(seg2 = first_seg(lv)) || !(seg2 = find_pool_seg(seg2)) ||
-		     seg2->metadata_lv != lv)) {
-			log_error("LV %s: segment 1 pool metadata LV does not point back to same LV",
-				  lv->name);
-			inc_error_count;
+		if (lv_is_pool_metadata(lv)) {
+			if (!(seg2 = first_seg(lv)) || !(seg2 = find_pool_seg(seg2)) ||
+			    seg2->metadata_lv != lv) {
+				log_error("LV %s: segment 1 pool metadata LV does not point back to same LV",
+					  lv->name);
+				inc_error_count;
+			}
+			if (lv_is_thin_pool_metadata(lv) &&
+			    !strstr(lv->name, "_tmeta")) {
+				log_error("LV %s: thin pool metadata LV does not use _tmeta",
+					  lv->name);
+				inc_error_count;
+			} else if (lv_is_cache_pool_metadata(lv) &&
+				   !strstr(lv->name, "_cmeta")) {
+				log_error("LV %s: cache pool metadata LV does not use _cmeta",
+					  lv->name);
+				inc_error_count;
+			}
 		}
 	}
 


