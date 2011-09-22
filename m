From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 22 Sep 2011 12:13:45 -0500
Subject: [PATCH 1 of 2] Skip sync of mirror extension if mirror has LV_NOTSYNCED set
Message-ID: <1316711625.9375.1.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If mirror was created with '--nosync', lvextend should not do sync on extension.

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -2599,13 +2599,45 @@ int lv_extend(struct logical_volume *lv,
 			return 0;
 		}
 
-		r = _lv_extend_layered_lv(ah, lv, extents, 0,
-					  stripes, stripe_size);
+		if (!(r = _lv_extend_layered_lv(ah, lv, extents, 0,
+						stripes, stripe_size)))
+			goto_out;
 
-		if (r && segtype_is_thin_pool(segtype))
+		if (segtype_is_thin_pool(segtype))
 			r = lv_add_segment(ah, ah->area_count, 1, first_seg(lv)->pool_metadata_lv,
 					   get_segtype_from_string(lv->vg->cmd, "striped"), 0, 0, 0);
+
+		/*
+		 * If we are expanding an existing mirror, we can skip the
+		 * resync of the extension if the LV is currently in-sync
+		 * and the LV has the LV_NOTSYNCED flag set.
+		 */
+		if ((lv->le_count != extents) &&
+		    segtype_is_mirrored(segtype) &&
+		    (lv->status & LV_NOTSYNCED)) {
+			percent_t sync_percent;
+
+			log_verbose("%s/%s created or extended with '--nosync'",
+				    lv->vg->name, lv->name);
+			if (!lv_mirror_percent(lv->vg->cmd, lv, 0,
+					      &sync_percent, NULL)) {
+				log_error("Failed to get sync percent for %s/%s:"
+					  " Forcing resync of extended portion",
+					  lv->vg->name, lv->name);
+			} else if (sync_percent == PERCENT_100) {
+				log_verbose("Skipping initial resync for "
+					    "extended portion of %s/%s",
+					    lv->vg->name, lv->name);
+				init_mirror_in_sync(1);
+			} else {
+				log_verbose("%s/%s is not currently in-sync: "
+					  " Forcing resync of extended portion",
+					  lv->vg->name, lv->name);
+			}
+		}
 	}
+
+out:
 	alloc_destroy(ah);
 	return r;
 }



