From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:55 -0500
Subject: master - cov: inline _build_desc_write
Message-ID: <83030.119111412075302485@us-mta-289.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1da5fd822665e385415ffdf4a0e43e46c6fd7ba5
Commit:        1da5fd822665e385415ffdf4a0e43e46c6fd7ba5
Parent:        61a483a654d87fc514dd4e7570467797247b6031
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 16:58:18 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

cov: inline _build_desc_write

Embed function into the code, since the function is actually
simpler written this as there are no memleak troubles
with failing allocation error path.
---
 lib/format_text/format-text.c |   31 ++++++-------------------------
 1 files changed, 6 insertions(+), 25 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index f3536e7..2c2b7fa 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -531,29 +531,6 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	return vg;
 }
 
-#define MAX_DESC_LEN 2048
-
-static char *_build_desc_write(struct cmd_context *cmd, struct volume_group *vg)
-{
-	size_t len = strlen(cmd->cmd_line) + 32;
-	char *desc;
-
-	if (len > MAX_DESC_LEN)
-		len = MAX_DESC_LEN;
-
-	if (!(desc = zalloc(len)))
-		return_NULL;
-
-	vg->write_count++;
-
-	if (vg->write_count == 1)
-		dm_snprintf(desc, len, "Write from %s.", cmd->cmd_line);
-	else
-		dm_snprintf(desc, len, "Write[%u] from %s.", vg->write_count, cmd->cmd_line);
-
-	return desc;
-}
-
 /*
  * VG metadata updates:
  *
@@ -598,6 +575,7 @@ static char *_build_desc_write(struct cmd_context *cmd, struct volume_group *vg)
 static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			 struct metadata_area *mda)
 {
+	char desc[2048];
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct text_fid_context *fidtc = (struct text_fid_context *) fid->private;
 	struct raw_locn *rlocn_old;
@@ -672,12 +650,15 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		write_buf_size = fidtc->write_buf_size;
 		new_size = fidtc->new_metadata_size;
 	} else {
-		char *desc = _build_desc_write(fid->fmt->cmd, vg);
+		if (!vg->write_count++)
+			(void) dm_snprintf(desc, sizeof(desc), "Write from %s.", vg->cmd->cmd_line);
+		else
+			(void) dm_snprintf(desc, sizeof(desc), "Write[%u] from %s.", vg->write_count, vg->cmd->cmd_line);
+
 		new_size = text_vg_export_raw(vg, desc, &write_buf, &write_buf_size);
 		fidtc->write_buf = write_buf;
 		fidtc->write_buf_size = write_buf_size;
 		fidtc->new_metadata_size = new_size;
-		free(desc);
 	}
 
 	if (!new_size || !write_buf) {



