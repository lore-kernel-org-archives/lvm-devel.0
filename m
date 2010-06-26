From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:37 -0400
Subject: [PATCH 06/38] Allow raw_read_mda_header to be called from text_label.c.
In-Reply-To: <1277520789-6808-6-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We'd like to pass in mda_header to vgname_from_mda().  In order to
do this, we need to call raw_read_mda_header() from text_label.c,
_text_read(), which gets called from the label_read() path, and
peers into the metadata and update vginfo cache.  We should check
the disable bit here, and if set, not peer into the vg metadata,
thus reducing the I/O to disk.

In the process, move vgname_from_mda() to layout.h, since the fn
only gets called from format_text code, and we need the mda_header
definition from the private layout.h.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c |   33 +++++++++++++++++++--------------
 lib/format_text/format-text.h |    5 -----
 lib/format_text/layout.h      |   11 +++++++++++
 lib/format_text/text_label.c  |   15 +++++++++++++--
 4 files changed, 43 insertions(+), 21 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index dc730fb..f9668bc 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -37,9 +37,6 @@
 #include <dirent.h>
 #include <ctype.h>
 
-static struct mda_header *_raw_read_mda_header(const struct format_type *fmt,
-					       struct device_area *dev_area);
-
 static struct format_instance *_text_create_text_instance(const struct format_type
 						     *fmt, const char *vgname,
 						     const char *vgid,
@@ -181,7 +178,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 	if (!dev_open(area->dev))
 		return_0;
 
-	if (!(mdah = _raw_read_mda_header(fmt, area)))
+	if (!(mdah = raw_read_mda_header(fmt, area)))
 		goto_out;
 
 	rlocn = mdah->raw_locns;
@@ -308,8 +305,8 @@ static void _xlate_mdah(struct mda_header *mdah)
 	}
 }
 
-static struct mda_header *_raw_read_mda_header(const struct format_type *fmt,
-					       struct device_area *dev_area)
+struct mda_header *raw_read_mda_header(const struct format_type *fmt,
+				       struct device_area *dev_area)
 {
 	struct mda_header *mdah;
 
@@ -459,7 +456,7 @@ static int _raw_holds_vgname(struct format_instance *fid,
 	if (!dev_open(dev_area->dev))
 		return_0;
 
-	if (!(mdah = _raw_read_mda_header(fid->fmt, dev_area)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, dev_area)))
 		return_0;
 
 	if (_find_vg_rlocn(dev_area, mdah, vgname, &noprecommit))
@@ -483,7 +480,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	char *desc;
 	uint32_t wrap = 0;
 
-	if (!(mdah = _raw_read_mda_header(fid->fmt, area)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, area)))
 		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(area, mdah, vgname, &precommitted))) {
@@ -583,7 +580,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!dev_open(mdac->area.dev))
 		return_0;
 
-	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
 	rlocn = _find_vg_rlocn(&mdac->area, mdah,
@@ -689,7 +686,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	if (!found)
 		return 1;
 
-	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah,
@@ -800,7 +797,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!dev_open(mdac->area.dev))
 		return_0;
 
-	if (!(mdah = _raw_read_mda_header(fid->fmt, &mdac->area)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area)))
 		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, vg->name, &noprecommit))) {
@@ -1083,12 +1080,12 @@ static int _scan_file(const struct format_type *fmt)
 }
 
 const char *vgname_from_mda(const struct format_type *fmt,
+			    struct mda_header *mdah,
 			    struct device_area *dev_area, struct id *vgid,
 			    uint64_t *vgstatus, char **creation_host,
 			    uint64_t *mda_free_sectors)
 {
 	struct raw_locn *rlocn;
-	struct mda_header *mdah;
 	uint32_t wrap = 0;
 	const char *vgname = NULL;
 	unsigned int len = 0;
@@ -1099,7 +1096,7 @@ const char *vgname_from_mda(const struct format_type *fmt,
 	if (mda_free_sectors)
 		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
 
-	if (!(mdah = _raw_read_mda_header(fmt, dev_area)))
+	if (!mdah)
 		goto_out;
 
 	/* FIXME Cope with returning a list */
@@ -1188,6 +1185,7 @@ static int _scan_raw(const struct format_type *fmt)
 	struct format_instance fid;
 	struct id vgid;
 	uint64_t vgstatus;
+	struct mda_header *mdah;
 
 	raw_list = &((struct mda_lists *) fmt->private)->raws;
 
@@ -1201,13 +1199,20 @@ static int _scan_raw(const struct format_type *fmt)
 			continue;
 		}
 
-		if ((vgname = vgname_from_mda(fmt, &rl->dev_area, &vgid, &vgstatus,
+		if (!(mdah = raw_read_mda_header(fmt, &rl->dev_area))) {
+			stack;
+			goto close_dev;
+		}
+
+		if ((vgname = vgname_from_mda(fmt, mdah,
+					      &rl->dev_area, &vgid, &vgstatus,
 					      NULL, NULL))) {
 			vg = _vg_read_raw_area(&fid, vgname, &rl->dev_area, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
 
 		}
+	close_dev:
 		if (!dev_close(rl->dev_area.dev))
 			stack;
 	}
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 9750ffa..eaf1e83 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -59,9 +59,4 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 	    struct device *dev, uint64_t start, uint64_t size);
 void del_mdas(struct dm_list *mdas);
 
-const char *vgname_from_mda(const struct format_type *fmt,
-			    struct device_area *dev_area, struct id *vgid,
-			    uint64_t *vgstatus, char **creation_host,
-			    uint64_t *mda_free_sectors);
-
 #endif
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index b7b2f2b..1e51a8b 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -76,6 +76,9 @@ struct mda_header {
 	struct raw_locn raw_locns[0];	/* NULL-terminated list */
 } __attribute__ ((packed));
 
+struct mda_header *raw_read_mda_header(const struct format_type *fmt,
+				       struct device_area *dev_area);
+
 struct mda_lists {
 	struct dm_list dirs;
 	struct dm_list raws;
@@ -86,6 +89,7 @@ struct mda_lists {
 struct mda_context {
 	struct device_area area;
 	uint64_t free_sectors;
+	struct mda_header *mdah; /* copy of the on-disk mdah */
 	struct raw_locn rlocn;	/* Store inbetween write and commit */
 };
 
@@ -96,4 +100,11 @@ struct mda_context {
 #define LVM2_LABEL "LVM2 001"
 #define MDA_SIZE_MIN (8 * (unsigned) lvm_getpagesize())
 
+
+const char *vgname_from_mda(const struct format_type *fmt,
+			    struct mda_header *mdah,
+			    struct device_area *dev_area, struct id *vgid,
+			    uint64_t *vgstatus, char **creation_host,
+			    uint64_t *mda_free_sectors);
+
 #endif
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 6f897e1..7083b89 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -262,6 +262,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	const char *vgname;
 	uint64_t vgstatus;
 	char *creation_host;
+	struct mda_header *mdah;
 
 	pvhdr = (struct pv_header *) ((void *) buf + xlate32(lh->offset_xl));
 
@@ -303,13 +304,23 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 			stack;
 			continue;
 		}
-		if ((vgname = vgname_from_mda(info->fmt, &mdac->area,
+		if (!(mdah = raw_read_mda_header(info->fmt, &mdac->area))) {
+			stack;
+			goto close_dev;
+		}
+
+		if ((vgname = vgname_from_mda(info->fmt, mdah,
+					      &mdac->area,
 					      &vgid, &vgstatus, &creation_host,
 					      &mdac->free_sectors)) &&
 		    !lvmcache_update_vgname_and_id(info, vgname,
 						   (char *) &vgid, vgstatus,
-						   creation_host))
+						   creation_host)) {
+			if (!dev_close(mdac->area.dev))
+					stack;
 			return_0;
+		}
+	close_dev:
 		if (!dev_close(mdac->area.dev))
 			stack;
 	}
-- 
1.6.0.6


