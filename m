From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 3 Jan 2018 20:55:37 -0500
Subject: master - format_text: Split up _update_mda.
Message-ID: <201801040155.w041tbou019180@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=59e8e2c6cb989dbf9cf161ceb30350441561b02b
Commit:        59e8e2c6cb989dbf9cf161ceb30350441561b02b
Parent:        111a9fcff5ace7391a9247678c8257da60cc37e6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jan 4 00:56:34 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jan 4 01:40:18 2018 +0000

format_text: Split up _update_mda.

Dedicated functions are now used to process each piece of data obtained,
so the refactoring in this file gives us one for the vgsummary and one
for the metadata header.  This new type of function takes two parameters
(for now), the obtained data plus a single struct (that must not
reference any data on the stack) that wraps up the entire context needed
to process it.
---
 lib/format_text/text_label.c |   99 +++++++++++++++++++++++++++++-------------
 1 files changed, 69 insertions(+), 30 deletions(-)

diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 42cf5b3..f02597c 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -325,13 +325,74 @@ struct update_mda_baton {
 	int ret;
 };
 
+struct process_mda_header_params {
+	struct update_mda_baton *umb;
+	struct metadata_area mda;
+	struct device *dev;
+	struct lvmcache_vgsummary vgsummary;
+};
+
+static int _process_vgsummary(struct process_mda_header_params *pmp, struct lvmcache_vgsummary *vgsummary)
+{
+	int r = 0;
+
+	if (!lvmcache_update_vgname_and_id(pmp->umb->info, vgsummary)) {
+		pmp->umb->ret = 0;
+		goto_out;
+	}
+
+	r = 1;
+
+out:
+	if (!dev_close(pmp->dev))
+		stack;
+
+	return r;
+}
+
+static int _process_mda_header(struct process_mda_header_params *pmp, struct mda_header *mdah)
+{
+	struct update_mda_baton *umb = pmp->umb;
+	const struct format_type *fmt = umb->label->labeller->fmt;
+	struct metadata_area *mda = &pmp->mda;
+	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
+
+	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
+
+	if (mda_is_ignored(mda)) {
+		log_debug_metadata("Ignoring mda on device %s at offset " FMTu64,
+				   dev_name(mdac->area.dev),
+				   mdac->area.start);
+		if (!dev_close(pmp->dev))
+			stack;
+		return 1;
+	}
+
+	if (!vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &pmp->vgsummary,
+			     &mdac->free_sectors)) {
+		/* FIXME Separate fatal and non-fatal error cases? */
+		stack;
+		if (!dev_close(pmp->dev))
+			stack;
+		return 1;
+	}
+
+	return _process_vgsummary(pmp, &pmp->vgsummary);
+}
+
 static int _update_mda(struct metadata_area *mda, void *baton)
 {
+	struct process_mda_header_params *pmp;
 	struct update_mda_baton *umb = baton;
 	const struct format_type *fmt = umb->label->labeller->fmt;
+	struct dm_pool *mem = umb->label->labeller->fmt->cmd->mem;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct mda_header *mdah;
-	struct lvmcache_vgsummary vgsummary = { 0 };
+
+	if (!(pmp = dm_pool_zalloc(mem, sizeof(*pmp)))) {
+		log_error("struct process_mda_header_params allocation failed");
+		return 0;
+	}
 
 	/*
 	 * Using the labeller struct to preserve info about
@@ -346,41 +407,19 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	if (!(mdah = raw_read_mda_header(fmt->cmd->mem, &mdac->area, mda_is_primary(mda)))) {
-		stack;
-		goto close_dev;
-	}
+	pmp->dev = mdac->area.dev;
 
-	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
+	pmp->umb = umb;
+	pmp->mda = *mda;
 
-	if (mda_is_ignored(mda)) {
-		log_debug_metadata("Ignoring mda on device %s at offset " FMTu64,
-				   dev_name(mdac->area.dev),
-				   mdac->area.start);
-		if (!dev_close(mdac->area.dev))
-			stack;
-		return 1;
-	}
-
-	if (!vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &vgsummary,
-			     &mdac->free_sectors)) {
-		/* FIXME Separate fatal and non-fatal error cases? */
+	if (!(mdah = raw_read_mda_header(fmt->cmd->mem, &mdac->area, mda_is_primary(mda)))) {
 		stack;
-		goto close_dev;
-	}
-
-	if (!lvmcache_update_vgname_and_id(umb->info, &vgsummary)) {
-		if (!dev_close(mdac->area.dev))
+		if (!dev_close(pmp->dev))
 			stack;
-		umb->ret = 0;
-		return_0;
+		return 1;
 	}
 
-close_dev:
-	if (!dev_close(mdac->area.dev))
-		stack;
-
-	return 1;
+	return _process_mda_header(pmp, mdah);
 }
 
 static int _text_read(struct labeller *l, struct device *dev, void *buf, struct label **label)


