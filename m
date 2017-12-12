From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 12 Dec 2017 17:55:57 -0500
Subject: master - format_text: Round size written up to multiple of 4096.
Message-ID: <201712122255.vBCMtvg6002536@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3edc25dbdfc5d8d5ba109921dae87c5415a0b460
Commit:        3edc25dbdfc5d8d5ba109921dae87c5415a0b460
Parent:        78ffa44fc58fba6f4e8d2046798783d7f4f11b41
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 12 22:52:22 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 12 22:52:22 2017 +0000

format_text: Round size written up to multiple of 4096.

Zero-fill metadata up to the next 4096 boundary then write out a
multiple of 4096 bytes to avoid triggering a read-modify-write.
---
 WHATS_NEW                     |    1 +
 lib/format_text/export.c      |    8 +++++++-
 lib/format_text/format-text.c |   34 +++++++++++++++++++++++++---------
 lib/format_text/layout.h      |    1 +
 4 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f871377..5fc4cd3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  When writing text metadata content, use complete 4096 byte blocks.
   Change text format metadata alignment from 512 to 4096 bytes.
   When writing metadata, consistently skip mdas marked as failed.
   Refactor and adjust text format metadata alignment calculation.
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index e535237..1bcaf83 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -23,6 +23,7 @@
 #include "lvm-version.h"
 #include "toolcontext.h"
 #include "config-util.h"
+#include "layout.h"
 
 #include <stdarg.h>
 #include <time.h>
@@ -1079,7 +1080,12 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 		goto_out;
 	}
 
-	r = f->data.buf.used + 1;
+	f->data.buf.used += 1;	/* Terminating NUL */
+
+	/* Zero fill up to next alignment boundary */
+	memset(f->data.buf.start + f->data.buf.used, 0, MDA_ALIGNMENT - f->data.buf.used % MDA_ALIGNMENT);
+
+	r = f->data.buf.used;
 	*buf = f->data.buf.start;
 
       out:
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index ea31a2f..1aa91c7 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -704,11 +704,12 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	struct mda_header *mdah;
 	struct pv_list *pvl;
 	int r = 0;
-	uint64_t new_wrap;	/* Number of bytes of new metadata that wrap around to start of buffer */
+	uint64_t new_wrap = 0;	/* Number of bytes of new metadata that wrap around to start of buffer */
 	uint64_t alignment = MDA_ALIGNMENT;
 	int found = 0;
 	int noprecommit = 0;
 	const char *old_vg_name = NULL;
+	uint64_t new_size_rounded;
 
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
 	dm_list_iterate_items(pvl, &vg->pvs) {
@@ -735,6 +736,7 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
+	/* Following space is zero-filled up to the next MDA_ALIGNMENT boundary */
 	if (!fidtc->raw_metadata_buf &&
 	    !(fidtc->raw_metadata_buf_size =
 			text_vg_export_raw(vg, "", &fidtc->raw_metadata_buf))) {
@@ -775,19 +777,33 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 				  vg->name, dev_name(mdac->area.dev), mdac->rlocn.size, mdah->size - MDA_HEADER_SIZE, rlocn ? rlocn->size : 0);
 			goto out;
 		}
+
+		new_size_rounded = mdac->rlocn.size;
+	} else {
+		/* Round up to a multiple of the new alignment */
+		if (mdac->rlocn.offset + new_size_rounded < mdah->size)
+			new_size_rounded = (mdac->rlocn.size | (alignment - 1)) + 1;
+		else
+			new_size_rounded = mdac->rlocn.size;
 	}
 
-	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64 " aligned to " FMTu64,
+	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64 " (rounded to " FMTu64 ") of " FMTu64 " aligned to " FMTu64,
 			    vg->name, dev_name(mdac->area.dev), mdac->area.start +
-			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap, mdac->rlocn.size, alignment);
+			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap, new_size_rounded, mdac->rlocn.size, alignment);
 
-	/* Write text out, circularly */
-	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
-		       (size_t) (mdac->rlocn.size - new_wrap), MDA_CONTENT_REASON(mda_is_primary(mda)),
-		       fidtc->raw_metadata_buf))
-		goto_out;
+	if (!new_wrap) {
+		/* Write text out, in alignment-sized blocks */
+		if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
+			       (size_t) new_size_rounded, MDA_CONTENT_REASON(mda_is_primary(mda)),
+			       fidtc->raw_metadata_buf))
+			goto_out;
+	} else {
+		/* Write text out, circularly */
+		if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
+			       (size_t) (mdac->rlocn.size - new_wrap), MDA_CONTENT_REASON(mda_is_primary(mda)),
+			       fidtc->raw_metadata_buf))
+			goto_out;
 
-	if (new_wrap) {
 		log_debug_metadata("Writing wrapped metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64,
 				  dev_name(mdac->area.dev), mdac->area.start +
 				  MDA_HEADER_SIZE, new_wrap, mdac->rlocn.size);
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 1eed664..bc25597 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -17,6 +17,7 @@
 #define _LVM_TEXT_LAYOUT_H
 
 #include "config.h"
+#include "format-text.h"
 #include "metadata.h"
 #include "lvmcache.h"
 #include "uuid.h"


