From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 Sep 2016 16:18:52 +0000 (UTC)
Subject: master - config: parse config tree without dup node checking if it's metadata tree
Message-ID: <20160921161852.1E74C60F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e40fbd08c8e3da43d07aabe58bd5549105056908
Commit:        e40fbd08c8e3da43d07aabe58bd5549105056908
Parent:        7563e69cf13126af5889de147c092b9d2e490648
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 21 14:27:15 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 21 18:16:05 2016 +0200

config: parse config tree without dup node checking if it's metadata tree

---
 lib/config/config.c      |   13 +++++++++----
 lib/config/config.h      |    2 +-
 lib/format_text/import.c |    4 ++--
 tools/toollib.c          |    2 +-
 4 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 820a744..6ad04e5 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -496,7 +496,7 @@ int override_config_tree_from_profile(struct cmd_context *cmd,
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
-			int checksum_only)
+			int checksum_only, int no_dup_node_check)
 {
 	char *fb, *fe;
 	int r = 0;
@@ -547,8 +547,13 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 
 	if (!checksum_only) {
 		fe = fb + size + size2;
-		if (!dm_config_parse(cft, fb, fe))
-			goto_out;
+		if (no_dup_node_check) {
+			if (!dm_config_parse_without_dup_node_check(cft, fb, fe))
+				goto_out;
+		} else {
+			if (!dm_config_parse(cft, fb, fe))
+				goto_out;
+		}
 	}
 
 	r = 1;
@@ -596,7 +601,7 @@ int config_file_read(struct dm_config_tree *cft)
 	}
 
 	r = config_file_read_fd(cft, cf->dev, 0, (size_t) info.st_size, 0, 0,
-				(checksum_fn_t) NULL, 0, 0);
+				(checksum_fn_t) NULL, 0, 0, 0);
 
 	if (!cf->keep_open) {
 		if (!dev_close(cf->dev))
diff --git a/lib/config/config.h b/lib/config/config.h
index f0202b6..8a7d6c3 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -239,7 +239,7 @@ struct dm_config_tree *config_open(config_source_t source, const char *filename,
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
-			int skip_parse);
+			int skip_parse, int no_dup_node_check);
 int config_file_read(struct dm_config_tree *cft);
 struct dm_config_tree *config_file_open_and_read(const char *config_file, config_source_t source,
 						 struct cmd_context *cmd);
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 629884b..62dee8f 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -56,7 +56,7 @@ int text_vgsummary_import(const struct format_type *fmt,
 	    (dev && !config_file_read_fd(cft, dev, offset, size,
 					 offset2, size2, checksum_fn,
 					 vgsummary->mda_checksum,
-					 checksum_only))) {
+					 checksum_only, 1))) {
 		log_error("Couldn't read volume group metadata.");
 		goto out;
 	}
@@ -130,7 +130,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	if ((!dev && !config_file_read(cft)) ||
 	    (dev && !config_file_read_fd(cft, dev, offset, size,
 					 offset2, size2, checksum_fn, checksum,
-					 skip_parse)))
+					 skip_parse, 1)))
 		goto_out;
 
 	if (skip_parse) {
diff --git a/tools/toollib.c b/tools/toollib.c
index ec6f2f7..9127d85 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1386,7 +1386,7 @@ int get_cache_params(struct cmd_context *cmd,
 						  NULL)))
 			goto_out;
 
-		if (!dm_config_parse(current, str, str + strlen(str)))
+		if (!dm_config_parse_without_dup_node_check(current, str, str + strlen(str)))
 			goto_out;
 	}
 


