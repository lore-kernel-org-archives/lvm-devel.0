From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 15 Dec 2017 10:01:34 -0500
Subject: master - format_text: Supply mempool directly to raw_read_mda_header.
Message-ID: <201712151501.vBFF1Y2R025130@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=145ded10c29a2e76ea12aab98a797e79135d6d44
Commit:        145ded10c29a2e76ea12aab98a797e79135d6d44
Parent:        83e1a0bad836f8950cb1e38924bf2600f118861e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Dec 15 14:57:05 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Dec 15 14:57:05 2017 +0000

format_text: Supply mempool directly to raw_read_mda_header.

---
 lib/format_text/format-text.c |   21 ++++++++++-----------
 lib/format_text/layout.h      |    3 +--
 lib/format_text/text_label.c  |    3 ++-
 3 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 1aa91c7..ab610ad 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -196,7 +196,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 	if (!dev_open_readonly(area->dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fmt, area, mda_is_primary(mda))))
+	if (!(mdah = raw_read_mda_header(fmt->cmd->mem, area, mda_is_primary(mda))))
 		goto_out;
 
 	rlocn = mdah->raw_locns;
@@ -370,18 +370,17 @@ static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev
 	return 1;
 }
 
-struct mda_header *raw_read_mda_header(const struct format_type *fmt,
-				       struct device_area *dev_area, int primary_mda)
+struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda)
 {
 	struct mda_header *mdah;
 
-	if (!(mdah = dm_pool_alloc(fmt->cmd->mem, MDA_HEADER_SIZE))) {
+	if (!(mdah = dm_pool_alloc(mem, MDA_HEADER_SIZE))) {
 		log_error("struct mda_header allocation failed");
 		return NULL;
 	}
 
 	if (!_raw_read_mda_header(mdah, dev_area, primary_mda)) {
-		dm_pool_free(fmt->cmd->mem, mdah);
+		dm_pool_free(mem, mdah);
 		return NULL;
 	}
 
@@ -529,7 +528,7 @@ static int _raw_holds_vgname(struct format_instance *fid,
 	if (!dev_open_readonly(dev_area->dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, dev_area, 0)))
+	if (!(mdah = raw_read_mda_header(fid->fmt->cmd->mem, dev_area, 0)))
 		return_0;
 
 	if (_find_vg_rlocn(dev_area, mdah, 0, vgname, &noprecommit))
@@ -556,7 +555,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	char *desc;
 	uint32_t wrap = 0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, area, primary_mda)))
+	if (!(mdah = raw_read_mda_header(fid->fmt->cmd->mem, area, primary_mda)))
 		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(area, mdah, primary_mda, vgname, &precommitted))) {
@@ -733,7 +732,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!dev_open(mdac->area.dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
+	if (!(mdah = raw_read_mda_header(fid->fmt->cmd->mem, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
 	/* Following space is zero-filled up to the next MDA_ALIGNMENT boundary */
@@ -865,7 +864,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	if (!found)
 		return 1;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
+	if (!(mdah = raw_read_mda_header(fid->fmt->cmd->mem, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit))) {
@@ -985,7 +984,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!dev_open(mdac->area.dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
+	if (!(mdah = raw_read_mda_header(fid->fmt->cmd->mem, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), vg->name, &noprecommit))) {
@@ -1414,7 +1413,7 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 			continue;
 		}
 
-		if (!(mdah = raw_read_mda_header(fmt, &rl->dev_area, 0))) {
+		if (!(mdah = raw_read_mda_header(fmt->cmd->mem, &rl->dev_area, 0))) {
 			stack;
 			goto close_dev;
 		}
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index bc25597..c0906a6 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -81,8 +81,7 @@ struct mda_header {
 	struct raw_locn raw_locns[0];	/* NULL-terminated list */
 } __attribute__ ((packed));
 
-struct mda_header *raw_read_mda_header(const struct format_type *fmt,
-				       struct device_area *dev_area, int primary_mda);
+struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda);
 
 struct mda_lists {
 	struct dm_list dirs;
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7058f70..d5e4820 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -19,6 +19,7 @@
 #include "label.h"
 #include "xlate.h"
 #include "lvmcache.h"
+#include "toolcontext.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -344,7 +345,7 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 		return 1;
 	}
 
-	if (!(mdah = raw_read_mda_header(fmt, &mdac->area, mda_is_primary(mda)))) {
+	if (!(mdah = raw_read_mda_header(fmt->cmd->mem, &mdac->area, mda_is_primary(mda)))) {
 		stack;
 		goto close_dev;
 	}


