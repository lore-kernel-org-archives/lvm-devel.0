From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Mar 2015 13:31:42 +0000 (UTC)
Subject: master - lib: reduce parsing in vgname_from_mda
Message-ID: <20150306133142.3A771600E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9b28a4f2105b92fdfc9f3915859e0deec4004a0
Commit:        a9b28a4f2105b92fdfc9f3915859e0deec4004a0
Parent:        7e7411966afc4309cdd91bfed4846720b308c84d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 6 10:24:26 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 6 13:53:13 2015 +0100

lib: reduce parsing in vgname_from_mda

Use similar logic as with text_vg_import_fd() and avoid repeated
parsing of same mda and its config tree for vgname_from_mda().

Remember last parsed vgname, vgid and creation_host in labeller
structure and if the  metadata have the same size and checksum,
return this stored info.

TODO: The reuse of labeller struct is not ideal, some lvmcache API for
this functionality would be nicer.
---
 WHATS_NEW                       |    1 +
 lib/format_text/format-text.c   |   23 ++++++++++++++++++-----
 lib/format_text/import-export.h |    9 +++++----
 lib/format_text/import.c        |   13 +++++++++++--
 lib/format_text/layout.h        |    4 +++-
 lib/format_text/text_label.c    |   27 ++++++++++++++++-----------
 lib/label/label.h               |    8 ++++++++
 7 files changed, 62 insertions(+), 23 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ef5abcd..9bf8699 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Reduce number of VG metadata parsing when looking for vgname on a PV.
   Avoid reparsing same metadata when reading same metadata from multiple PVs.
   Save extra device open/close when scanning device for size.
   Fix seg_monitor field to report status also for mirrors and thick snapshots.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 375a793..d80ebf6 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1124,14 +1124,14 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 }
 
 const char *vgname_from_mda(const struct format_type *fmt,
-			    struct mda_header *mdah,
-			    struct device_area *dev_area, struct id *vgid,
+			    struct mda_header *mdah, struct device_area *dev_area,
+			    uint32_t *mda_checksum, size_t *mda_size,
+			    const char *vgname, struct id *vgid,
 			    uint64_t *vgstatus, char **creation_host,
 			    uint64_t *mda_free_sectors)
 {
 	struct raw_locn *rlocn;
 	uint32_t wrap = 0;
-	const char *vgname = NULL;
 	unsigned int len = 0;
 	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
 	char uuid[64] __attribute__((aligned(8)));
@@ -1182,6 +1182,10 @@ const char *vgname_from_mda(const struct format_type *fmt,
 		return NULL;
 	}
 
+	/* Check if it could be the same VG */
+	if ((rlocn->checksum != *mda_checksum) || (rlocn->size != *mda_size))
+		vgname = NULL; /* nope, reset to NULL */
+
 	/* FIXME 64-bit */
 	if (!(vgname = text_vgname_import(fmt, dev_area->dev,
 					  (off_t) (dev_area->start +
@@ -1190,6 +1194,7 @@ const char *vgname_from_mda(const struct format_type *fmt,
 					  (off_t) (dev_area->start +
 						   MDA_HEADER_SIZE),
 					  wrap, calc_crc, rlocn->checksum,
+					  vgname,
 					  vgid, vgstatus, creation_host)))
 		return_NULL;
 
@@ -1217,6 +1222,9 @@ const char *vgname_from_mda(const struct format_type *fmt,
 			*mda_free_sectors = ((buffer_size - 2 * current_usage) / 2) >> SECTOR_SHIFT;
 	}
 
+	*mda_checksum = rlocn->checksum;
+	*mda_size = rlocn->size;
+
 	return vgname;
 }
 
@@ -1230,6 +1238,8 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 	struct id vgid;
 	uint64_t vgstatus;
 	struct mda_header *mdah;
+	uint32_t mda_checksum = 0;
+	size_t mda_size = 0;
 
 	raw_list = &((struct mda_lists *) fmt->private)->raws;
 
@@ -1249,9 +1259,12 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 			goto close_dev;
 		}
 
+		/* TODO: caching as in vgname_from_mda() (trigger this code?) */
 		if ((scanned_vgname = vgname_from_mda(fmt, mdah,
-					      &rl->dev_area, &vgid, &vgstatus,
-					      NULL, NULL))) {
+						      &rl->dev_area,
+						      &mda_checksum, &mda_size, NULL,
+						      &vgid, &vgstatus,
+						      NULL, NULL))) {
 			vg = _vg_read_raw_area(&fid, scanned_vgname, &rl->dev_area, 0, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index d4e25f0..4b2756d 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -79,10 +79,11 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       time_t *when, char **desc);
 const char *text_vgname_import(const struct format_type *fmt,
 			       struct device *dev,
-                               off_t offset, uint32_t size,
-                               off_t offset2, uint32_t size2,
-                               checksum_fn_t checksum_fn, uint32_t checksum,
-                               struct id *vgid, uint64_t *vgstatus,
+			       off_t offset, uint32_t size,
+			       off_t offset2, uint32_t size2,
+			       checksum_fn_t checksum_fn, uint32_t checksum,
+			       const char *vgname,
+			       struct id *vgid, uint64_t *vgstatus,
 			       char **creation_host);
 
 #endif
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 8a1771a..c8ba5ce 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -32,17 +32,22 @@ static void _init_text_import(void)
 	_text_import_initialised = 1;
 }
 
+/*
+ * Find out vgname on a given device.
+ * If the checksum and metadata size is matching the vgname discovered in last read
+ * (multi PVs VG) could be passed back and it may skip parsing of such metadata.
+ */
 const char *text_vgname_import(const struct format_type *fmt,
 			       struct device *dev,
 			       off_t offset, uint32_t size,
 			       off_t offset2, uint32_t size2,
 			       checksum_fn_t checksum_fn, uint32_t checksum,
+			       const char *vgname,
 			       struct id *vgid, uint64_t *vgstatus,
 			       char **creation_host)
 {
 	struct dm_config_tree *cft;
 	struct text_vg_version_ops **vsn;
-	const char *vgname = NULL;
 
 	_init_text_import();
 
@@ -51,11 +56,15 @@ const char *text_vgname_import(const struct format_type *fmt,
 
 	if ((!dev && !config_file_read(cft)) ||
 	    (dev && !config_file_read_fd(cft, dev, offset, size,
-					 offset2, size2, checksum_fn, checksum, 0))) {
+					 offset2, size2, checksum_fn, checksum,
+					 (vgname != NULL)))) {
 		log_error("Couldn't read volume group metadata.");
 		goto out;
 	}
 
+	if (vgname)
+		goto out; /* Everything is matching from the last call */
+
 	/*
 	 * Find a set of version functions that can read this file
 	 */
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 4753fde..5f6b549 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -100,7 +100,9 @@ struct mda_context {
 
 const char *vgname_from_mda(const struct format_type *fmt,
 			    struct mda_header *mdah,
-			    struct device_area *dev_area, struct id *vgid,
+			    struct device_area *dev_area,
+			    uint32_t *mda_checksum, size_t *mda_size,
+			    const char *vgname, struct id *vgid,
 			    uint64_t *vgstatus, char **creation_host,
 			    uint64_t *mda_free_sectors);
 
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index e451be4..3a4835c 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -319,10 +319,14 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 	const struct format_type *fmt = p->label->labeller->fmt;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
-	const char *vgname = NULL;
-	struct id vgid;
-	uint64_t vgstatus;
-	char *creation_host;
+	struct labeller *l = p->label->labeller;
+
+	/*
+	 * Using the labeller struct to preserve info about
+	 * the last parsed vgname, vgid, creation host
+	 *
+	 * TODO: make lvmcache smarter and move this cache logic there
+	 */
 
 	if (!dev_open_readonly(mdac->area.dev)) {
 		mda_set_ignored(mda, 1);
@@ -346,17 +350,18 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	if ((vgname = vgname_from_mda(fmt, mdah,
-				      &mdac->area,
-				      &vgid, &vgstatus, &creation_host,
-				      &mdac->free_sectors)) &&
-	    !lvmcache_update_vgname_and_id(p->info, vgname,
-					   (char *) &vgid, vgstatus,
-					   creation_host)) {
+	if ((l->vgname = vgname_from_mda(fmt, mdah, &mdac->area,
+					 &l->mda_checksum, &l->mda_size, l->vgname,
+					 &l->vgid, &l->vgstatus, &l->creation_host,
+					 &mdac->free_sectors)) &&
+	    !lvmcache_update_vgname_and_id(p->info, l->vgname,
+					   (char *) &l->vgid, l->vgstatus,
+					   l->creation_host)) {
 		if (!dev_close(mdac->area.dev))
 			stack;
 		return_0;
 	}
+
 close_dev:
 	if (!dev_close(mdac->area.dev))
 		stack;
diff --git a/lib/label/label.h b/lib/label/label.h
index 253e1e8..831977f 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -89,6 +89,14 @@ struct label_ops {
 struct labeller {
 	struct label_ops *ops;
 	const struct format_type *fmt;
+
+	/* Caching info */
+	const char *vgname;
+	struct id vgid;
+	uint64_t vgstatus;
+	char *creation_host;
+	uint32_t mda_checksum;
+	size_t mda_size;
 };
 
 int label_init(void);


