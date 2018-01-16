From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 15 Jan 2018 22:17:25 -0500
Subject: master - format_text: Refactor mda counting in label processing.
Message-ID: <201801160317.w0G3HPll025406@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0a3c6bf8c61224024c030152693fe2ce103cc6f0
Commit:        0a3c6bf8c61224024c030152693fe2ce103cc6f0
Parent:        73b5ee64e7bf1525f1958a1fb212b67a0832e6c7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 15 20:43:51 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 15 23:47:44 2018 +0000

format_text: Refactor mda counting in label processing.

---
 lib/format_text/text_label.c |   53 +++++++++++++++++++++++++++---------------
 1 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index a676f19..be797b2 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -349,12 +349,17 @@ static void _process_vgsummary(int failed, void *context, const void *data)
 	if (!lvmcache_update_vgname_and_id(pmp->umb->info, vgsummary)) {
 		pmp->umb->ret = 0;
 		pmp->ret = 0;
-		goto_out;
 	}
 
 out:
+	if (!pmp->umb->nr_outstanding_mdas && pmp->umb->ret)
+		lvmcache_make_valid(pmp->umb->info);
+
 	if (!dev_close(pmp->dev))
 		stack;
+
+	if (!pmp->umb->nr_outstanding_mdas && pmp->umb->read_label_callback_fn)
+		pmp->umb->read_label_callback_fn(!pmp->umb->ret, pmp->umb->read_label_callback_context, pmp->umb->label);
 }
 
 static void _process_mda_header(int failed, void *context, const void *data)
@@ -367,7 +372,7 @@ static void _process_mda_header(int failed, void *context, const void *data)
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 
 	if (failed)
-		return;
+		goto_bad;
 
 	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
@@ -390,6 +395,15 @@ bad:
 	return;
 }
 
+static int _count_mda(struct metadata_area *mda, void *baton)
+{
+	struct update_mda_baton *umb = baton;
+
+	umb->nr_outstanding_mdas++;
+
+	return 1;
+}
+
 static int _update_mda(struct metadata_area *mda, void *baton)
 {
 	struct process_mda_header_params *pmp;
@@ -410,24 +424,23 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 	 * TODO: make lvmcache smarter and move this cache logic there
 	 */
 
+	pmp->dev = mdac->area.dev;
+	pmp->umb = umb;
+	pmp->mda = mda;
+
 	if (!dev_open_readonly(mdac->area.dev)) {
 		mda_set_ignored(mda, 1);
 		stack;
+		if (!--umb->nr_outstanding_mdas && umb->read_label_callback_fn)
+			umb->read_label_callback_fn(!umb->ret, umb->read_label_callback_context, umb->label);
 		return 1;
 	}
 
-	umb->nr_outstanding_mdas++;
-	pmp->dev = mdac->area.dev;
-
-	pmp->umb = umb;
-	pmp->mda = mda;
 	pmp->ret = 1;
 
 	if (!raw_read_mda_header_callback(fmt->cmd->mem, &mdac->area, mda_is_primary(mda), _process_mda_header, pmp)) {
+		_process_vgsummary(1, pmp, NULL);
 		stack;
-		--pmp->umb->nr_outstanding_mdas;
-		if (!dev_close(pmp->dev))
-			stack;
 		return 1;
 	}
 
@@ -446,7 +459,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf,
 	uint32_t ext_version;
 	struct dm_pool *mem = l->fmt->cmd->mem;
 	struct update_mda_baton *umb;
-	struct label *label = NULL;
+	struct label *label;
 
 	/*
 	 * PV header base
@@ -515,19 +528,21 @@ out:
 	umb->label = label;
 	umb->read_label_callback_fn = read_label_callback_fn;
 	umb->read_label_callback_context = read_label_callback_context;
-	umb->nr_outstanding_mdas = 1;
 
 	umb->ret = 1;
 
-	if (!lvmcache_foreach_mda(info, _update_mda, umb))
-		return_0;
+	if (!lvmcache_foreach_mda(info, _count_mda, umb))
+		goto_bad;
 
-	if (!--umb->nr_outstanding_mdas)
-		if (umb->ret)
-			lvmcache_make_valid(info);
+	if (!umb->nr_outstanding_mdas) {
+		lvmcache_make_valid(info);
+		if (read_label_callback_fn)
+			read_label_callback_fn(0, read_label_callback_context, label);
+		return 1;
+	}
 
-	if (umb->read_label_callback_fn)
-		umb->read_label_callback_fn(!umb->ret, umb->read_label_callback_context, label);
+	if (!lvmcache_foreach_mda(info, _update_mda, umb))
+		goto_bad;
 
 	return 1;
 


