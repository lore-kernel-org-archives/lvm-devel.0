From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 26 Mar 2012 14:30:36 +0200
Subject: [PATCH 2/2] Avoid reparsing same metadata
In-Reply-To: <cover.1332764920.git.zkabelac@redhat.com>
References: <cover.1332764920.git.zkabelac@redhat.com>
Message-ID: <6f5d97f81e11b396305b80565bd00e075d15567b.1332764920.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When reading VG - we read mda from some PV - do all the validation,
and then we read another mda from next PV and the same thing again.
But in case - we could trust checksum and length - it seems just
wasting CPU  (i.e. using 300PVs for a VG would lead to create and
destroy 300 config trees....)

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/config.c              |   10 ++++++++--
 lib/config/config.h              |    3 ++-
 lib/format_text/import.c         |   19 +++++++++++++++++--
 lib/metadata/metadata-exported.h |    5 +++++
 4 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 67a8b04..532812c 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -189,7 +189,8 @@ int override_config_tree_from_string(struct cmd_context *cmd,
 
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
-			checksum_fn_t checksum_fn, uint32_t checksum)
+			checksum_fn_t checksum_fn, uint32_t checksum,
+			int skip_parse)
 {
 	char *fb, *fe;
 	int r = 0;
@@ -230,6 +231,11 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 		goto out;
 	}
 
+	if (skip_parse) {
+		r = 1;
+		goto out;
+	}
+
 	fe = fb + size + size2;
 	if (!dm_config_parse(cft, fb, fe))
 		goto_out;
@@ -273,7 +279,7 @@ int config_file_read(struct dm_config_tree *cft)
 	}
 
 	r = config_file_read_fd(cft, cf->dev, 0, (size_t) info.st_size, 0, 0,
-				(checksum_fn_t) NULL, 0);
+				(checksum_fn_t) NULL, 0, 0);
 
 	if (!cf->keep_open) {
 		if (!dev_close(cf->dev))
diff --git a/lib/config/config.h b/lib/config/config.h
index d789ade..7eb56f0 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -30,7 +30,8 @@ typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_
 struct dm_config_tree *config_file_open(const char *filename, int keep_open);
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
-			checksum_fn_t checksum_fn, uint32_t checksum);
+			checksum_fn_t checksum_fn, uint32_t checksum,
+			int skip_parse);
 	int config_file_read(struct dm_config_tree *cft);
 int config_write(struct dm_config_tree *cft, const char *file,
 		 int argc, char **argv);
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 3d2f496..26f6cb9 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -89,6 +89,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	struct volume_group *vg = NULL;
 	struct dm_config_tree *cft;
 	struct text_vg_version_ops **vsn;
+	int skip;
 
 	_init_text_import();
 
@@ -98,13 +99,21 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	if (!(cft = config_file_open(file, 0)))
 		return_NULL;
 
+	skip = fid->vg && (fid->mda_checksum == checksum) &&
+		(fid->mda_size == (size + size2));
+
 	if ((!dev && !config_file_read(cft)) ||
-	    (dev && !config_file_read_fd(cft, dev, offset, size,
-					 offset2, size2, checksum_fn, checksum))) {
+	    (dev && !config_file_read_fd(cft, dev, offset, size, offset2,
+					 size2, checksum_fn, checksum, skip))) {
 		log_error("Couldn't read volume group metadata.");
 		goto out;
 	}
 
+	if (skip) {
+		vg = fid->vg;
+		goto out;
+	}
+
 	/*
 	 * Find a set of version functions that can read this file
 	 */
@@ -119,6 +128,12 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		break;
 	}
 
+	if (vg && (!fid->vg || (vg->seqno > fid->vg->seqno))) {
+		fid->vg = vg;
+		fid->mda_size = (size + size2);
+		fid->mda_checksum = checksum;
+	}
+
       out:
 	config_file_destroy(cft);
 	return vg;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 10cd910..7d1812c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -233,6 +233,11 @@ struct format_instance {
 	struct dm_list metadata_areas_ignored;
 	struct dm_hash_table *metadata_areas_index;
 
+	/* Speedup parser - avoid repeateadly parse same mda content */
+	struct volume_group *vg;
+	uint32_t mda_checksum;
+	size_t mda_size;
+
 	void *private;
 };
 
-- 
1.7.9.3


