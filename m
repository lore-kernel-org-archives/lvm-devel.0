From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:21 -0400
Subject: master - change args for text label read function
Message-ID: <201906072108.x57L8Llk005265@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86d831b9165d71769cd0fc05b52bc7469760e2f0
Commit:        86d831b9165d71769cd0fc05b52bc7469760e2f0
Parent:        889b5d3183314985d4d0930b30f0cd4b0f482f69
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 5 13:40:34 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

change args for text label read function

Have the caller pass the label_sector to the read
function so the read function can set the sector
field in the label struct, instead of having the
read function return a pointer to the label for
the caller to set the sector field.

Also have the read function return a flag indicating
to the caller that the scanned device was identified
as a duplicate pv.
---
 lib/cache/lvmcache.c          |   14 ++++++++++----
 lib/cache/lvmcache.h          |    6 +++---
 lib/format_text/format-text.c |    7 +++----
 lib/format_text/text_label.c  |   27 +++++++++++++++++++++------
 lib/label/label.c             |   40 ++++++++++++++++++++++++++++++++--------
 lib/label/label.h             |    2 +-
 6 files changed, 70 insertions(+), 26 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 3e89b02..3987173 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1760,7 +1760,7 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
  *   transient duplicate?
  */
 
-static struct lvmcache_info * _create_info(struct labeller *labeller, struct device *dev)
+static struct lvmcache_info * _create_info(struct labeller *labeller, struct device *dev, uint64_t label_sector)
 {
 	struct lvmcache_info *info;
 	struct label *label;
@@ -1773,6 +1773,9 @@ static struct lvmcache_info * _create_info(struct labeller *labeller, struct dev
 		return NULL;
 	}
 
+	label->dev = dev;
+	label->sector = label_sector;
+
 	info->dev = dev;
 	info->fmt = labeller->fmt;
 
@@ -1788,8 +1791,9 @@ static struct lvmcache_info * _create_info(struct labeller *labeller, struct dev
 }
 
 struct lvmcache_info *lvmcache_add(struct labeller *labeller,
-				   const char *pvid, struct device *dev,
-				   const char *vgname, const char *vgid, uint32_t vgstatus)
+				   const char *pvid, struct device *dev, uint64_t label_sector,
+				   const char *vgname, const char *vgid, uint32_t vgstatus,
+				   int *is_duplicate)
 {
 	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
 	char uuid[64] __attribute__((aligned(8)));
@@ -1817,7 +1821,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 		info = lvmcache_info_from_pvid(dev->pvid, NULL, 0);
 
 	if (!info) {
-		info = _create_info(labeller, dev);
+		info = _create_info(labeller, dev, label_sector);
 		created = 1;
 	}
 
@@ -1849,6 +1853,8 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 
 			dm_list_add(&_found_duplicate_devs, &devl->list);
 			_found_duplicate_pvs = 1;
+			if (is_duplicate)
+				*is_duplicate = 1;
 			return NULL;
 		}
 
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 21f29ef..d4c19f9 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -74,9 +74,9 @@ int lvmcache_label_rescan_vg(struct cmd_context *cmd, const char *vgname, const
 
 /* Add/delete a device */
 struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
-				   struct device *dev,
-				   const char *vgname, const char *vgid,
-				   uint32_t vgstatus);
+                                   struct device *dev, uint64_t label_sector,
+                                   const char *vgname, const char *vgid,
+                                   uint32_t vgstatus, int *is_duplicate);
 int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt);
 void lvmcache_del(struct lvmcache_info *info);
 void lvmcache_del_dev(struct device *dev);
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index df1e56b..9d58c53 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1513,13 +1513,12 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 
 	/* Add a new cache entry with PV info or update existing one. */
 	if (!(info = lvmcache_add(fmt->labeller, (const char *) &pv->id,
-				  pv->dev, pv->vg_name,
-				  is_orphan_vg(pv->vg_name) ? pv->vg_name : pv->vg ? (const char *) &pv->vg->id : NULL, 0)))
+				  pv->dev,  pv->label_sector, pv->vg_name,
+				  is_orphan_vg(pv->vg_name) ? pv->vg_name : pv->vg ? (const char *) &pv->vg->id : NULL, 0, NULL)))
 		return_0;
 
+	/* lvmcache_add() creates info and info->label structs for the dev, get info->label. */
 	label = lvmcache_get_label(info);
-	label->sector = pv->label_sector;
-	label->dev = pv->dev;
 
 	lvmcache_update_pv(info, pv, fmt);
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 5f4bcfd..42184de 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -371,8 +371,8 @@ fail:
 	return 0;
 }
 
-static int _text_read(struct labeller *l, struct device *dev, void *label_buf,
-		      struct label **label)
+static int _text_read(struct labeller *labeller, struct device *dev, void *label_buf,
+		      uint64_t label_sector, int *is_duplicate)
 {
 	struct label_header *lh = (struct label_header *) label_buf;
 	struct pv_header *pvhdr;
@@ -382,18 +382,33 @@ static int _text_read(struct labeller *l, struct device *dev, void *label_buf,
 	uint64_t offset;
 	uint32_t ext_version;
 	struct _update_mda_baton baton;
+	struct label *label;
 
 	/*
 	 * PV header base
 	 */
 	pvhdr = (struct pv_header *) ((char *) label_buf + xlate32(lh->offset_xl));
 
-	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev,
+	/*
+	 * FIXME: stop adding the device to lvmcache initially as an orphan
+	 * (and then moving it later) and instead just add it when we know the
+	 * VG.
+	 *
+	 * If another device with this same PVID has already been seen,
+	 * lvmcache_add will put this device in the duplicates list in lvmcache
+	 * and return NULL.  At the end of label_scan, the duplicate devs are
+	 * compared, and if another dev is preferred for this PV, then the
+	 * existing dev is removed from lvmcache and _text_read is called again
+	 * for this dev, and lvmcache_add will add it.
+	 *
+	 * Other reasons for lvmcache_add to return NULL are internal errors.
+	 */
+	if (!(info = lvmcache_add(labeller, (char *)pvhdr->pv_uuid, dev, label_sector,
 				  FMT_TEXT_ORPHAN_VG_NAME,
-				  FMT_TEXT_ORPHAN_VG_NAME, 0)))
+				  FMT_TEXT_ORPHAN_VG_NAME, 0, is_duplicate)))
 		return_0;
 
-	*label = lvmcache_get_label(info);
+	label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, xlate64(pvhdr->device_size_xl));
 
@@ -441,7 +456,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *label_buf,
 	}
 out:
 	baton.info = info;
-	baton.label = *label;
+	baton.label = label;
 
 	/*
 	 * In the vg_read phase, we compare all mdas and decide which to use
diff --git a/lib/label/label.c b/lib/label/label.c
index f6ba2d8..4d008ed 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -356,9 +356,9 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 			  int *is_lvm_device)
 {
 	char label_buf[LABEL_SIZE] __attribute__((aligned(8)));
-	struct label *label = NULL;
 	struct labeller *labeller;
 	uint64_t sector = 0;
+	int is_duplicate = 0;
 	int ret = 0;
 	int pass;
 
@@ -423,17 +423,41 @@ static int _process_block(struct cmd_context *cmd, struct dev_filter *f,
 
 	/*
 	 * This is the point where the scanning code dives into the rest of
-	 * lvm.  ops->read() is usually _text_read() which reads the pv_header,
-	 * mda locations, mda contents.  As these bits of data are read, they
-	 * are saved into lvmcache as info/vginfo structs.
+	 * lvm.  ops->read() is _text_read() which reads the pv_header, mda
+	 * locations, and metadata text.  All of the info it finds about the PV
+	 * and VG is stashed in lvmcache which saves it in the form of
+	 * info/vginfo structs.  That lvmcache info is used later when the
+	 * command wants to read the VG to do something to it.
 	 */
+	ret = labeller->ops->read(labeller, dev, label_buf, sector, &is_duplicate);
 
-	if ((ret = (labeller->ops->read)(labeller, dev, label_buf, &label)) && label) {
-		label->dev = dev;
-		label->sector = sector;
-	} else {
+	if (!ret) {
 		/* FIXME: handle errors */
 		lvmcache_del_dev(dev);
+
+		if (is_duplicate) {
+			/*
+			 * _text_read() called lvmcache_add() which found an
+			 * existing info struct for this PVID but for a
+			 * different dev.  lvmcache_add() did not add an info
+			 * struct for this dev, but added this dev to the list
+			 * of duplicate devs.
+			 */
+			log_warn("WARNING: scan found duplicate PVID %s on %s", dev->pvid, dev_name(dev));
+		} else {
+			/*
+			 * Leave the info in lvmcache because the device is
+			 * present and can still be used even if it has
+			 * metadata that we can't process (we can get metadata
+			 * from another PV/mda.) _text_read only saves mdas
+			 * with good metadata in lvmcache (this includes old
+			 * metadata), and if a PV has no mdas with good
+			 * metadata, then the info for the PV will be in
+			 * lvmcache with empty info->mdas, and it will behave
+			 * like a PV with no mdas (a common configuration.)
+			 */
+			log_warn("WARNING: scan failed to get metadata summary from %s PVID %s", dev_name(dev), dev->pvid);
+		}
 	}
  out:
 	return ret;
diff --git a/lib/label/label.h b/lib/label/label.h
index 8f1f0e2..07bb77d 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -65,7 +65,7 @@ struct label_ops {
 	 * Read a label from a volume.
 	 */
 	int (*read) (struct labeller * l, struct device * dev,
-		     void *label_buf, struct label ** label);
+		     void *label_buf, uint64_t label_sector, int *is_duplicate);
 
 	/*
 	 * Populate label_type etc.


