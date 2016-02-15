From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:19 +0000 (UTC)
Subject: master - lvmcache/lvmetad: cache PV extension version
Message-ID: <20160215120819.4C03C60DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71ea2e1602f9b058ee1cad445a07bf80413f833f
Commit:        71ea2e1602f9b058ee1cad445a07bf80413f833f
Parent:        7593221f94f9b2b81b169fc526829bfc44c74166
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 11 16:25:36 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

lvmcache/lvmetad: cache PV extension version

Store PV extension version in lvmcache/lvmetad for use throughout the code.
---
 lib/cache/lvmcache.c         |    9 +++++++++
 lib/cache/lvmcache.h         |    2 ++
 lib/cache/lvmetad.c          |    3 +++
 lib/format1/lvm1-label.c     |    1 +
 lib/format_pool/disk_rep.c   |    1 +
 lib/format_text/text_label.c |    3 +++
 6 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 3218619..1945a74 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -42,6 +42,7 @@ struct lvmcache_info {
 	const struct format_type *fmt;
 	struct device *dev;
 	uint64_t device_size;	/* Bytes */
+	uint32_t ext_version;   /* Extension version */
 	uint32_t ext_flags;	/* Extension flags */
 	uint32_t status;
 };
@@ -2366,6 +2367,14 @@ void lvmcache_set_device_size(struct lvmcache_info *info, uint64_t size) {
 struct device *lvmcache_device(struct lvmcache_info *info) {
 	return info->dev;
 }
+void lvmcache_set_ext_version(struct lvmcache_info *info, uint32_t version)
+{
+	info->ext_version = version;
+}
+
+uint32_t lvmcache_ext_version(struct lvmcache_info *info) {
+	return info->ext_version;
+}
 
 void lvmcache_set_ext_flags(struct lvmcache_info *info, uint32_t flags) {
 	info->ext_flags = flags;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 7de4e14..9ca0379 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -156,6 +156,8 @@ int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
 int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size);
 int lvmcache_add_ba(struct lvmcache_info *info, uint64_t start, uint64_t size);
 
+void lvmcache_set_ext_version(struct lvmcache_info *info, uint32_t version);
+uint32_t lvmcache_ext_version(struct lvmcache_info *info);
 void lvmcache_set_ext_flags(struct lvmcache_info *info, uint32_t flags);
 uint32_t lvmcache_ext_flags(struct lvmcache_info *info);
 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 70ab44f..7d6356d 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -369,6 +369,7 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 	uint64_t devsize = dm_config_find_int64(cn->child, "dev_size", 0),
 		 label_sector = dm_config_find_int64(cn->child, "label_sector", 0);
 	uint32_t ext_flags = (uint32_t) dm_config_find_int64(cn->child, "ext_flags", 0);
+	uint32_t ext_version = (uint32_t) dm_config_find_int64(cn->child, "ext_version", 0);
 
 	if (!fmt && fmt_name)
 		fmt = get_format_by_name(cmd, fmt_name);
@@ -481,6 +482,7 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 	lvmcache_set_preferred_duplicates((const char *)&vgid);
 
 	lvmcache_set_ext_flags(info, ext_flags);
+	lvmcache_set_ext_version(info, ext_version);
 
 	return 1;
 }
@@ -1051,6 +1053,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 			       "format = %s", fmt->name,
 			       "label_sector = %"PRId64, (int64_t) label_sector,
 			       "id = %s", uuid,
+			       "ext_version = %"PRId64, (int64_t) lvmcache_ext_version(info),
 			       "ext_flags = %"PRId64, (int64_t) lvmcache_ext_flags(info),
 			       NULL))
 	{
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index 903a430..f5ce1e8 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -80,6 +80,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
 	*label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, ((uint64_t)xlate32(pvd->pv_size)) << SECTOR_SHIFT);
+	lvmcache_set_ext_version(info, 0);
 	lvmcache_set_ext_flags(info, 0);
 	lvmcache_del_mdas(info);
 	lvmcache_del_bas(info);
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 6d8787e..fd11380 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -104,6 +104,7 @@ int read_pool_label(struct pool_list *pl, struct labeller *l,
 		*label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, ((uint64_t)xlate32_be(pd->pl_blocks)) << SECTOR_SHIFT);
+	lvmcache_set_ext_version(info, 0);
 	lvmcache_set_ext_flags(info, 0);
 	lvmcache_del_mdas(info);
 	lvmcache_del_bas(info);
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index c62cf5a..6edfae7 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -421,6 +421,9 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	log_debug_metadata("%s: PV header extension version %" PRIu32 " found",
 			   dev_name(dev), ext_version);
 
+	/* Extension version */
+	lvmcache_set_ext_version(info, xlate32(pvhdr_ext->version));
+
 	/* Extension flags */
 	lvmcache_set_ext_flags(info, xlate32(pvhdr_ext->flags));
 


