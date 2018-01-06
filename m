From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 5 Jan 2018 21:43:25 -0500
Subject: master - metadata: Use a consistent format for callback fn parameters
Message-ID: <201801060243.w062hPxl013307@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=946f07af3e8f97b0e48752ce1cd8de87d3456540
Commit:        946f07af3e8f97b0e48752ce1cd8de87d3456540
Parent:        a0ddfad94b92da4c5d21459f17c5f1fb9fe003b3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 5 14:24:10 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 5 14:24:56 2018 +0000

metadata: Use a consistent format for callback fn parameters

---
 lib/config/config.c           |    6 ++++--
 lib/device/device.h           |    5 +++++
 lib/format_text/format-text.c |   16 ++++++++++------
 lib/format_text/import.c      |   10 ++++++----
 lib/format_text/text_label.c  |   13 +++++++++----
 lib/label/label.c             |    8 ++++----
 lib/metadata/metadata.h       |    1 -
 7 files changed, 38 insertions(+), 21 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 5dc2356..bffee06 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -503,8 +503,10 @@ struct process_config_file_params {
 	int ret;
 };
 
-static void _process_config_file_buffer(struct process_config_file_params *pcfp, char *buffer)
+static void _process_config_file_buffer(int failed, void *context, void *data)
 {
+	struct process_config_file_params *pcfp = context;
+	char *buffer = data;
 	char *fb, *fe;
 
 	fb = buffer;
@@ -598,7 +600,7 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 		fb = buf;
 	}
 
-	_process_config_file_buffer(pcfp, fb);
+	_process_config_file_buffer(0, pcfp, fb);
 	r = pcfp->ret;
 
       out:
diff --git a/lib/device/device.h b/lib/device/device.h
index dac638c..04117d2 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -33,6 +33,11 @@
 #define DEV_NOT_O_NOATIME	0x00000400	/* Don't use O_NOATIME */
 
 /*
+ * Standard format for callback functions
+ */
+typedef void (*lvm_callback_fn_t)(int failed, void *context, void *data);
+
+/*
  * Support for external device info.
  * Any new external device info source needs to be
  * registered using EXT_REGISTER macro in dev-ext.c.
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index fb87ae2..a0aff4d 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -332,8 +332,9 @@ struct process_raw_mda_header_params {
 	int ret;
 };
 
-static void _process_raw_mda_header(struct process_raw_mda_header_params *prmp)
+static void _process_raw_mda_header(int failed, void *context, void *data)
 {
+	struct process_raw_mda_header_params *prmp = context;
 	struct mda_header *mdah = prmp->mdah;
 	struct device_area *dev_area = &prmp->dev_area;
 
@@ -413,7 +414,7 @@ static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct devic
 		return_NULL;
 	}
 
-	_process_raw_mda_header(prmp);
+	_process_raw_mda_header(0, prmp, NULL);
 
 	if (!prmp->ret)
 		return_NULL;
@@ -1347,8 +1348,9 @@ struct vgname_from_mda_params{
 	int ret;
 };
 
-static void _vgname_from_mda_process(struct vgname_from_mda_params *vfmp)
+static void _vgname_from_mda_process(int failed, void *context, void *data)
 {
+	struct vgname_from_mda_params *vfmp = context;
 	struct mda_header *mdah = vfmp->mdah;
 	struct device_area *dev_area = vfmp->dev_area;
 	struct lvmcache_vgsummary *vgsummary = vfmp->vgsummary;
@@ -1386,8 +1388,10 @@ out:
 	;
 }
 
-static void _vgname_from_mda_validate(struct vgname_from_mda_params *vfmp, char *buffer)
+static void _vgname_from_mda_validate(int failed, void *context, void *data)
 {
+	struct vgname_from_mda_params *vfmp = context;
+	char *buffer = data;
 	const struct format_type *fmt = vfmp->fmt;
 	struct mda_header *mdah = vfmp->mdah;
 	struct device_area *dev_area = vfmp->dev_area;
@@ -1439,7 +1443,7 @@ static void _vgname_from_mda_validate(struct vgname_from_mda_params *vfmp, char
 		goto_out;
 	}
 
-	_vgname_from_mda_process(vfmp);
+	_vgname_from_mda_process(0, vfmp, NULL);
 
 out:
 	;
@@ -1492,7 +1496,7 @@ int vgname_from_mda(const struct format_type *fmt,
 			  NAME_LEN, MDA_CONTENT_REASON(primary_mda), buf))
 		return_0;
 
-	_vgname_from_mda_validate(vfmp, buf);
+	_vgname_from_mda_validate(0, vfmp, buf);
 
 	return vfmp->ret;
 }
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 580c1f3..64ef2be 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -41,8 +41,9 @@ struct import_vgsummary_params {
 	int ret;
 };
 
-static void _import_vgsummary(struct import_vgsummary_params *ivsp)
+static void _import_vgsummary(int failed, void *context, void *data)
 {
+	struct import_vgsummary_params *ivsp = context;
 	struct text_vg_version_ops **vsn;
 
 	if (ivsp->checksum_only)
@@ -114,7 +115,7 @@ int text_vgsummary_import(const struct format_type *fmt,
 		return 0;
 	}
 
-	_import_vgsummary(ivsp);
+	_import_vgsummary(0, ivsp, NULL);
 
 	return ivsp->ret;
 }
@@ -138,8 +139,9 @@ struct import_vg_params {
 	char **desc;
 };
 
-static void _import_vg(struct import_vg_params *ivp)
+static void _import_vg(int failed, void *context, void *data)
 {
+	struct import_vg_params *ivp = context;
 	struct text_vg_version_ops **vsn;
 
 	ivp->vg = NULL;
@@ -234,7 +236,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		return_NULL;
 	}
 
-	_import_vg(ivp);
+	_import_vg(0, ivp, NULL);
 
 	return ivp->vg;
 }
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index c4ea166..05e1626 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -333,8 +333,11 @@ struct process_mda_header_params {
 	int ret;
 };
 
-static void _process_vgsummary(struct process_mda_header_params *pmp, struct lvmcache_vgsummary *vgsummary)
+static void _process_vgsummary(int failed, void *context, void *data)
 {
+	struct process_mda_header_params *pmp = context;
+	struct lvmcache_vgsummary *vgsummary = data;
+
 	if (!lvmcache_update_vgname_and_id(pmp->umb->info, vgsummary)) {
 		pmp->umb->ret = 0;
 		pmp->ret = 0;
@@ -346,8 +349,10 @@ out:
 		stack;
 }
 
-static void _process_mda_header(struct process_mda_header_params *pmp, struct mda_header *mdah)
+static void _process_mda_header(int failed, void *context, void *data)
 {
+	struct process_mda_header_params *pmp = context;
+	struct mda_header *mdah = data;
 	struct update_mda_baton *umb = pmp->umb;
 	const struct format_type *fmt = umb->label->labeller->fmt;
 	struct metadata_area *mda = pmp->mda;
@@ -373,7 +378,7 @@ static void _process_mda_header(struct process_mda_header_params *pmp, struct md
 		return;
 	}
 
-	_process_vgsummary(pmp, &pmp->vgsummary);
+	_process_vgsummary(0, pmp, &pmp->vgsummary);
 }
 
 static int _update_mda(struct metadata_area *mda, void *baton)
@@ -416,7 +421,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	_process_mda_header(pmp, mdah);
+	_process_mda_header(0, pmp, mdah);
 
 	return pmp->ret;
 }
diff --git a/lib/label/label.c b/lib/label/label.c
index 5d5bcc5..a187bad 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -146,8 +146,10 @@ out:
 		stack;
 }
 
-static void _find_labeller(struct find_labeller_params *flp, char *readbuf)
+static void _find_labeller(int failed, void *context, void *data)
 {
+	struct find_labeller_params *flp = context;
+	char *readbuf = data;
 	struct device *dev = flp->dev;
 	uint64_t scan_sector = flp->scan_sector;
 	struct label **result = flp->result;
@@ -158,8 +160,6 @@ static void _find_labeller(struct find_labeller_params *flp, char *readbuf)
 	struct lvmcache_info *info;
 	uint64_t sector;
 
-int r = 0;
-
 	/* Scan a few sectors for a valid label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
@@ -343,7 +343,7 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		return 0;
 	}
 
-	_find_labeller(flp, readbuf);
+	_find_labeller(0, flp, readbuf);
 	return flp->ret;
 }
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 3a4abc3..f15080a 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -48,7 +48,6 @@
  */
 #define dm_round_up(n, sz) (dm_div_up((n), (sz)) * (sz))
 
-
 /* Various flags */
 /* See metadata-exported.h for the complete list. */
 /* Note that the bits no longer necessarily correspond to LVM1 disk format */


