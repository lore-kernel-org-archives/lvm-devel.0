From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 12:21:07 -0500
Subject: master - pvck: move some arg processing
Message-ID: <24827.119112712210201509@us-mta-311.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=53126ceada394f7c12ce95c4cd8d824132d418eb
Commit:        53126ceada394f7c12ce95c4cd8d824132d418eb
Parent:        94076245df6e99492a7a0bb2d8c2f2bc2616259d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 21 16:39:46 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 11:13:47 2019 -0600

pvck: move some arg processing

---
 tools/pvck.c |  103 +++++++++++++++++++++-------------------------------------
 1 files changed, 37 insertions(+), 66 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 231faf9..d2c2f9d 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -807,8 +807,8 @@ static int _dump_current_text(struct device *dev,
 	return 1;
 }
 
-static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
-				     struct device *dev,
+static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsector, struct device *dev,
+				     int print_fields,
 				     int *found_label,
 				     uint64_t *mda1_offset, uint64_t *mda1_size,
 				     uint64_t *mda2_offset, uint64_t *mda2_size,
@@ -824,22 +824,11 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, int print_fields,
 	uint64_t pvhe_offset;
 	uint64_t dlocn_offset;
 	char *buf;
-	uint64_t labelsector;
 	uint64_t tmp;
 	int mda_count = 0;
 	int bad = 0;
 	int di;
 
-	/*
-	 * By default LVM skips the first sector (sector 0), and writes
-	 * the label_header in the second sector (sector 1).
-	 * (sector size 512 bytes)
-	 */
-	if (arg_is_set(cmd, labelsector_ARG))
-		labelsector = arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0));
-	else
-		labelsector = 1;
-
 	lh_offset = labelsector * 512; /* from start of disk */
 
 	if (!(buf = zalloc(512)))
@@ -1194,26 +1183,15 @@ static int _dump_mda_header(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _dump_headers(struct cmd_context *cmd,
+static int _dump_headers(struct cmd_context *cmd, uint64_t labelsector, struct device *dev,
 			 int argc, char **argv)
 {
-	struct device *dev;
-	const char *pv_name;
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
 	uint32_t mda1_checksum, mda2_checksum;
 	int mda_count = 0;
 	int bad = 0;
 
-	pv_name = argv[0];
-
-	if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
-		log_error("No device found for %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
-		return ECMD_FAILED;
-	}
-
-	label_scan_setup_bcache();
-
-	if (!_dump_label_and_pv_header(cmd, 1, dev, NULL,
+	if (!_dump_label_and_pv_header(cmd, labelsector, dev, 1, NULL,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count))
 		bad++;
 
@@ -1261,12 +1239,10 @@ static int _dump_headers(struct cmd_context *cmd,
 	return ECMD_PROCESSED;
 }
 
-static int _dump_metadata(struct cmd_context *cmd,
+static int _dump_metadata(struct cmd_context *cmd, uint64_t labelsector, struct device *dev,
 			 int argc, char **argv,
 			 int print_metadata, int print_area)
 {
-	struct device *dev;
-	const char *pv_name;
 	const char *tofile = NULL;
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
 	uint32_t mda1_checksum, mda2_checksum;
@@ -1283,16 +1259,7 @@ static int _dump_metadata(struct cmd_context *cmd,
 	if (arg_is_set(cmd, pvmetadatacopies_ARG))
 		mda_num = arg_int_value(cmd, pvmetadatacopies_ARG, 1);
 
-	pv_name = argv[0];
-
-	if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
-		log_error("No device found for %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
-		return ECMD_FAILED;
-	}
-
-	label_scan_setup_bcache();
-
-	if (!_dump_label_and_pv_header(cmd, 0, dev, NULL,
+	if (!_dump_label_and_pv_header(cmd, labelsector, dev, 0, NULL,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count))
 		bad++;
 
@@ -1338,8 +1305,7 @@ static int _dump_metadata(struct cmd_context *cmd,
 	return ECMD_PROCESSED;
 }
 
-static int _dump_found(struct cmd_context *cmd, struct device *dev,
-		       uint64_t labelsector)
+static int _dump_found(struct cmd_context *cmd, uint64_t labelsector, struct device *dev)
 {
 	uint64_t mda1_offset = 0, mda1_size = 0, mda2_offset = 0, mda2_size = 0;
 	uint32_t mda1_checksum = 0, mda2_checksum = 0;
@@ -1347,7 +1313,7 @@ static int _dump_found(struct cmd_context *cmd, struct device *dev,
 	int mda_count = 0;
 	int bad = 0;
 
-	if (!_dump_label_and_pv_header(cmd, 0, dev, &found_label,
+	if (!_dump_label_and_pv_header(cmd, labelsector, dev, 0, &found_label,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count))
 		bad++;
 
@@ -1392,12 +1358,10 @@ static int _dump_found(struct cmd_context *cmd, struct device *dev,
  * zeroed/damaged.
  */
 
-static int _dump_search(struct cmd_context *cmd,
+static int _dump_search(struct cmd_context *cmd, uint64_t labelsector, struct device *dev,
 			int argc, char **argv)
 {
 	char str[256];
-	struct device *dev;
-	const char *pv_name;
 	const char *tofile = NULL;
 	char *buf;
 	struct mda_header *mh;
@@ -1416,16 +1380,7 @@ static int _dump_search(struct cmd_context *cmd,
 	if (arg_is_set(cmd, pvmetadatacopies_ARG))
 		mda_num = arg_int_value(cmd, pvmetadatacopies_ARG, 1);
 
-	pv_name = argv[0];
-
-	if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
-		log_error("No device found for %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
-		return ECMD_FAILED;
-	}
-
-	label_scan_setup_bcache();
-
-	_dump_label_and_pv_header(cmd, 0, dev, NULL,
+	_dump_label_and_pv_header(cmd, labelsector, dev, 0, NULL,
 			&mda1_offset, &mda1_size, &mda2_offset, &mda2_size, &mda_count);
 
 	/*
@@ -1524,23 +1479,44 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	int bad = 0;
 	int i;
 
+	/*
+	 * By default LVM skips the first sector (sector 0), and writes
+	 * the label_header in the second sector (sector 1).
+	 * (sector size 512 bytes)
+	 */
+	if (arg_is_set(cmd, labelsector_ARG))
+		labelsector = arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0));
+
 	if (arg_is_set(cmd, dump_ARG)) {
+		pv_name = argv[0];
+
+		if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
+			log_error("No device found for %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
+			return ECMD_FAILED;
+		}
+	}
+
+	label_scan_setup_bcache();
+
+	if (arg_is_set(cmd, dump_ARG)) {
+		cmd->use_hints = 0;
+
 		dump = arg_str_value(cmd, dump_ARG, NULL);
 
 		if (!strcmp(dump, "metadata"))
-			return _dump_metadata(cmd, argc, argv, PRINT_CURRENT, 0);
+			return _dump_metadata(cmd, labelsector, dev, argc, argv, PRINT_CURRENT, 0);
 
 		if (!strcmp(dump, "metadata_all"))
-			return _dump_metadata(cmd, argc, argv, PRINT_ALL, 0);
+			return _dump_metadata(cmd, labelsector, dev, argc, argv, PRINT_ALL, 0);
 
 		if (!strcmp(dump, "metadata_area"))
-			return _dump_metadata(cmd, argc, argv, 0, 1);
+			return _dump_metadata(cmd, labelsector, dev, argc, argv, 0, 1);
 
 		if (!strcmp(dump, "metadata_search"))
-			return _dump_search(cmd, argc, argv);
+			return _dump_search(cmd, labelsector, dev, argc, argv);
 
 		if (!strcmp(dump, "headers"))
-			return _dump_headers(cmd, argc, argv);
+			return _dump_headers(cmd, labelsector, dev, argc, argv);
 
 		log_error("Unknown dump value.");
 		return ECMD_FAILED;
@@ -1551,11 +1527,6 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	 * but this is here to preserve the historical output.
 	 */
 
-	if (arg_is_set(cmd, labelsector_ARG))
-		labelsector = arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0));
-
-	label_scan_setup_bcache();
-
 	for (i = 0; i < argc; i++) {
 		pv_name = argv[i];
 
@@ -1564,7 +1535,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 			continue;
 		}
 
-		if (!_dump_found(cmd, dev, labelsector))
+		if (!_dump_found(cmd, labelsector, dev))
 			bad++;
 	}
 



