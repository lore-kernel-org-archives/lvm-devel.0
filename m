From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 3 Jan 2018 19:07:30 -0500
Subject: master - format_text: Allocate update_mda baton from mempool.
Message-ID: <201801040007.w0407UNw000727@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=111a9fcff5ace7391a9247678c8257da60cc37e6
Commit:        111a9fcff5ace7391a9247678c8257da60cc37e6
Parent:        5a846e09297a56b6fdb0ba85a215164d08204589
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 3 23:53:00 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 3 23:53:00 2018 +0000

format_text: Allocate update_mda baton from mempool.

Also store return code.  Note that fatal and non-fatal errors while
handling the mda aren't currently distinguished.
---
 lib/format_text/text_label.c |   56 +++++++++++++++++++++++++++--------------
 1 files changed, 37 insertions(+), 19 deletions(-)

diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index d5e4820..42cf5b3 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -36,14 +36,14 @@ static int _text_can_handle(struct labeller *l __attribute__((unused)),
 	return 0;
 }
 
-struct _dl_setup_baton {
+struct dl_setup_baton {
 	struct disk_locn *pvh_dlocn_xl;
 	struct device *dev;
 };
 
 static int _da_setup(struct disk_locn *da, void *baton)
 {
-	struct _dl_setup_baton *p = baton;
+	struct dl_setup_baton *p = baton;
 	p->pvh_dlocn_xl->offset = xlate64(da->offset);
 	p->pvh_dlocn_xl->size = xlate64(da->size);
 	p->pvh_dlocn_xl++;
@@ -57,7 +57,7 @@ static int _ba_setup(struct disk_locn *ba, void *baton)
 
 static int _mda_setup(struct metadata_area *mda, void *baton)
 {
-	struct _dl_setup_baton *p = baton;
+	struct dl_setup_baton *p = baton;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 
 	if (mdac->area.dev != p->dev)
@@ -72,7 +72,7 @@ static int _mda_setup(struct metadata_area *mda, void *baton)
 
 static int _dl_null_termination(void *baton)
 {
-	struct _dl_setup_baton *p = baton;
+	struct dl_setup_baton *p = baton;
 
 	p->pvh_dlocn_xl->offset = xlate64(UINT64_C(0));
 	p->pvh_dlocn_xl->size = xlate64(UINT64_C(0));
@@ -87,7 +87,7 @@ static int _text_write(struct label *label, void *buf)
 	struct pv_header *pvhdr;
 	struct pv_header_extension *pvhdr_ext;
 	struct lvmcache_info *info;
-	struct _dl_setup_baton baton;
+	struct dl_setup_baton baton;
 	char buffer[64] __attribute__((aligned(8)));
 	int ba1, da1, mda1, mda2;
 
@@ -319,15 +319,16 @@ static int _text_initialise_label(struct labeller *l __attribute__((unused)),
 	return 1;
 }
 
-struct _update_mda_baton {
+struct update_mda_baton {
 	struct lvmcache_info *info;
 	struct label *label;
+	int ret;
 };
 
 static int _update_mda(struct metadata_area *mda, void *baton)
 {
-	struct _update_mda_baton *p = baton;
-	const struct format_type *fmt = p->label->labeller->fmt;
+	struct update_mda_baton *umb = baton;
+	const struct format_type *fmt = umb->label->labeller->fmt;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
 	struct lvmcache_vgsummary vgsummary = { 0 };
@@ -361,11 +362,17 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	if (vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &vgsummary,
-			     &mdac->free_sectors) &&
-	    !lvmcache_update_vgname_and_id(p->info, &vgsummary)) {
+	if (!vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &vgsummary,
+			     &mdac->free_sectors)) {
+		/* FIXME Separate fatal and non-fatal error cases? */
+		stack;
+		goto close_dev;
+	}
+
+	if (!lvmcache_update_vgname_and_id(umb->info, &vgsummary)) {
 		if (!dev_close(mdac->area.dev))
 			stack;
+		umb->ret = 0;
 		return_0;
 	}
 
@@ -376,8 +383,7 @@ close_dev:
 	return 1;
 }
 
-static int _text_read(struct labeller *l, struct device *dev, void *buf,
-		 struct label **label)
+static int _text_read(struct labeller *l, struct device *dev, void *buf, struct label **label)
 {
 	struct label_header *lh = (struct label_header *) buf;
 	struct pv_header *pvhdr;
@@ -386,7 +392,8 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	struct disk_locn *dlocn_xl;
 	uint64_t offset;
 	uint32_t ext_version;
-	struct _update_mda_baton baton;
+	struct dm_pool *mem = l->fmt->cmd->mem;
+	struct update_mda_baton *umb;
 
 	/*
 	 * PV header base
@@ -396,7 +403,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev,
 				  FMT_TEXT_ORPHAN_VG_NAME,
 				  FMT_TEXT_ORPHAN_VG_NAME, 0)))
-		return_0;
+		goto_bad;
 
 	*label = lvmcache_get_label(info);
 
@@ -444,16 +451,27 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 		lvmcache_add_ba(info, offset, xlate64(dlocn_xl->size));
 		dlocn_xl++;
 	}
+
 out:
-	baton.info = info;
-	baton.label = *label;
+	if (!(umb = dm_pool_zalloc(mem, sizeof(*umb)))) {
+		log_error("baton allocation failed");
+		goto_bad;
+	}
+
+	umb->info = info;
+	umb->label = *label;
+	umb->ret = 1;
 
-	if (!lvmcache_foreach_mda(info, _update_mda, &baton))
+	if (!lvmcache_foreach_mda(info, _update_mda, umb))
 		return_0;
 
-	lvmcache_make_valid(info);
+	if (umb->ret)
+		lvmcache_make_valid(info);
 
 	return 1;
+
+bad:
+	return 0;
 }
 
 static void _text_destroy_label(struct labeller *l __attribute__((unused)),


