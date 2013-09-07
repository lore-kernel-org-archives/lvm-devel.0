From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  7 Sep 2013 07:20:00 +0000 (UTC)
Subject: master - thin: validation catch multiseg thin pool/volumes
Message-ID: <20130907072000.2CDCF610C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0670bfeb5942508c3d2e2573a50980f82abe1bcf
Commit:        0670bfeb5942508c3d2e2573a50980f82abe1bcf
Parent:        655296609eaab2d3255178b22b15910c4771b864
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 6 14:07:39 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 7 03:32:07 2013 +0200

thin: validation catch multiseg thin pool/volumes

Multisegment thin pools and volumes are not supported.
Catch such error code path early.
---
 WHATS_NEW            |    1 +
 lib/metadata/merge.c |   30 ++++++++++++++++++++----------
 2 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8bc95c2..342f15b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Check for exactly one lv segment in validation of thin pools and volumes.
   Fix dmeventd unmonitoring of thin pools.
   Fix lvresize for stacked thin pool volumes (i.e. mirrors).
   Write Completed debug message before reinstating log defaults after command.
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 477d7bb..c22e922 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -76,18 +76,28 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 
 	/* Check LV flags match first segment type */
 	if (complete_vg) {
-		if (lv_is_thin_volume(lv) &&
-		    (!(seg2 = first_seg(lv)) || !seg_is_thin_volume(seg2))) {
-			log_error("LV %s is thin volume without first thin volume segment",
-				  lv->name);
-			inc_error_count;
+		if (lv_is_thin_volume(lv)) {
+			if (dm_list_size(&lv->segments) != 1) {
+				log_error("LV %s is thin volume without exactly one segment.",
+					  lv->name);
+				inc_error_count;
+			} else if (!seg_is_thin_volume(first_seg(lv))) {
+				log_error("LV %s is thin volume without first thin volume segment.",
+					  lv->name);
+				inc_error_count;
+			}
 		}
 
-		if (lv_is_thin_pool(lv) &&
-		    (!(seg2 = first_seg(lv)) || !seg_is_thin_pool(seg2))) {
-			log_error("LV %s is thin pool without first thin pool segment",
-				  lv->name);
-			inc_error_count;
+		if (lv_is_thin_pool(lv)) {
+			if (dm_list_size(&lv->segments) != 1) {
+				log_error("LV %s is thin pool volume without exactly one segment.",
+					  lv->name);
+				inc_error_count;
+			} else if (!seg_is_thin_pool(first_seg(lv))) {
+				log_error("LV %s is thin pool without first thin pool segment.",
+					  lv->name);
+				inc_error_count;
+			}
 		}
 
 		if (lv_is_thin_pool_data(lv) &&


