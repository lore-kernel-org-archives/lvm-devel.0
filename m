From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 Oct 2019 14:00:34 -0400
Subject: master - vgck: fix updatemetadata writing different descriptions
Message-ID: <201910111800.x9BI0You024266@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6ffc990523468e46ae03a462ef1ec73067f9934
Commit:        d6ffc990523468e46ae03a462ef1ec73067f9934
Parent:        fe16d296b058333fddd5102afbebf95a18f85468
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 8 14:36:55 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 11 12:57:32 2019 -0500

vgck: fix updatemetadata writing different descriptions

vgck --updatemetadata would write the same correct
metadata to good mdas, and then to bad mdas, but the
sequence of vg_write/vg_commit calls betwen good and
bad mdas could cause a different description field to
be generated for good/bad mdas. (The description field
describing the command was recently included in the
ondisk copy of the metadata text.)
---
 lib/format_text/format-text.c |   29 ++++++++++++++++++++++++++++-
 lib/format_text/format-text.h |    3 +++
 tools/vgck.c                  |   15 +++++++++++++++
 3 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index be4730b..6ec47bf 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -41,8 +41,35 @@ struct text_fid_context {
 	char *write_buf;         /* buffer containing metadata text to write to disk */
 	uint32_t write_buf_size; /* mem size of write_buf, increases in 64K multiples */
 	uint32_t new_metadata_size; /* size of text metadata in buf */
+	unsigned preserve:1;
 };
 
+void preserve_text_fidtc(struct volume_group *vg)
+{
+	struct format_instance *fid = vg->fid;
+	struct text_fid_context *fidtc = (struct text_fid_context *)fid->private;
+
+	if (fidtc)
+		fidtc->preserve = 1;
+}
+
+void free_text_fidtc(struct volume_group *vg)
+{
+	struct format_instance *fid = vg->fid;
+	struct text_fid_context *fidtc = (struct text_fid_context *)fid->private;
+
+	if (!fidtc)
+		return;
+
+	fidtc->preserve = 0;
+
+	if (fidtc->write_buf)
+		free(fidtc->write_buf);
+	fidtc->write_buf = NULL;
+	fidtc->write_buf_size = 0;
+	fidtc->new_metadata_size = 0;
+}
+
 int rlocn_is_ignored(const struct raw_locn *rlocn)
 {
 	return (rlocn->flags & RAW_LOCN_IGNORED ? 1 : 0);
@@ -1183,7 +1210,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	r = 1;
 
       out:
-	if (!precommit) {
+	if (!precommit && !fidtc->preserve) {
 		free(fidtc->write_buf);
 		fidtc->write_buf = NULL;
 		fidtc->write_buf_size = 0;
diff --git a/lib/format_text/format-text.h b/lib/format_text/format-text.h
index 2345d52..552bfb7 100644
--- a/lib/format_text/format-text.h
+++ b/lib/format_text/format-text.h
@@ -80,4 +80,7 @@ struct data_area_list {
 int text_wipe_outdated_pv_mda(struct cmd_context *cmd, struct device *dev,
                               struct metadata_area *mda);
 
+void preserve_text_fidtc(struct volume_group *vg);
+void free_text_fidtc(struct volume_group *vg);
+
 #endif
diff --git a/tools/vgck.c b/tools/vgck.c
index 46ad594..4e797e7 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+#include "lib/format_text/format-text.h"
 
 /*
  * TODO: we cannot yet repair corruption in label_header, pv_header/locations,
@@ -39,6 +40,14 @@ static int _update_metadata_single(struct cmd_context *cmd __attribute__((unused
 		return 0;
 	}
 
+	/*
+	 * Prevent vg_commit from freeing the metadata
+	 * buffer that vg_write wrote to disk so that
+	 * vg_write_commit_bad_mdas() can use the same
+	 * metadata buffer to write to the bad mdas.
+	 */
+	preserve_text_fidtc(vg);
+
 	if (!vg_commit(vg)) {
 		log_error("Failed to commit VG.");
 		return 0;
@@ -53,6 +62,12 @@ static int _update_metadata_single(struct cmd_context *cmd __attribute__((unused
 	 */
 	vg_write_commit_bad_mdas(cmd, vg);
 
+	/*
+	 * Now free the metadata buffer that was
+	 * preserved above.
+	 */
+	free_text_fidtc(vg);
+
 	return 1;
 }
 


