From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Mar 2015 13:31:40 +0000 (UTC)
Subject: master - lib: avoid reparsing same metadata
Message-ID: <20150306133140.120FD606F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e7411966afc4309cdd91bfed4846720b308c84d
Commit:        7e7411966afc4309cdd91bfed4846720b308c84d
Parent:        6a2ae250ffc52c7620ec837cb10eb7b9ca44a121
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 26 13:35:26 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 6 13:53:12 2015 +0100

lib: avoid reparsing same metadata

When reading VG mda from multiple PVs - do all the validation only
when mda is seen for the first time and  when mda checksum and length
is same just return already existing VG pointer.

(i.e. using 300PVs for a VG would lead to create and destroy 300 config trees....)
---
 WHATS_NEW                        |    1 +
 lib/config/config.c              |   18 +++++++++++++-----
 lib/config/config.h              |    3 ++-
 lib/format_text/import.c         |   24 ++++++++++++++++++++++--
 lib/metadata/metadata-exported.h |    5 +++++
 lib/metadata/metadata.c          |    1 +
 6 files changed, 44 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b62a632..ef5abcd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Avoid reparsing same metadata when reading same metadata from multiple PVs.
   Save extra device open/close when scanning device for size.
   Fix seg_monitor field to report status also for mirrors and thick snapshots.
 
diff --git a/lib/config/config.c b/lib/config/config.c
index effe93d..5de6df6 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -478,9 +478,15 @@ int override_config_tree_from_profile(struct cmd_context *cmd,
 	return 0;
 }
 
+/*
+ * When skip_parse is set, the checksum of buffer is only matched
+ * and function avoids parsing of mda into config tree which
+ * remains unmodified and should not be used.
+ */
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
-			checksum_fn_t checksum_fn, uint32_t checksum)
+			checksum_fn_t checksum_fn, uint32_t checksum,
+			int skip_parse)
 {
 	char *fb, *fe;
 	int r = 0;
@@ -529,9 +535,11 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 		goto out;
 	}
 
-	fe = fb + size + size2;
-	if (!dm_config_parse(cft, fb, fe))
-		goto_out;
+	if (!skip_parse) {
+		fe = fb + size + size2;
+		if (!dm_config_parse(cft, fb, fe))
+			goto_out;
+	}
 
 	r = 1;
 
@@ -575,7 +583,7 @@ int config_file_read(struct dm_config_tree *cft)
 	}
 
 	r = config_file_read_fd(cft, cf->dev, 0, (size_t) info.st_size, 0, 0,
-				(checksum_fn_t) NULL, 0);
+				(checksum_fn_t) NULL, 0, 0);
 
 	if (!cf->keep_open) {
 		if (!dev_close(cf->dev))
diff --git a/lib/config/config.h b/lib/config/config.h
index ba34354..50ea361 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -205,7 +205,8 @@ typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_
 struct dm_config_tree *config_open(config_source_t source, const char *filename, int keep_open);
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
-			checksum_fn_t checksum_fn, uint32_t checksum);
+			checksum_fn_t checksum_fn, uint32_t checksum,
+			int skip_parse);
 int config_file_read(struct dm_config_tree *cft);
 struct dm_config_tree *config_file_open_and_read(const char *config_file, config_source_t source,
 						 struct cmd_context *cmd);
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index fe19dd7..8a1771a 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -51,7 +51,7 @@ const char *text_vgname_import(const struct format_type *fmt,
 
 	if ((!dev && !config_file_read(cft)) ||
 	    (dev && !config_file_read_fd(cft, dev, offset, size,
-					 offset2, size2, checksum_fn, checksum))) {
+					 offset2, size2, checksum_fn, checksum, 0))) {
 		log_error("Couldn't read volume group metadata.");
 		goto out;
 	}
@@ -88,6 +88,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	struct volume_group *vg = NULL;
 	struct dm_config_tree *cft;
 	struct text_vg_version_ops **vsn;
+	int skip_parse;
 
 	_init_text_import();
 
@@ -97,11 +98,20 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	if (!(cft = config_open(CONFIG_FILE_SPECIAL, file, 0)))
 		return_NULL;
 
+	skip_parse = fid->vg && (fid->mda_checksum == checksum) &&
+		(fid->mda_size == (size + size2));
+
 	if ((!dev && !config_file_read(cft)) ||
 	    (dev && !config_file_read_fd(cft, dev, offset, size,
-					 offset2, size2, checksum_fn, checksum)))
+					 offset2, size2, checksum_fn, checksum,
+					 skip_parse)))
 		goto_out;
 
+	if (skip_parse) {
+		vg = fid->vg;
+		goto out;
+	}
+
 	/*
 	 * Find a set of version functions that can read this file
 	 */
@@ -116,6 +126,16 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		break;
 	}
 
+	if (vg && (!fid->vg || (vg->seqno > fid->vg->seqno))) {
+		/*
+		 * Remember vg pointer to newest VG for reuse.
+		 * NOTE: _vg_read() will not release same VG
+		 */
+		fid->vg = vg;
+		fid->mda_size = (size + size2);
+		fid->mda_checksum = checksum;
+	}
+
       out:
 	config_destroy(cft);
 	return vg;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8c081d9..b5ab1f2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -324,6 +324,11 @@ struct format_instance {
 	struct dm_list metadata_areas_ignored;
 	struct dm_hash_table *metadata_areas_index;
 
+	/* Remember last vg to avoid parsing same mda content for multiple PVs */
+	struct volume_group *vg;
+	uint32_t mda_checksum;
+	size_t mda_size;
+
 	void *private;
 };
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7e440a4..57066a5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3365,6 +3365,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		}
 
 		if (vg != correct_vg)
+			/* NOTE: tied to fid->vg logic in text_vg_import_fd() */
 			release_vg(vg);
 	}
 	fid->ref_count--;


