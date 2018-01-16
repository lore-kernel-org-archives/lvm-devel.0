From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 15 Jan 2018 22:17:17 -0500
Subject: master - format_text: Change update_mda_baton to use label not labeller
Message-ID: <201801160317.w0G3HH7G025389@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73b5ee64e7bf1525f1958a1fb212b67a0832e6c7
Commit:        73b5ee64e7bf1525f1958a1fb212b67a0832e6c7
Parent:        b825987b2fc6a8294d164bf4c5e1be7edc199bea
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 15 20:13:53 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 15 20:13:53 2018 +0000

format_text: Change update_mda_baton to use label not labeller

---
 lib/format_text/text_label.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 44d43f1..a676f19 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -321,7 +321,7 @@ static int _text_initialise_label(struct labeller *l __attribute__((unused)),
 
 struct update_mda_baton {
 	struct lvmcache_info *info;
-	struct labeller *labeller;
+	struct label *label;
 	int nr_outstanding_mdas;
 	lvm_callback_fn_t read_label_callback_fn;
 	void *read_label_callback_context;
@@ -362,7 +362,7 @@ static void _process_mda_header(int failed, void *context, const void *data)
 	struct process_mda_header_params *pmp = context;
 	const struct mda_header *mdah = data;
 	struct update_mda_baton *umb = pmp->umb;
-	const struct format_type *fmt = umb->labeller->fmt;
+	const struct format_type *fmt = umb->label->labeller->fmt;
 	struct metadata_area *mda = pmp->mda;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 
@@ -394,8 +394,8 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 {
 	struct process_mda_header_params *pmp;
 	struct update_mda_baton *umb = baton;
-	const struct format_type *fmt = umb->labeller->fmt;
-	struct dm_pool *mem = umb->labeller->fmt->cmd->mem;
+	const struct format_type *fmt = umb->label->labeller->fmt;
+	struct dm_pool *mem = umb->label->labeller->fmt->cmd->mem;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 
 	if (!(pmp = dm_pool_zalloc(mem, sizeof(*pmp)))) {
@@ -512,7 +512,7 @@ out:
 	}
 
 	umb->info = info;
-	umb->labeller = label->labeller;
+	umb->label = label;
 	umb->read_label_callback_fn = read_label_callback_fn;
 	umb->read_label_callback_context = read_label_callback_context;
 	umb->nr_outstanding_mdas = 1;


