From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 28 Jan 2014 09:41:09 +0000 (UTC)
Subject: master - thin: disable extension of reduced thin with etx.origin
Message-ID: <20140128094109.75F0C616A5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0bd436dcb45849aff2e953432e5b40e55e0f712
Commit:        c0bd436dcb45849aff2e953432e5b40e55e0f712
Parent:        7786443530915505e17fcc42f0c750cb81cdc522
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 28 10:24:50 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 28 10:40:08 2014 +0100

thin: disable extension of reduced thin with etx.origin

Since we are currently incapable of providing zeroes for
reextended thin volume area, let's disable extension of
such already reduce thin volumes.

(in-release change)
---
 lib/metadata/lv_manip.c                     |   28 +++++++++++++++++++-------
 test/shell/lvresize-thin-external-origin.sh |    6 ++--
 2 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c875b69..2e240fc 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2452,14 +2452,6 @@ int lv_add_virtual_segment(struct logical_volume *lv, uint64_t status,
 	lv->le_count += extents;
 	lv->size += (uint64_t) extents *lv->vg->extent_size;
 
-	/* Validate thin target supports bigger size of thin volume then external origin */
-	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv &&
-	    first_seg(lv)->external_lv->size < lv->size &&
-	    !thin_pool_feature_supported(first_seg(lv)->pool_lv, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND)) {
-		log_error("Thin target does not support external origin smaller then thin volume.");
-		return 0;
-	}
-
 	return 1;
 }
 
@@ -4036,6 +4028,26 @@ static int _lvresize_check_type(struct cmd_context *cmd, const struct logical_vo
 		}
 	}
 
+	if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv &&
+	    (lp->resize == LV_EXTEND)) {
+		/*
+		 * TODO: currently we do not support extension of already reduced thin volume.
+		 * But it might be possible to create combined mapping of some part of
+		 * the external origin followed by zero target.
+		 */
+		if (first_seg(lv)->external_lv->size > lv->size) {
+			log_error("Extension of reduced thin volume with external origin is unsupported.");
+			return 0;
+		}
+
+		/* Validate thin target supports bigger size of thin volume then external origin */
+		if (first_seg(lv)->external_lv->size <= lv->size &&
+		    !thin_pool_feature_supported(first_seg(lv)->pool_lv, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND)) {
+			log_error("Thin target does not support external origin smaller then thin volume.");
+			return 0;
+		}
+	}
+
 	return 1;
 }
 
diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index d9739c0..3499196 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -37,6 +37,6 @@ not lvresize -L+10 $vg/$lv1
 # But reduction works
 lvresize -L-5 -f $vg/$lv1
 not lvresize -L+15 -y $vg/$lv1
-# We may size again back up to the size of external origin
-# TODO: hmm do we really want this???
-lvresize -L+5 -f $vg/$lv1
+# Try to resize again back up to the size of external origin
+# But for now we do not support zeroing for rexetended areas.
+not lvresize -L+5 -f $vg/$lv1


