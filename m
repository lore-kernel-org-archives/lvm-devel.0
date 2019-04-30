From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Apr 2019 07:30:40 -0400
Subject: stable-2.02 - thin: resize metadata with data
Message-ID: <201904301130.x3UBUe8q020429@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=515867bbad4565b788460b1fc8cfe91acd5ade1e
Commit:        515867bbad4565b788460b1fc8cfe91acd5ade1e
Parent:        bcf1aa99e66b7a99f9cddbecffad1b3d65b59a50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 3 13:01:06 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 30 12:02:49 2019 +0200

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
index 6457d4c..7949a4a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.185 - 
 ==================================
+  Automatically grow thin metadata, when thin data gets too big.
   Add support for vgsplit with cached devices.
   Fix signal delivery checking race in libdaemon (lvmetad).
   Add missing Before=shutdown.target to LVM2 services to fix shutdown ordering.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e72a1c9..2ea8eb4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5518,6 +5518,24 @@ int lv_resize(struct logical_volume *lv,
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


