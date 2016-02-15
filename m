From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:17 +0000 (UTC)
Subject: master - lvmcache/lvmetad: cache PV extension flags
Message-ID: <20160215120817.2F05B60DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7593221f94f9b2b81b169fc526829bfc44c74166
Commit:        7593221f94f9b2b81b169fc526829bfc44c74166
Parent:        54b41db9a6c2ec78c5c768972dda59283563eb9d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 9 12:52:07 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

lvmcache/lvmetad: cache PV extension flags

Store PV extension flags in lvmcache/lvmetad for use throughout the code.
---
 lib/cache/lvmcache.c         |    9 +++++++++
 lib/cache/lvmcache.h         |    3 +++
 lib/cache/lvmetad.c          |    5 +++++
 lib/format1/lvm1-label.c     |    1 +
 lib/format_pool/disk_rep.c   |    1 +
 lib/format_text/text_label.c |    5 ++++-
 6 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 4a4b53f..3218619 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -42,6 +42,7 @@ struct lvmcache_info {
 	const struct format_type *fmt;
 	struct device *dev;
 	uint64_t device_size;	/* Bytes */
+	uint32_t ext_flags;	/* Extension flags */
 	uint32_t status;
 };
 
@@ -2366,6 +2367,14 @@ struct device *lvmcache_device(struct lvmcache_info *info) {
 	return info->dev;
 }
 
+void lvmcache_set_ext_flags(struct lvmcache_info *info, uint32_t flags) {
+	info->ext_flags = flags;
+}
+
+uint32_t lvmcache_ext_flags(struct lvmcache_info *info) {
+	return info->ext_flags;
+}
+
 int lvmcache_is_orphan(struct lvmcache_info *info) {
 	if (!info->vginfo)
 		return 1; /* FIXME? */
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 371ac8e..7de4e14 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -156,6 +156,9 @@ int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
 int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size);
 int lvmcache_add_ba(struct lvmcache_info *info, uint64_t start, uint64_t size);
 
+void lvmcache_set_ext_flags(struct lvmcache_info *info, uint32_t flags);
+uint32_t lvmcache_ext_flags(struct lvmcache_info *info);
+
 const struct format_type *lvmcache_fmt(struct lvmcache_info *info);
 struct label *lvmcache_get_label(struct lvmcache_info *info);
 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 90ff4cb..70ab44f 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -368,6 +368,7 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 	dev_t devt = dm_config_find_int(cn->child, "device", 0);
 	uint64_t devsize = dm_config_find_int64(cn->child, "dev_size", 0),
 		 label_sector = dm_config_find_int64(cn->child, "label_sector", 0);
+	uint32_t ext_flags = (uint32_t) dm_config_find_int64(cn->child, "ext_flags", 0);
 
 	if (!fmt && fmt_name)
 		fmt = get_format_by_name(cmd, fmt_name);
@@ -478,6 +479,9 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 	}
 
 	lvmcache_set_preferred_duplicates((const char *)&vgid);
+
+	lvmcache_set_ext_flags(info, ext_flags);
+
 	return 1;
 }
 
@@ -1047,6 +1051,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 			       "format = %s", fmt->name,
 			       "label_sector = %"PRId64, (int64_t) label_sector,
 			       "id = %s", uuid,
+			       "ext_flags = %"PRId64, (int64_t) lvmcache_ext_flags(info),
 			       NULL))
 	{
 		dm_config_destroy(pvmeta);
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index b600bd7..903a430 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -80,6 +80,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 	*label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, ((uint64_t)xlate32(pvd->pv_size)) << SECTOR_SHIFT);
+	lvmcache_set_ext_flags(info, 0);
 	lvmcache_del_mdas(info);
 	lvmcache_del_bas(info);
 	lvmcache_make_valid(info);
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 688c521..6d8787e 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -104,6 +104,7 @@ int read_pool_label(struct pool_list *pl, struct labeller *l,
 		*label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, ((uint64_t)xlate32_be(pd->pl_blocks)) << SECTOR_SHIFT);
+	lvmcache_set_ext_flags(info, 0);
 	lvmcache_del_mdas(info);
 	lvmcache_del_bas(info);
 	lvmcache_make_valid(info);
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 2865226..c62cf5a 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -124,7 +124,7 @@ static int _text_write(struct label *label, void *buf)
 	 */
 	pvhdr_ext = (struct pv_header_extension *) ((char *) baton.pvh_dlocn_xl);
 	pvhdr_ext->version = xlate32(PV_HEADER_EXTENSION_VSN);
-	pvhdr_ext->flags = 0; /* no flags yet */
+	pvhdr_ext->flags = xlate32(lvmcache_ext_flags(info));
 
 	/* List of bootloader area locations */
 	baton.pvh_dlocn_xl = &pvhdr_ext->bootloader_areas_xl[0];
@@ -421,6 +421,9 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	log_debug_metadata("%s: PV header extension version %" PRIu32 " found",
 			   dev_name(dev), ext_version);
 
+	/* Extension flags */
+	lvmcache_set_ext_flags(info, xlate32(pvhdr_ext->flags));
+
 	/* Bootloader areas */
 	dlocn_xl = pvhdr_ext->bootloader_areas_xl;
 	while ((offset = xlate64(dlocn_xl->offset))) {


