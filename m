From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:27 +0000 (UTC)
Subject: dev-dct-process-latest - metadata: validate major, minor numbers
Message-ID: <20140922153927.D312D6092E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=73f4fa6bc100e21562397627ea95a5e89443c1ab
Commit:        73f4fa6bc100e21562397627ea95a5e89443c1ab
Parent:        656ba3a744af5548ee0a5983590698aeee3dd326
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 14:51:41 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 15:53:27 2014 +0200

metadata: validate major, minor numbers

Validate major, minor numbers after reading them from metadata.
---
 WHATS_NEW                        |    1 +
 lib/format_text/import_vsn1.c    |   33 +++++++++++++++++-----------
 lib/metadata/metadata-exported.h |    3 ++
 lib/metadata/metadata.c          |   43 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e06fcc2..24e28c7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Validate major and minor numbers stored in metadata.
   Use -fPIE when linking -pie executables.
   Enable cache segment type by default.
   Ensure only supported volume types are used with cache segments.
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 174b3bf..580349f 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -635,7 +635,7 @@ static int _read_lvnames(struct format_instance *fid __attribute__((unused)),
 	return 1;
 }
 
-static int _read_lvsegs(struct format_instance *fid __attribute__((unused)),
+static int _read_lvsegs(struct format_instance *fid,
 			struct volume_group *vg, const struct dm_config_node *lvn,
 			const struct dm_config_node *vgn __attribute__((unused)),
 			struct dm_hash_table *pv_hash,
@@ -668,20 +668,27 @@ static int _read_lvsegs(struct format_instance *fid __attribute__((unused)),
 		return_0;
 
 	lv->size = (uint64_t) lv->le_count * (uint64_t) vg->extent_size;
-
 	lv->minor = -1;
-	if ((lv->status & FIXED_MINOR) &&
-	    !_read_int32(lvn, "minor", &lv->minor)) {
-		log_error("Couldn't read minor number for logical "
-			  "volume %s.", lv->name);
-		return 0;
-	}
-
 	lv->major = -1;
-	if ((lv->status & FIXED_MINOR) &&
-	    !_read_int32(lvn, "major", &lv->major)) {
-		log_error("Couldn't read major number for logical "
-			  "volume %s.", lv->name);
+
+	if (lv->status & FIXED_MINOR) {
+		if (!_read_int32(lvn, "minor", &lv->minor)) {
+			log_error("Couldn't read minor number for logical "
+				  "volume %s.", lv->name);
+			return 0;
+		}
+
+		if (!_read_int32(lvn, "major", &lv->major)) {
+			log_error("Couldn't read major number for logical "
+				  "volume %s.", lv->name);
+			return 0;
+		}
+
+		if (!validate_major_minor(vg->cmd, fid->fmt, lv->major, lv->minor)) {
+			log_error("Logical volume %s does not have a valid major, minor number.",
+				  lv->name);
+			return 0;
+		}
 	}
 
 	return 1;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 935d3f7..aa0edcf 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1136,6 +1136,9 @@ struct vgcreate_params {
 	uint32_t vgmetadatacopies;
 };
 
+int validate_major_minor(const struct cmd_context *cmd,
+			 const struct format_type *fmt,
+			 int32_t major, int32_t minor);
 int vgcreate_params_validate(struct cmd_context *cmd,
 			     struct vgcreate_params *vp);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2900ccc..0842563 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -837,6 +837,49 @@ const char *strip_dir(const char *vg_name, const char *dev_dir)
 }
 
 /*
+ * Validates major and minor numbers.
+ * On >2.4 kernel we only support dynamic major number.
+ */
+int validate_major_minor(const struct cmd_context *cmd,
+			 const struct format_type *fmt,
+			 int32_t major, int32_t minor)
+{
+	int r = 1;
+
+	if (!strncmp(cmd->kernel_vsn, "2.4.", 4) ||
+	    (fmt->features & FMT_RESTRICTED_LVIDS)) {
+		if (major < 0 || major > 255) {
+			log_error("Major number %d outside range 0-255.", major);
+			r = 0;
+		}
+		if (minor < 0 || minor > 255) {
+			log_error("Minor number %d outside range 0-255.", minor);
+			r = 0;
+		}
+	} else {
+		/* 12 bits for major number */
+		if ((major != -1) &&
+		    (major != cmd->dev_types->device_mapper_major)) {
+			/* User supplied some major number */
+			if (major < 0 || major > 4095) {
+				log_error("Major number %d outside range 0-4095.", major);
+				r = 0;
+			} else
+				log_print_unless_silent("Ignoring supplied major %d number - "
+							"kernel assigns major numbers dynamically.",
+							major);
+		}
+		/* 20 bits for minor number */
+		if (minor < 0 || minor > 1048575) {
+			log_error("Minor number %d outside range 0-1048575.", minor);
+			r = 0;
+		}
+	}
+
+	return r;
+}
+
+/*
  * Validate parameters to vg_create() before calling.
  * FIXME: Move inside vg_create library function.
  * FIXME: Change vgcreate_params struct to individual gets/sets


