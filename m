From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:49:29 -0400
Subject: master - format-text.c log message fixes
Message-ID: <201804231349.w3NDnT05031665@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=29c6c171217753daf5603432bcaeaed2e8dc8418
Commit:        29c6c171217753daf5603432bcaeaed2e8dc8418
Parent:        d9a77e8bb4d25af33625d3cdddf5288207101d5b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 7 15:20:39 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:45 2018 -0500

format-text.c log message fixes

---
 lib/format_text/format-text.c |   56 ++++++++++++++++++++++------------------
 1 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index ee1f11d..8740a05 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -468,12 +468,11 @@ static struct raw_locn *_read_metadata_location_vg(struct device_area *dev_area,
 	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
 		return rlocn;
 
-	log_debug_metadata("Volume group name found in %smetadata on %s at " FMTu64 " does "
-			   "not match expected name %s.", 
-			   *precommitted ? "precommitted " : "",
-			   dev_name(dev_area->dev), dev_area->start + rlocn->offset, vgname);
+	log_error("Metadata on %s at %llu has wrong VG name \"%s\" expected %s.",
+		  dev_name(dev_area->dev),
+		  (unsigned long long)(dev_area->start + rlocn->offset),
+		  vgnamebuf, vgname);
 
-      bad:
 	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, dev_area->dev, 0)) &&
 	    !lvmcache_update_vgname_and_id(info, &vgsummary_orphan))
 		stack;
@@ -553,8 +552,10 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
 	if (wrap > rlocn->offset) {
-		log_error("VG %s metadata on %s (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes)",
-			  vgname, dev_name(area->dev), rlocn->size, mdah->size - MDA_HEADER_SIZE);
+		log_error("Metadata for VG %s on %s at %llu size %llu is too large for circular buffer.",
+			  vgname, dev_name(area->dev),
+			  (unsigned long long)(area->start + rlocn->offset),
+			  (unsigned long long)rlocn->size);
 		goto out;
 	}
 
@@ -572,10 +573,10 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 		   that skips parsing the metadata which also returns NULL. */
 	}
 
-	log_debug_metadata("Found metadata on %s at %"FMTu64" size %"FMTu64" for VG %s",
+	log_debug_metadata("Found metadata on %s at %llu size %llu for VG %s",
 			   dev_name(area->dev),
-			   area->start + rlocn->offset,
-			   rlocn->size,
+			   (unsigned long long)(area->start + rlocn->offset),
+			   (unsigned long long)rlocn->size,
 			   vgname);
 
 	if (vg && precommitted)
@@ -1220,8 +1221,9 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	 * If no valid offset, do not try to search for vgname
 	 */
 	if (!rlocn->offset) {
-		log_debug_metadata("Metadata location on %s at %"FMTu64" has offset 0.",
-				   dev_name(dev_area->dev), dev_area->start + rlocn->offset);
+		log_debug_metadata("Metadata location on %s at %llu has offset 0.",
+				   dev_name(dev_area->dev),
+				   (unsigned long long)(dev_area->start + rlocn->offset));
 		return 0;
 	}
 
@@ -1235,9 +1237,10 @@ int read_metadata_location_summary(const struct format_type *fmt,
 
 	/* Ignore this entry if the characters aren't permissible */
 	if (!validate_name(buf)) {
-		log_error("Metadata location on %s at %"FMTu64" begins with invalid VG name.",
-			  dev_name(dev_area->dev), dev_area->start + rlocn->offset);
-		return_0;
+		log_error("Metadata location on %s at %llu begins with invalid VG name.",
+			  dev_name(dev_area->dev),
+			  (unsigned long long)(dev_area->start + rlocn->offset));
+		return 0;
 	}
 
 	/* We found a VG - now check the metadata */
@@ -1245,8 +1248,9 @@ int read_metadata_location_summary(const struct format_type *fmt,
 		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
 	if (wrap > rlocn->offset) {
-		log_error("Metadata location on %s at %"FMTu64" is too large for circular buffer.",
-			  dev_name(dev_area->dev), dev_area->start + rlocn->offset);
+		log_error("Metadata location on %s at %llu is too large for circular buffer.",
+			  dev_name(dev_area->dev),
+			  (unsigned long long)(dev_area->start + rlocn->offset));
 		return 0;
 	}
 
@@ -1277,22 +1281,24 @@ int read_metadata_location_summary(const struct format_type *fmt,
 				(off_t) (dev_area->start + MDA_HEADER_SIZE),
 				wrap, calc_crc, vgsummary->vgname ? 1 : 0,
 				vgsummary)) {
-		log_error("Metadata location on %s at %"FMTu64" has invalid summary for VG.",
-			  dev_name(dev_area->dev), dev_area->start + rlocn->offset);
+		log_error("Metadata location on %s at %llu has invalid summary for VG.",
+			  dev_name(dev_area->dev),
+			  (unsigned long long)(dev_area->start + rlocn->offset));
 		return 0;
 	}
 
 	/* Ignore this entry if the characters aren't permissible */
 	if (!validate_name(vgsummary->vgname)) {
-		log_error("Metadata location on %s at %"FMTu64" has invalid VG name.",
-			  dev_name(dev_area->dev), dev_area->start + rlocn->offset);
+		log_error("Metadata location on %s at %llu has invalid VG name.",
+			  dev_name(dev_area->dev),
+			  (unsigned long long)(dev_area->start + rlocn->offset));
 		return 0;
 	}
 
-	log_debug_metadata("Found metadata summary on %s at %"FMTu64" size %"FMTu64" for VG %s",
+	log_debug_metadata("Found metadata summary on %s at %llu size %llu for VG %s",
 			   dev_name(dev_area->dev),
-			   dev_area->start + rlocn->offset,
-			   rlocn->size,
+			   (unsigned long long)(dev_area->start + rlocn->offset),
+			   (unsigned long long)rlocn->size,
 			   vgsummary->vgname);
 
 	if (mda_free_sectors) {
@@ -1344,7 +1350,7 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 		}
 
 		if (read_metadata_location_summary(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
-			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0, 0);
+			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0);
 			if (vg) {
 				lvmcache_update_vg(vg, 0);
 				lvmcache_set_independent_location(vg->name);


