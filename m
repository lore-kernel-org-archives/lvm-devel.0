From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:06:01 +0000 (UTC)
Subject: dev-mornfall-lvmcache - lvmcache: Drop the label->info link.
Message-ID: <20130605120601.8550860F90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e5d18afd3f182bcfc3025ef2aeecaa9b542cc19
Commit:        8e5d18afd3f182bcfc3025ef2aeecaa9b542cc19
Parent:        ec5f5564de0d0e84c1e2359cad06af2477fa4031
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Feb 18 22:15:00 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:36 2013 +0200

lvmcache: Drop the label->info link.

---
 lib/cache/lvmcache.c          |    7 ++-----
 lib/cache/lvmetad.c           |    2 +-
 lib/format_text/format-text.c |    2 +-
 lib/format_text/text_label.c  |   12 +++++++-----
 lib/label/label.h             |    1 -
 lib/metadata/metadata.c       |    4 ++--
 6 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 1c4da0f..f76e479 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -808,11 +808,10 @@ static struct device *_device_from_pvid(const struct id *pvid,
 		}
 
 		if (label_read(info->label->dev, &label, UINT64_C(0))) {
-			info = (struct lvmcache_info *) label->info;
-			if (id_equal(pvid, (struct id *) &info->label->dev->pvid)) {
+			if (id_equal(pvid, (struct id *) &label->dev->pvid)) {
 				if (label_sector)
 					*label_sector = label->sector;
-				return info->label->dev;
+				return label->dev;
                         }
 		}
 	}
@@ -1357,7 +1356,6 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 			return NULL;
 		}
 
-		label->info = info;
 		info->label = label;
 		dm_list_init(&info->list);
 		info->label->dev = dev;
@@ -1418,7 +1416,6 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 			if (!(info->label = label_create(labeller)))
 				/* FIXME leaves info without label! */
 				return_NULL;
-			info->label->info = info;
 			info->label->dev = dev;
 			lvmcache_del_mdas(info);
 			lvmcache_del_das(info);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 7aa8641..069c0ae 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -897,7 +897,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 		return 1;
 	}
 
-	info = (struct lvmcache_info *) label->info;
+	info = lvmcache_info_from_pvid(dev->pvid, 0);
 
 	baton.vg = NULL;
 	baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info),
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 1a16134..c8db5d0 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1455,7 +1455,7 @@ static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 		struct label *label;
 		if (!(label_read(dev, &label, UINT64_C(0))))
 			return_0;
-		info = label->info;
+		info = lvmcache_info_from_pvid(dev->pvid, 0);
 	}
 
 	if (!info)
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 3408590..09a3302 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -99,7 +99,7 @@ static int _text_write(struct label *label, void *buf)
 	strncpy((char *)lh->type, label->type, sizeof(label->type));
 
 	pvhdr = (struct pv_header *) ((char *) buf + xlate32(lh->offset_xl));
-	info = (struct lvmcache_info *) label->info;
+	info = lvmcache_info_from_pvid(label->dev->pvid, 0);
 	pvhdr->device_size_xl = xlate64(lvmcache_device_size(info));
 	memcpy(pvhdr->pv_uuid, &lvmcache_device(info)->pvid, sizeof(struct id));
 	if (!id_write_format((const struct id *)pvhdr->pv_uuid, buffer,
@@ -439,11 +439,13 @@ out:
 static void _text_destroy_label(struct labeller *l __attribute__((unused)),
 				struct label *label)
 {
-	struct lvmcache_info *info = (struct lvmcache_info *) label->info;
+	struct lvmcache_info *info = lvmcache_info_from_pvid(label->dev->pvid, 0);
 
-	lvmcache_del_mdas(info);
-	lvmcache_del_das(info);
-	lvmcache_del_bas(info);
+	if (info) {
+		lvmcache_del_mdas(info);
+		lvmcache_del_das(info);
+		lvmcache_del_bas(info);
+	}
 }
 
 static void _fmt_text_destroy(struct labeller *l)
diff --git a/lib/label/label.h b/lib/label/label.h
index 9a0e07e..c45928a 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -42,7 +42,6 @@ struct label {
 	char type[8];
 	uint64_t sector;
 	struct labeller *labeller;
-	void *info;
 	struct device *dev;
 	struct dm_list mdas;	/* list head for metadata areas */
 	struct dm_list das;	/* list head for data areas */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2fe795c..31c9eba 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3616,7 +3616,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 					  pv_name);
 			return NULL;
 		}
-		info = (struct lvmcache_info *) label->info;
+		info = lvmcache_info_from_pvid(label->dev->pvid, 0);
 	}
 
 	fmt = lvmcache_fmt(info);
@@ -3872,7 +3872,7 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 	/*
 	 * Next, loop through metadata areas
 	 */
-	info = label->info;
+	info = lvmcache_info_from_pvid(label->dev->pvid, 0);
 	lvmcache_foreach_mda(info, _analyze_mda, (void *)lvmcache_fmt(info));
 
 	return 1;


