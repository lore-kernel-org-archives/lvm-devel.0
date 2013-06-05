From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:06:03 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvmcache: Drop a superfluous "fmt" pointer from lvmcache_info.
Message-ID: <20130605120603.A382361057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db59f5661cd425b1a0fc1c075ec1af19d25eb69f
Commit:        db59f5661cd425b1a0fc1c075ec1af19d25eb69f
Parent:        8e5d18afd3f182bcfc3025ef2aeecaa9b542cc19
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Feb 18 23:02:21 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:36 2013 +0200

lvmcache: Drop a superfluous "fmt" pointer from lvmcache_info.

---
 lib/cache/lvmcache.c         |   24 ++++++++++++------------
 lib/format1/lvm1-label.c     |    2 +-
 lib/format_pool/pool_label.c |    2 +-
 lib/format_text/text_label.c |    4 ++--
 lib/label/label.c            |    5 +++++
 lib/label/label.h            |    3 ++-
 6 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f76e479..8d50919 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -39,7 +39,6 @@ struct lvmcache_info {
 	struct dm_list list;	/* Join VG members together */
 	struct lvmcache_vginfo *vginfo;	/* NULL == unknown */
 	struct label *label; /* move to PV */
-	const struct format_type *fmt;
 	uint64_t device_size;	/* move to label */ /* Bytes */
 	uint32_t status;
 };
@@ -1277,7 +1276,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 	if (!vgname && !info->vginfo) {
 		log_error(INTERNAL_ERROR "NULL vgname handed to cache");
 		/* FIXME Remove this */
-		vgname = info->fmt->orphan_vg_name;
+		vgname = label_fmt(info->label)->orphan_vg_name;
 		vgid = vgname;
 	}
 
@@ -1296,7 +1295,7 @@ int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
 		info->status &= ~CACHE_INVALID;
 
 	if (!_lvmcache_update_vgname(info, vgname, vgid, vgstatus,
-				     creation_host, info->fmt) ||
+				     creation_host, label_fmt(info->label)) ||
 	    !_lvmcache_update_vgid(info, info->vginfo, vgid) ||
 	    !_lvmcache_update_vgstatus(info, vgstatus, creation_host))
 		return_0;
@@ -1423,7 +1422,6 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 		label = info->label;
 	}
 
-	info->fmt = (const struct format_type *) labeller->private;
 	info->status |= CACHE_INVALID;
 
 	if (!_lvmcache_update_pvid(info, pvid_s)) {
@@ -1546,7 +1544,7 @@ static int _get_pv_if_in_vg(struct lvmcache_info *info,
 		strcpy(vgname, info->vginfo->vgname);
 		memcpy(vgid, info->vginfo->vgid, sizeof(vgid));
 
-		if (get_pv_from_vg_by_id(info->fmt, vgname, vgid,
+		if (get_pv_from_vg_by_id(label_fmt(info->label), vgname, vgid,
 					 info->label->dev->pvid, pv))
 			return 1;
 	}
@@ -1566,7 +1564,7 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 
 	/* Perform full scan (just the first time) and try again */
 	if (!scan_label_only && !critical_section() && !full_scan_done()) {
-		lvmcache_label_scan(info->fmt->cmd, 2);
+		lvmcache_label_scan(label_fmt(info->label)->cmd, 2);
 
 		if (_get_pv_if_in_vg(info, pv))
 			return 1;
@@ -1574,7 +1572,7 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 
 	/* Orphan */
 	pv->dev = info->label->dev;
-	pv->fmt = info->fmt;
+	pv->fmt = label_fmt(info->label);
 	pv->size = info->device_size >> SECTOR_SHIFT;
 	pv->vg_name = FMT_TEXT_ORPHAN_VG_NAME;
 	memcpy(&pv->id, &info->label->dev->pvid, sizeof(pv->id));
@@ -1606,9 +1604,9 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 
 int lvmcache_check_format(struct lvmcache_info *info, const struct format_type *fmt)
 {
-	if (info->fmt != fmt) {
+	if (label_fmt(info->label) != fmt) {
 		log_error("PV %s is a different format (seqno %s)",
-			  dev_name(info->label->dev), info->fmt->name);
+			  dev_name(info->label->dev), label_fmt(info->label)->name);
 		return 0;
 	}
 	return 1;
@@ -1638,7 +1636,7 @@ void lvmcache_del_bas(struct lvmcache_info *info)
 int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
 		     uint64_t start, uint64_t size, unsigned ignored)
 {
-	return add_mda(info->fmt, NULL, &info->label->mdas, dev, start, size, ignored);
+	return add_mda(label_fmt(info->label), NULL, &info->label->mdas, dev, start, size, ignored);
 }
 
 int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size)
@@ -1655,7 +1653,9 @@ void lvmcache_update_pv(struct lvmcache_info *info, struct physical_volume *pv,
 			const struct format_type *fmt)
 {
 	info->device_size = pv->size << SECTOR_SHIFT;
-	info->fmt = fmt;
+	if (label_fmt(info->label) != fmt)
+		log_error(INTERNAL_ERROR "Unexpected format mismatch on %s: %s found while %s expected.",
+			  dev_name(pv->dev), fmt->name, label_fmt(info->label)->name);
 }
 
 int lvmcache_update_das(struct lvmcache_info *info, struct physical_volume *pv)
@@ -1812,5 +1812,5 @@ uint64_t lvmcache_smallest_mda_size(struct lvmcache_info *info)
 }
 
 const struct format_type *lvmcache_fmt(struct lvmcache_info *info) {
-	return info->fmt;
+	return label_fmt(info->label);
 }
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 6138a05..c5f9f35 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -122,7 +122,7 @@ struct labeller *lvm1_labeller_create(struct format_type *fmt)
 	}
 
 	l->ops = &_lvm1_ops;
-	l->private = (const void *) fmt;
+	l->fmt = fmt;
 
 	return l;
 }
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
index 7059b98..d453dd9 100644
--- a/lib/format_pool/pool_label.c
+++ b/lib/format_pool/pool_label.c
@@ -99,7 +99,7 @@ struct labeller *pool_labeller_create(struct format_type *fmt)
 	}
 
 	l->ops = &_pool_ops;
-	l->private = (const void *) fmt;
+	l->fmt = fmt;
 
 	return l;
 }
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 09a3302..812ec2c 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -316,7 +316,7 @@ struct _update_mda_baton {
 static int _update_mda(struct metadata_area *mda, void *baton)
 {
 	struct _update_mda_baton *p = baton;
-	const struct format_type *fmt = p->label->labeller->private; // Oh dear.
+	const struct format_type *fmt = label_fmt(p->label);
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
 	const char *vgname = NULL;
@@ -473,7 +473,7 @@ struct labeller *text_labeller_create(const struct format_type *fmt)
 	}
 
 	l->ops = &_text_ops;
-	l->private = (const void *) fmt;
+	l->fmt = fmt;
 
 	return l;
 }
diff --git a/lib/label/label.c b/lib/label/label.c
index 9c931f5..2acba14 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -392,3 +392,8 @@ struct label *label_create(struct labeller *labeller)
 
 	return label;
 }
+
+const struct format_type *label_fmt(struct label *label)
+{
+	return label->labeller->fmt;
+}
diff --git a/lib/label/label.h b/lib/label/label.h
index c45928a..f8230db 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -90,7 +90,7 @@ struct label_ops {
 
 struct labeller {
 	struct label_ops *ops;
-	const void *private;
+	const struct format_type *fmt;
 };
 
 int label_init(void);
@@ -107,5 +107,6 @@ int label_write(struct device *dev, struct label *label);
 int label_verify(struct device *dev);
 struct label *label_create(struct labeller *labeller);
 void label_destroy(struct label *label);
+const struct format_type *label_fmt(struct label *label);
 
 #endif


