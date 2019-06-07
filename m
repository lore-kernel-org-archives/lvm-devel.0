From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:12 -0400
Subject: master - add mda arg to add_mda
Message-ID: <201906072108.x57L8Cl6005255@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=889b5d3183314985d4d0930b30f0cd4b0f482f69
Commit:        889b5d3183314985d4d0930b30f0cd4b0f482f69
Parent:        b2447e3538db370d1e12d328c25ca1f078ddabf6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 5 13:24:23 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

add mda arg to add_mda

Allow the caller of lvmcache_add_mda() to have the
new mda returned.
---
 lib/cache/lvmcache.c          |    5 +++--
 lib/cache/lvmcache.h          |    3 ++-
 lib/format_text/format-text.c |    2 +-
 lib/format_text/format-text.h |    3 ++-
 lib/format_text/text_label.c  |    7 +++++--
 5 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f54eff0..3e89b02 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2086,9 +2086,10 @@ void lvmcache_del_bas(struct lvmcache_info *info)
 }
 
 int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
-		     uint64_t start, uint64_t size, unsigned ignored)
+		     uint64_t start, uint64_t size, unsigned ignored,
+		     struct metadata_area **mda_new)
 {
-	return add_mda(info->fmt, NULL, &info->mdas, dev, start, size, ignored);
+	return add_mda(info->fmt, NULL, &info->mdas, dev, start, size, ignored, mda_new);
 }
 
 int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size)
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 16cbb48..21f29ef 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -129,7 +129,8 @@ void lvmcache_del_mdas(struct lvmcache_info *info);
 void lvmcache_del_das(struct lvmcache_info *info);
 void lvmcache_del_bas(struct lvmcache_info *info);
 int lvmcache_add_mda(struct lvmcache_info *info, struct device *dev,
-		     uint64_t start, uint64_t size, unsigned ignored);
+		     uint64_t start, uint64_t size, unsigned ignored,
+		     struct metadata_area **mda_new);
 int lvmcache_add_da(struct lvmcache_info *info, uint64_t start, uint64_t size);
 int lvmcache_add_ba(struct lvmcache_info *info, uint64_t start, uint64_t size);
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index f5e08fa..df1e56b 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1547,7 +1547,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 		// if fmt is not the same as info->fmt we are in trouble
 		if (!lvmcache_add_mda(info, mdac->area.dev,
 				      mdac->area.start, mdac->area.size,
-				      mda_is_ignored(mda)))
+				      mda_is_ignored(mda), NULL))
 			return_0;
 	}
 
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 1300e58..c42d5c0 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -61,7 +61,8 @@ int add_ba(struct dm_pool *mem, struct dm_list *eas,
 	   uint64_t start, uint64_t size);
 void del_bas(struct dm_list *bas);
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
-	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored);
+	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored,
+	    struct metadata_area **mda_new);
 void del_mdas(struct dm_list *mdas);
 
 /* On disk */
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 6eca3c1..5f4bcfd 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -243,7 +243,8 @@ void del_bas(struct dm_list *bas)
 
 /* FIXME: refactor this function with other mda constructor code */
 int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *mdas,
-	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored)
+	    struct device *dev, uint64_t start, uint64_t size, unsigned ignored,
+	    struct metadata_area **mda_new)
 {
 /* FIXME List size restricted by pv_header SECTOR_SIZE */
 	struct metadata_area *mdal, *mda;
@@ -295,6 +296,8 @@ int add_mda(const struct format_type *fmt, struct dm_pool *mem, struct dm_list *
 	mda_set_ignored(mdal, ignored);
 
 	dm_list_add(mdas, &mdal->list);
+	if (mda_new)
+		*mda_new = mdal;
 	return 1;
 }
 
@@ -408,7 +411,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *label_buf,
 	/* Metadata area headers */
 	dlocn_xl++;
 	while ((offset = xlate64(dlocn_xl->offset))) {
-		lvmcache_add_mda(info, dev, offset, xlate64(dlocn_xl->size), 0);
+		lvmcache_add_mda(info, dev, offset, xlate64(dlocn_xl->size), 0, NULL);
 		dlocn_xl++;
 	}
 


