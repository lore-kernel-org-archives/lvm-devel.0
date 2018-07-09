From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:53 -0400
Subject: master - check_lv_segment: internal vdo segment validation
Message-ID: <201807091334.w69DYrpY030714@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00990ed53e4d00fe7b030d366193a51bd646c85b
Commit:        00990ed53e4d00fe7b030d366193a51bd646c85b
Parent:        0dafd159a862aa76a950a3568eba32a73c0422cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 11:13:43 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

check_lv_segment: internal vdo segment validation

Check if settings for vdo segment are correct.
---
 lib/metadata/merge.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index cf8789c..035a56c 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -486,6 +486,29 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			seg_error("sets indirect_origin LV");
 	}
 
+	if (seg_is_vdo_pool(seg)) {
+		if (!lv_is_vdo_pool(lv))
+			seg_error("is not flagged as VDO pool LV");
+		if ((seg->area_count != 1) || (seg_type(seg, 0) != AREA_LV)) {
+			seg_error("is missing a VDO pool data LV");
+		} else if (!lv_is_vdo_pool_data(seg_lv(seg, 0)))
+			seg_error("is not VDO pool data LV");
+	} else { /* !VDO pool */
+		if (seg->vdo_pool_header_size)
+			seg_error("sets vdo_pool_header_size");
+		if (seg->vdo_pool_virtual_extents)
+			seg_error("sets vdo_pool_virtual_extents");
+	}
+
+	if (seg_is_vdo(seg)) {
+		if (!lv_is_vdo(lv))
+			seg_error("is not flagged as VDO LV");
+		if (!seg_lv(seg, 0))
+			seg_error("is missing VDO pool LV");
+		else if (!lv_is_vdo_pool(seg_lv(seg, 0)))
+			seg_error("is not referencing VDO pool LV");
+	}
+
 	/* Some multi-seg vars excluded here */
 	if (!seg_is_cache(seg) &&
 	    !seg_is_thin_volume(seg)) {


