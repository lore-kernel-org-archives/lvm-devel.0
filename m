From: David Teigland <teigland@sourceware.org>
Date: Thu, 20 Jun 2019 17:10:07 -0400
Subject: master - metadata: include description with command in metadata areas
Message-ID: <201906202110.x5KLA7SR025801@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8fecd9c14e0b3f62cc4de6ddac0a015db687b335
Commit:        8fecd9c14e0b3f62cc4de6ddac0a015db687b335
Parent:        82b137ef2f7f1b6fc1bbf83918750037835a9568
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 18 16:10:06 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 20 16:09:05 2019 -0500

metadata: include description with command in metadata areas

Previously the VG metadata description field (which contains
the command line) was only included in backup/archive copies
of the metadata.  Now also include it in the metadata written
to the metadata areas.
---
 lib/format_text/export.c      |    4 ++--
 lib/format_text/format-text.c |   27 ++++++++++++++++++++++++++-
 lib/metadata/metadata.h       |    1 -
 lib/metadata/vg.h             |    1 +
 test/shell/metadata.sh        |    4 ++++
 5 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 841e06d..2a3f844 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -1086,7 +1086,7 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 	return r;
 }
 
-size_t export_vg_to_buffer(struct volume_group *vg, char **buf)
+static size_t _export_vg_to_buffer(struct volume_group *vg, char **buf)
 {
 	return text_vg_export_raw(vg, "", buf);
 }
@@ -1096,7 +1096,7 @@ struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg)
 	char *buf = NULL;
 	struct dm_config_tree *vg_cft;
 
-	if (!export_vg_to_buffer(vg, &buf)) {
+	if (!_export_vg_to_buffer(vg, &buf)) {
 		log_error("Could not format metadata for VG %s.", vg->name);
 		return NULL;
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 13b2c66..6873f19 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -493,6 +493,29 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	return vg;
 }
 
+#define MAX_DESC_LEN 2048
+
+static char *_build_desc_write(struct cmd_context *cmd, struct volume_group *vg)
+{
+	size_t len = strlen(cmd->cmd_line) + 32;
+	char *desc;
+
+	if (len > MAX_DESC_LEN)
+		len = MAX_DESC_LEN;
+
+	if (!(desc = zalloc(len)))
+		return_NULL;
+
+	vg->write_count++;
+
+	if (vg->write_count == 1)
+		dm_snprintf(desc, len, "Write from %s.", cmd->cmd_line);
+	else
+		dm_snprintf(desc, len, "Write[%u] from %s.", vg->write_count, cmd->cmd_line);
+
+	return desc;
+}
+
 /*
  * VG metadata updates:
  *
@@ -576,9 +599,11 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 		new_buf = fidtc->raw_metadata_buf;
 		new_size = fidtc->raw_metadata_buf_size;
 	} else {
-		new_size = text_vg_export_raw(vg, "", &new_buf);
+		char *desc = _build_desc_write(fid->fmt->cmd, vg);
+		new_size = text_vg_export_raw(vg, desc, &new_buf);
 		fidtc->raw_metadata_buf = new_buf;
 		fidtc->raw_metadata_buf_size = new_size;
+		free(desc);
 	}
 
 	if (!new_size || !new_buf) {
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 63ee4a6..2fc0015 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -473,7 +473,6 @@ void lv_calculate_readahead(const struct logical_volume *lv, uint32_t *read_ahea
 /*
  * For internal metadata caching.
  */
-size_t export_vg_to_buffer(struct volume_group *vg, char **buf);
 struct dm_config_tree *export_vg_to_config_tree(struct volume_group *vg);
 struct volume_group *import_vg_from_config_tree(const struct dm_config_tree *cft,
 						struct format_instance *fid);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 6e89b33..2e21461 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -42,6 +42,7 @@ struct volume_group {
 	struct lvmcache_vginfo *vginfo;
 	uint32_t seqno;		/* Metadata sequence number */
 	unsigned skip_validate_lock_args : 1;
+	uint32_t write_count; /* count the number of vg_write calls */
 
 	/*
 	 * The parsed committed (on-disk) copy of this VG; is NULL if this VG is committed
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index a86bc0b..f5d6483 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -26,6 +26,10 @@ pvcreate --metadatacopies 0 "$dev5"
 vgcreate $SHARED "$vg" "${DEVICES[@]}"
 lvcreate -n $lv -l 1 -i5 -I256 $vg
 
+pvck --dump metadata "$dev1" > meta1
+grep "description = " meta1 > desc1
+grep "Write from lvcreate" desc1
+
 pvchange -x n "$dev1"
 pvchange -x y "$dev1"
 vgchange -a n $vg


