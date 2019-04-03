From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 3 Apr 2019 07:29:56 -0400
Subject: master - thin: resize metadata with data
Message-ID: <201904031129.x33BTuaI027557@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e27d0271557d4b93e87a70854b3c7f1cc6008155
Commit:        e27d0271557d4b93e87a70854b3c7f1cc6008155
Parent:        7c3de2fd935aee428af8d75e774f5dd23a74c409
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 3 13:01:06 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 3 13:28:22 2019 +0200

thin: resize metadata with data

When data are growing, adapt also size of metadata.
As we get way too many reports from users doing huge growths of
data portion while keep metadata small and avoiding using monitoring.

So to enhance the user-experience in case user requests grown of
thin-pool (without passing PV list for growth) - lvm2 will automaticaly
grown also the metadata part of thin-pool (if possible).
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   18 ++++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0f1fe1b..00c96b5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Automatically grow thin metadata, when thin data gets too big.
   Add synchronization with udev before removing cached devices.
   Add support for caching VDO LVs and VDOPOOL LVs.
   Add support for vgsplit with cached devices.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index cc391b6..a13ba31 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5664,6 +5664,24 @@ int lv_resize(struct logical_volume *lv,
 	if (!_lvresize_prepare(&lv, lp, pvh))
 		return_0;
 
+	if (lp->resize != LV_REDUCE && !aux_lv && !lp->poolmetadata_size &&
+	    &lv->vg->pvs == pvh && lv_is_thin_pool_data(lv)) {
+		/* When thin-pool data part is extended, automatically extend also metadata part
+		 * to have the metadata chunks for adressing all data blocks
+		 * Do this only when PV list is not defined and --poolmetadatasize is unspecified */
+		aux_lp = *lp;
+		seg = get_only_segment_using_this_lv(lv);
+		aux_lp.size = estimate_thin_pool_metadata_size(lp->extents, lv->vg->extent_size, seg->chunk_size);
+		if (aux_lp.size > seg->metadata_lv->size) {
+			log_verbose("Also going to resize thin-pool metadata to match bigger data.");
+			aux_lv = _lvresize_setup_aux(seg->metadata_lv, &aux_lp);
+			aux_lp.sign = SIGN_NONE;
+			if (!_lvresize_prepare(&aux_lv, &aux_lp, pvh))
+				return_0;
+		} else
+			aux_lp.size = 0;
+	}
+
 	if (((lp->resize == LV_REDUCE) ||
 	     (aux_lv && aux_lp.resize == LV_REDUCE)) &&
 	    (pvh != &vg->pvs))


