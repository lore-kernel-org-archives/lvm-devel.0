From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:05:44 -0400
Subject: [PATCH 11/35] Add metadata_areas_ignored list and functions to manage ignored mdas.
In-Reply-To: <1277175968-9661-11-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-12-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a second mda list, metadata_areas_ignored to fid, and a couple
functions, fid_add_mda() and fid_add_mdas() to help manage the lists.

These functions are needed to properly count the ignored mdas and
manage the lists attached to the 'fid' and ultimately the 'vg'.

Ensure metadata_areas_ignored is initialized in other formats, even
if the list is never used.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/format-text.c    |    2 ++
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   23 +++++++++++++++++++++++
 lib/metadata/metadata.h          |    2 ++
 lib/report/report.c              |    1 +
 7 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 1167e04..f0b323c 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -464,6 +464,7 @@ static struct format_instance *_format1_create_instance(const struct format_type
 
 	fid->fmt = fmt;
 	dm_list_init(&fid->metadata_areas);
+	dm_list_init(&fid->metadata_areas_ignored);
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda)))) {
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index d8a09ec..d3f5fd6 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -263,6 +263,7 @@ static struct format_instance *_pool_create_instance(const struct format_type *f
 
 	fid->fmt = fmt;
 	dm_list_init(&fid->metadata_areas);
+	dm_list_init(&fid->metadata_areas_ignored);
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index be221ee..bbee7f0 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1201,6 +1201,7 @@ static int _scan_raw(const struct format_type *fmt)
 
 	fid.fmt = fmt;
 	dm_list_init(&fid.metadata_areas);
+	dm_list_init(&fid.metadata_areas_ignored);
 
 	dm_list_iterate_items(rl, raw_list) {
 		/* FIXME We're reading mdah twice here... */
@@ -1910,6 +1911,7 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 
 	fid->fmt = fmt;
 	dm_list_init(&fid->metadata_areas);
+	dm_list_init(&fid->metadata_areas_ignored);
 
 	if (!vgname) {
 		if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index dbac0f2..d0e10e6 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -216,6 +216,7 @@ struct physical_volume {
 struct format_instance {
 	const struct format_type *fmt;
 	struct dm_list metadata_areas;	/* e.g. metadata locations */
+	struct dm_list metadata_areas_ignored;
 	void *private;
 };
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 20a51e9..c7b829f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3855,6 +3855,29 @@ uint32_t pv_pe_alloc_count(const struct physical_volume *pv)
 	return pv_field(pv, pe_alloc_count);
 }
 
+void fid_add_mda(struct format_instance *fid, struct metadata_area *mda)
+{
+	if (mda_is_ignored(mda))
+		dm_list_add(&fid->metadata_areas_ignored,
+			    &mda->list);
+	else
+		dm_list_add(&fid->metadata_areas,
+			    &mda->list);
+}
+
+int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas)
+{
+	struct metadata_area *mda, *mda_new;
+
+	dm_list_iterate_items(mda, mdas) {
+		mda_new = mda_copy(fid->fmt->cmd->mem, mda);
+		if (!mda_new)
+			return_0;
+		fid_add_mda(fid, mda_new);
+	}
+	return 1;
+}
+
 /*
  * Copy constructor for a metadata_area.
  */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 86314b2..fd89423 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -183,6 +183,8 @@ struct metadata_area *mda_copy(struct dm_pool *mem,
 int mda_is_ignored(struct metadata_area *mda);
 void mda_set_ignored(struct metadata_area *mda, int value);
 int mda_locn_match(struct metadata_area *mda1, struct metadata_area *mda2);
+void fid_add_mda(struct format_instance *fid, struct metadata_area *mda);
+int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas);
 
 #define seg_pvseg(seg, s)	(seg)->areas[(s)].u.pv.pvseg
 #define seg_dev(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv->dev
diff --git a/lib/report/report.c b/lib/report/report.c
index 063db07..d912758 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1103,6 +1103,7 @@ static int _copypercent_disp(struct dm_report *rh __attribute((unused)),
 /* necessary for displaying something for PVs not belonging to VG */
 static struct format_instance _dummy_fid = {
 	.metadata_areas = { &(_dummy_fid.metadata_areas), &(_dummy_fid.metadata_areas) },
+	.metadata_areas_ignored = { &(_dummy_fid.metadata_areas_ignored), &(_dummy_fid.metadata_areas_ignored) },
 };
 
 static struct volume_group _dummy_vg = {
-- 
1.6.0.6


