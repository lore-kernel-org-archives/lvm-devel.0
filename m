From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:35:20 +0000 (UTC)
Subject: master - cleanup: more readable check
Message-ID: <20160114103520.ADF6360DBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ebcfd09ba9631b52762b4932fbe06260326b9827
Commit:        ebcfd09ba9631b52762b4932fbe06260326b9827
Parent:        753a496348828fd296f79af2cf4803eade5c375b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 15 15:13:11 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:34:05 2016 +0100

cleanup: more readable check

---
 lib/metadata/lv_manip.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index dd9df3b..62564c5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5146,22 +5146,19 @@ static int _lvresize_check_type(struct cmd_context *cmd, const struct logical_vo
 		}
 	}
 
-	if (lv_is_thin_pool(lv)) {
-		if (lp->resize == LV_REDUCE) {
+	if (lp->resize == LV_REDUCE) {
+		if (lv_is_thin_pool(lv)) {
 			log_error("Thin pool volumes cannot be reduced in size yet.");
 			return 0;
 		}
-	}
-
-	if ((lp->resize == LV_REDUCE) && lv_is_thin_pool_metadata(lv)) {
-		log_error("Thin pool metadata volumes cannot be reduced.");
-		return 0;
-	}
-
-	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv &&
-	    (lp->resize == LV_EXTEND)) {
+		if (lv_is_thin_pool_metadata(lv)) {
+			log_error("Thin pool metadata volumes cannot be reduced.");
+			return 0;
+		}
+	} else if (lp->resize == LV_EXTEND)  {
 		/* Validate thin target supports bigger size of thin volume then external origin */
-		if (first_seg(lv)->external_lv->size <= lv->size &&
+		if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv &&
+		    (lv->size > first_seg(lv)->external_lv->size) &&
 		    !thin_pool_feature_supported(first_seg(lv)->pool_lv, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND)) {
 			log_error("Thin target does not support external origin smaller then thin volume.");
 			return 0;


