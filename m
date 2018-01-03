From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 3 Jan 2018 15:50:12 -0500
Subject: master - format_text: Split the text import fns into two pieces.
Message-ID: <201801032050.w03KoCFj030045@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5a846e09297a56b6fdb0ba85a215164d08204589
Commit:        5a846e09297a56b6fdb0ba85a215164d08204589
Parent:        4b9806ab6f8723630c5284ed2baf1d82c7839a07
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 3 16:00:52 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 3 20:48:02 2018 +0000

format_text: Split the text import fns into two pieces.

---
 lib/format_text/import.c |  202 +++++++++++++++++++++++++++++++---------------
 1 files changed, 135 insertions(+), 67 deletions(-)

diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 039722a..d729659 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -33,6 +33,43 @@ static void _init_text_import(void)
 	_text_import_initialised = 1;
 }
 
+struct import_vgsummary_params {
+	const struct format_type *fmt;
+	struct dm_config_tree *cft;
+	int checksum_only;
+	struct lvmcache_vgsummary *vgsummary;
+};
+
+static int _import_vgsummary(struct import_vgsummary_params *ivsp)
+{
+	struct text_vg_version_ops **vsn;
+	int r = 0;
+
+	if (ivsp->checksum_only) {
+		/* Checksum matches already-cached content - no need to reparse. */
+		r = 1;
+		goto out;
+	}
+
+	/*
+	 * Find a set of version functions that can read this file
+	 */
+	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
+		if (!(*vsn)->check_version(ivsp->cft))
+			continue;
+
+		if (!(*vsn)->read_vgsummary(ivsp->fmt, ivsp->cft, ivsp->vgsummary))
+			goto_out;
+
+		r = 1;
+		break;
+	}
+
+out:
+	config_destroy(ivsp->cft);
+	return r;
+}
+
 /*
  * Find out vgname on a given device.
  */
@@ -44,27 +81,68 @@ int text_vgsummary_import(const struct format_type *fmt,
 		       int checksum_only,
 		       struct lvmcache_vgsummary *vgsummary)
 {
-	struct dm_config_tree *cft;
-	struct text_vg_version_ops **vsn;
-	int r = 0;
+	struct import_vgsummary_params *ivsp;
 
 	_init_text_import();
 
-	if (!(cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0)))
+	if (!(ivsp = dm_pool_zalloc(fmt->cmd->mem, sizeof(*ivsp)))) {
+		log_error("Failed to allocate import_vgsummary_params struct.");
+		return 0;
+	}
+
+	if (!(ivsp->cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0)))
 		return_0;
 
-	if ((!dev && !config_file_read(fmt->cmd->mem, cft)) ||
-	    (dev && !config_file_read_fd(fmt->cmd->mem, cft, dev, reason, offset, size,
-					 offset2, size2, checksum_fn,
-					 vgsummary->mda_checksum,
-					 checksum_only, 1))) {
+	ivsp->fmt = fmt;
+	ivsp->checksum_only = checksum_only;
+	ivsp->vgsummary = vgsummary;
+
+	if (!dev && !config_file_read(fmt->cmd->mem, ivsp->cft)) {
 		log_error("Couldn't read volume group metadata.");
-		goto out;
+		config_destroy(ivsp->cft);
+		return 0;
 	}
 
-	if (checksum_only) {
-		/* Checksum matches already-cached content - no need to reparse. */
-		r = 1;
+	if (dev && !config_file_read_fd(fmt->cmd->mem, ivsp->cft, dev, reason, offset, size,
+					offset2, size2, checksum_fn,
+					vgsummary->mda_checksum,
+					checksum_only, 1)) {
+		log_error("Couldn't read volume group metadata.");
+		config_destroy(ivsp->cft);
+		return 0;
+	}
+
+	return _import_vgsummary(ivsp);
+}
+
+struct cached_vg_fmtdata {
+        uint32_t cached_mda_checksum;
+        size_t cached_mda_size;
+};
+
+struct import_vg_params {
+	struct format_instance *fid;
+	struct dm_config_tree *cft;
+	int single_device;
+	int skip_parse;
+	unsigned *use_previous_vg;
+	struct volume_group *vg;
+	uint32_t checksum;
+	uint32_t total_size;
+	time_t *when;
+	struct cached_vg_fmtdata **vg_fmtdata;
+	char **desc;
+};
+
+static void _import_vg(struct import_vg_params *ivp)
+{
+	struct text_vg_version_ops **vsn;
+
+	ivp->vg = NULL;
+
+	if (ivp->skip_parse) {
+		if (ivp->use_previous_vg)
+			*ivp->use_previous_vg = 1;
 		goto out;
 	}
 
@@ -72,25 +150,27 @@ int text_vgsummary_import(const struct format_type *fmt,
 	 * Find a set of version functions that can read this file
 	 */
 	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
-		if (!(*vsn)->check_version(cft))
+		if (!(*vsn)->check_version(ivp->cft))
 			continue;
 
-		if (!(*vsn)->read_vgsummary(fmt, cft, vgsummary))
+		if (!(ivp->vg = (*vsn)->read_vg(ivp->fid, ivp->cft, ivp->single_device, 0)))
 			goto_out;
 
-		r = 1;
+		(*vsn)->read_desc(ivp->vg->vgmem, ivp->cft, ivp->when, ivp->desc);
 		break;
 	}
 
-      out:
-	config_destroy(cft);
-	return r;
-}
+	if (ivp->vg && ivp->vg_fmtdata && *ivp->vg_fmtdata) {
+		(*ivp->vg_fmtdata)->cached_mda_size = ivp->total_size;
+		(*ivp->vg_fmtdata)->cached_mda_checksum = ivp->checksum;
+	}
 
-struct cached_vg_fmtdata {
-        uint32_t cached_mda_checksum;
-        size_t cached_mda_size;
-};
+	if (ivp->use_previous_vg)
+		*ivp->use_previous_vg = 0;
+
+out:
+	config_destroy(ivp->cft);
+}
 
 struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       const char *file,
@@ -104,10 +184,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       uint32_t checksum,
 				       time_t *when, char **desc)
 {
-	struct volume_group *vg = NULL;
-	struct dm_config_tree *cft;
-	struct text_vg_version_ops **vsn;
-	int skip_parse;
+	struct import_vg_params *ivp;
 
 	if (vg_fmtdata && !*vg_fmtdata &&
 	    !(*vg_fmtdata = dm_pool_zalloc(fid->mem, sizeof(**vg_fmtdata)))) {
@@ -115,56 +192,47 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		return NULL;
 	}
 
-	_init_text_import();
+	if (!(ivp = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*ivp)))) {
+		log_error("Failed to allocate import_vgsummary_params struct.");
+		return NULL;
+	}
 
-	*desc = NULL;
-	*when = 0;
+	_init_text_import();
 
-	if (!(cft = config_open(CONFIG_FILE_SPECIAL, file, 0)))
+	ivp->fid = fid;
+	ivp->when = when;
+	*ivp->when = 0;
+	ivp->desc = desc;
+	*ivp->desc = NULL;
+	ivp->single_device = single_device;
+	ivp->use_previous_vg = use_previous_vg;
+	ivp->checksum = checksum;
+	ivp->total_size = size + size2;
+	ivp->vg_fmtdata = vg_fmtdata;
+
+	if (!(ivp->cft = config_open(CONFIG_FILE_SPECIAL, file, 0)))
 		return_NULL;
 
 	/* Does the metadata match the already-cached VG? */
-	skip_parse = vg_fmtdata && 
-		     ((*vg_fmtdata)->cached_mda_checksum == checksum) &&
-		     ((*vg_fmtdata)->cached_mda_size == (size + size2));
-
-	if ((!dev && !config_file_read(fid->mem, cft)) ||
-	    (dev && !config_file_read_fd(fid->mem, cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
-					 offset2, size2, checksum_fn, checksum,
-					 skip_parse, 1)))
-		goto_out;
-
-	if (skip_parse) {
-		if (use_previous_vg)
-			*use_previous_vg = 1;
-		goto out;
-	}
-
-	/*
-	 * Find a set of version functions that can read this file
-	 */
-	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
-		if (!(*vsn)->check_version(cft))
-			continue;
+	ivp->skip_parse = vg_fmtdata && 
+			  ((*vg_fmtdata)->cached_mda_checksum == checksum) &&
+			  ((*vg_fmtdata)->cached_mda_size == ivp->total_size);
 
-		if (!(vg = (*vsn)->read_vg(fid, cft, single_device, 0)))
-			goto_out;
-
-		(*vsn)->read_desc(vg->vgmem, cft, when, desc);
-		break;
+	if (!dev && !config_file_read(fid->mem, ivp->cft)) {
+		config_destroy(ivp->cft);
+		return_NULL;
 	}
 
-	if (vg && vg_fmtdata && *vg_fmtdata) {
-		(*vg_fmtdata)->cached_mda_size = (size + size2);
-		(*vg_fmtdata)->cached_mda_checksum = checksum;
+	if (dev && !config_file_read_fd(fid->mem, ivp->cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
+					offset2, size2, checksum_fn, checksum,
+					ivp->skip_parse, 1)) {
+		config_destroy(ivp->cft);
+		return_NULL;
 	}
 
-	if (use_previous_vg)
-		*use_previous_vg = 0;
+	_import_vg(ivp);
 
-      out:
-	config_destroy(cft);
-	return vg;
+	return ivp->vg;
 }
 
 struct volume_group *text_vg_import_file(struct format_instance *fid,


