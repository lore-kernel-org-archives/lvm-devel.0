From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 26 May 2010 10:02:12 -0400
Subject: [PATCH 10/18] Add fid_add_mda() and fid_add_mdas() helpers to manage ignored mdas.
In-Reply-To: <1274882540-6181-10-git-send-email-dwysocha@redhat.com>
References: <1274882540-6181-1-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-2-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-3-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-4-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-5-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-6-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-7-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-8-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-9-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1274882540-6181-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a second mda list, metadata_areas_ignored to fid, and a couple
functions to help manage the lists.

These functions are needed to properly count the ignored mdas and
manage the lists attached to the 'fid' and ultimately the 'vg'.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/format-text.c    |    1 +
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   23 +++++++++++++++++++++++
 lib/metadata/metadata.h          |    2 ++
 lib/report/report.c              |    1 +
 5 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 1417473..21bc8bf 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1910,6 +1910,7 @@ static struct format_instance *_text_create_text_instance(const struct format_ty
 
 	fid->fmt = fmt;
 	dm_list_init(&fid->metadata_areas);
+	dm_list_init(&fid->metadata_areas_ignored);
 
 	if (!vgname) {
 		if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9e1b564..840c777 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -213,6 +213,7 @@ struct physical_volume {
 struct format_instance {
 	const struct format_type *fmt;
 	struct dm_list metadata_areas;	/* e.g. metadata locations */
+	struct dm_list metadata_areas_ignored;
 	void *private;
 };
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 44532a4..5e6ca57 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3851,6 +3851,29 @@ uint32_t pv_pe_alloc_count(const struct physical_volume *pv)
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
index 503301c..8cf5a58 100644
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
index 49d28b7..a03c575 100644
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


